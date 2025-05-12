module ts_binding

import papyrus.ast
import strings
import gen.ts_binding.server_util as s_util
import gen.ts_binding.client_util as c_util

fn (mut g Gen) gen_server_main_cpp_file() {
	g.server_main_cpp.writeln(server_main_cpp_file_start)

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		g.server_main_cpp.writeln("static inline Napi::FunctionReference ${s_util.gen_ctor_name(file.obj_name)};")
		g.each_all_this_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl) {
			assert func.is_native
		
			g.server_main_cpp.writeln("static NativeFunction ${s_util.gen_vm_fn_impl_name(sym.name, func.name)} = nullptr;")
		})
	})

	g.server_main_cpp.writeln("")

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		bind_class_name := s_util.gen_bind_class_name(sym.name)

		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("// ==================================================================================")
		g.server_main_cpp.writeln("// ==================================${bind_class_name}==============================")
		g.server_main_cpp.writeln("")

		g.each_all_this_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl) {
			assert func.is_native
		
			g.gen_server_main_cpp_fn(sym, sym, func)
		})

		g.each_all_parent_fns(sym, fn[sym](mut g Gen, parent_sym &ast.TypeSymbol, func &ast.FnDecl) {
			assert func.is_native
		
			g.gen_server_main_cpp_fn(sym, parent_sym, func)
		})
		
		g.gen_server_main_cpp_end_class(sym, file)
	})

	g.server_main_cpp.writeln("void RegisterAllVMObjects(Napi::Env env, Napi::Object exports)")
	g.server_main_cpp.writeln("{")
	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		bind_class_name := s_util.gen_bind_class_name(sym.name)
		g.server_main_cpp.writeln("\t${bind_class_name}::Init(env, exports);")
	})
	g.server_main_cpp.writeln("}")

	g.server_main_cpp.writeln(server_main_cpp_file_end)
}

fn (mut g Gen) gen_server_main_cpp_fn(sym &ast.TypeSymbol, parent_sym &ast.TypeSymbol, func &ast.FnDecl) {
	js_class_name := s_util.gen_bind_class_name(sym.name)
	js_fn_name := s_util.gen_js_fn_name(func.name)

	g.server_main_cpp.writeln("Napi::Value ${js_class_name}::${js_fn_name}(const Napi::CallbackInfo& info)")
	g.server_main_cpp.writeln("{")
	g.server_main_cpp.writeln("\ttry")
	g.server_main_cpp.writeln("\t{")
	g.server_main_cpp.writeln("\t\tstd::vector<VarValue> args = {")

	for i in 0..func.params.len {
		param := func.params[i]

		if param.is_optional {
			mut arg := "info[${i}]"
			
			default_value := match param.default_value {
				ast.NoneLiteral {
					"" //unused
				}
				ast.IntegerLiteral,
				ast.FloatLiteral {
					param.default_value.val
				}
				ast.BoolLiteral {
					param.default_value.val.to_lower()
				}
				ast.StringLiteral {
					"\"${param.default_value.val}\""
				}
				else {
					panic("invalid expr in param")
				}
			}

			g.server_main_cpp.write_string("\t\t\t${s_util.gen_convert_to_varvalue_optional(g.table, param.typ, arg, default_value, param.name)}")
		}
		else {
			arg := "info[${i}]"
			g.server_main_cpp.write_string("\t\t\t${s_util.gen_convert_to_varvalue(g.table, param.typ, arg, param.name)}")
		}
		
		g.server_main_cpp.writeln(",")
	}

	if func.params.len > 0 {
		g.server_main_cpp.go_back("\n,".len)
		g.server_main_cpp.writeln("")
	}
	
	g.server_main_cpp.writeln("\t\t};")

	if !func.is_global {
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\t\tif (!self || self.GetType() != VarValue::Type::kType_Object)")
		g.server_main_cpp.writeln("\t\t{")
		g.server_main_cpp.writeln("\t\t\tthrow std::runtime_error(\"invalid self in ${js_class_name}::${js_fn_name}\");")
		g.server_main_cpp.writeln("\t\t}")
		g.server_main_cpp.writeln("")
	}

	g.server_main_cpp.writeln("\t\tNapi::Env env = info.Env();")
	
	if func.is_global {
		g.server_main_cpp.writeln("\t\tVarValue res = ${s_util.gen_vm_fn_impl_name(parent_sym.obj_name, func.name)}(VarValue::None(), args);")
	}
	else {
		g.server_main_cpp.writeln("\t\tVarValue res = ${s_util.gen_vm_fn_impl_name(parent_sym.obj_name, func.name)}(self, args);")
	}
	
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\t\treturn ${s_util.gen_convert_to_napivalue(g.table, func.return_type, "res")};")
	g.server_main_cpp.writeln("\t}")
	g.server_main_cpp.writeln("\tcatch(std::exception& e) {")
	g.server_main_cpp.writeln("\t\tspdlog::error((std::string)e.what());")
	g.server_main_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
	g.server_main_cpp.writeln("\t}")
	g.server_main_cpp.writeln("\treturn info.Env().Undefined();")
	g.server_main_cpp.writeln("}")
	g.server_main_cpp.writeln("")
}

fn (mut g Gen) gen_server_main_cpp_end_class(sym &ast.TypeSymbol, file &ast.File) {
	// Init
	// constructor
	// destructor
	// From
	// IsInstance
	// ToVMValue
	// ToNapiValue

	mut init_methods_bind_cpp := strings.new_builder(300)
	mut init_methods_bind_cpp_ptr := &init_methods_bind_cpp

	obj_name := sym.obj_name
	obj_name2 := sym.name
	obj_type := g.table.find_type_idx(sym.name)
	
	g.each_all_fns(sym, fn[mut init_methods_bind_cpp_ptr, obj_name](mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl) {
		assert func.is_native
		
		js_class_name := s_util.gen_bind_class_name(obj_name)
		js_fn_name := s_util.gen_js_fn_name(func.name)
		fn_name := func.name

		if func.is_global {
			init_methods_bind_cpp_ptr.write_string("\t\tStaticMethod(\"${fn_name}\", &${js_class_name}::${js_fn_name})")
		}
		else {
			init_methods_bind_cpp_ptr.write_string("\t\tInstanceMethod(\"${fn_name}\", &${js_class_name}::${js_fn_name})")
		}
		
		init_methods_bind_cpp_ptr.write_string(",\n")
	})
	
	if init_methods_bind_cpp_ptr.len > 0 {
		init_methods_bind_cpp_ptr.go_back(",\n".len) // remove last `,` + `\n`
	}

	g.server_main_cpp.writeln("Napi::Object ${s_util.gen_bind_class_name(obj_name2)}::Init(Napi::Env env, Napi::Object exports)")
	g.server_main_cpp.writeln("{")
	
	g.each_all_this_fns(sym, fn(mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl){
		assert func.is_native
		
		is_static_str := if func.is_global { "true" } else { "false" }
		g.server_main_cpp.writeln("\t${s_util.gen_vm_fn_impl_name(sum.obj_name, func.name)} = VirtualMachine::GetInstance()->GetFunctionImplementation(\"${sum.obj_name}\", \"${func.name}\", ${is_static_str});")
		g.server_main_cpp.writeln("\tif(!${s_util.gen_vm_fn_impl_name(sum.obj_name, func.name)}){")
		g.server_main_cpp.writeln("\t\tspdlog::error(\"failed to find function in Papyrus VM: `${sum.obj_name}.${func.name}`\");")
		g.server_main_cpp.writeln("\t\tthrow std::runtime_error(\"failed to find function in Papyrus VM: `${sum.obj_name}.${func.name}`\");")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("")
	})

	g.server_main_cpp.writeln("\tNapi::HandleScope scope(env);")
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\tNapi::Function func = DefineClass(env, \"${obj_name2}\", {")
	if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
		g.server_main_cpp.writeln("\t\tStaticMethod(\"From\", &${s_util.gen_bind_class_name(obj_name2)}::From),")
	}
	g.server_main_cpp.writeln("${init_methods_bind_cpp_ptr.str()}")
	g.server_main_cpp.writeln("\t});")
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\t${s_util.gen_ctor_name(obj_name2)} = Napi::Persistent(func);")
	g.server_main_cpp.writeln("\t${s_util.gen_ctor_name(obj_name2)}.SuppressDestruct();")
	g.server_main_cpp.writeln("\texports.Set(\"${obj_name2}\", func);")
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\treturn exports;")
	g.server_main_cpp.writeln("};")

	g.server_main_cpp.writeln("")
	
	g.server_main_cpp.write_string("${s_util.gen_bind_class_name(obj_name2)}::${s_util.gen_bind_class_name(obj_name2)}(const Napi::CallbackInfo& info) : ObjectWrap(info)")

	g.server_main_cpp.writeln("{")
	if !c_util.is_no_instance_class(g.no_instance_class, obj_type)
	{
		g.server_main_cpp.writeln("\tself = VarValue::None();")
	}
	g.server_main_cpp.writeln("};")

	g.server_main_cpp.writeln("")

	if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
		g.server_main_cpp.writeln("Napi::Value ${s_util.gen_bind_class_name(obj_name2)}::From(const Napi::CallbackInfo& info)")
		g.server_main_cpp.writeln("{")
		g.server_main_cpp.writeln("\ttry")
		g.server_main_cpp.writeln("\t{")
		g.server_main_cpp.writeln("\t\tuint32_t formId = NapiHelper::ExtractUInt32(info[0], \"formId\");")
		g.server_main_cpp.writeln("\t\tstd::optional<VarValue> form = LookupForm(formId);")

		g.server_main_cpp.writeln("\t\tif (!form.has_value())")
		g.server_main_cpp.writeln("\t\t{")
		g.server_main_cpp.writeln("\t\t\tspdlog::error(\"form not found `${s_util.gen_bind_class_name(obj_name2)}::From`\");")
		g.server_main_cpp.writeln("\t\t\tthrow std::runtime_error(\"form not found `${s_util.gen_bind_class_name(obj_name2)}::From`\");")
		g.server_main_cpp.writeln("\t\t}")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\t\treturn ${s_util.gen_bind_class_name(obj_name2)}::ToNapiValue(info.Env(), form.value());")

	/*
		g.server_main_cpp.writeln("\t\tauto formId = NapiHelper::ExtractUInt32(info[0], \"formId\");")
		g.server_main_cpp.writeln("\t\tauto& form = g_partOne->worldState.GetFormAt<MpForm>(formId);")
		g.server_main_cpp.writeln("\t\t// if(!form) {")
		g.server_main_cpp.writeln("\t\t//\t throw std::runtime_error(\"form not found `${s_util.gen_bind_class_name(obj_name2)}::From`\");")
		g.server_main_cpp.writeln("\t\t// }")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\t\treturn ${s_util.gen_convert_to_napivalue(g.table, obj_type, "VarValue(form.ToGameObject())")};")
	*/
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("\tcatch(std::exception& e) {")
		g.server_main_cpp.writeln("\t\tspdlog::error((std::string)e.what());")
		g.server_main_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("\treturn info.Env().Undefined();")
		g.server_main_cpp.writeln("};")

		g.server_main_cpp.writeln("")

		g.server_main_cpp.writeln("bool ${s_util.gen_bind_class_name(obj_name2)}::IsInstance(const Napi::Value& value)")
		g.server_main_cpp.writeln("{")
		g.server_main_cpp.writeln("\tif (!value.IsObject())")
		g.server_main_cpp.writeln("\t{")
		g.server_main_cpp.writeln("\t\treturn false;")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("\tNapi::Object obj = value.As<Napi::Object>();")
		g.server_main_cpp.writeln("\treturn obj.InstanceOf(${s_util.gen_ctor_name(obj_name2)}.Value());")
		g.server_main_cpp.writeln("};")

		g.server_main_cpp.writeln("")

		g.server_main_cpp.writeln("VarValue ${s_util.gen_bind_class_name(obj_name2)}::ToVMValue(const Napi::Value& value)")
		g.server_main_cpp.writeln("{")
		g.server_main_cpp.writeln("\tif (!IsInstance(value))")
		g.server_main_cpp.writeln("\t{")
		g.server_main_cpp.writeln("\t\treturn VarValue::None();")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("\tNapi::Object obj = value.As<Napi::Object>();")
		g.server_main_cpp.writeln("\t${s_util.gen_bind_class_name(obj_name2)}* wrapper = Napi::ObjectWrap<${s_util.gen_bind_class_name(obj_name2)}>::Unwrap(obj);")
		g.server_main_cpp.writeln("\treturn wrapper->self;")
		g.server_main_cpp.writeln("};")
		
		g.server_main_cpp.writeln("")

		g.server_main_cpp.writeln("Napi::Value ${s_util.gen_bind_class_name(obj_name2)}::ToNapiValue(Napi::Env env, const VarValue& self)")
		g.server_main_cpp.writeln("{")
		g.server_main_cpp.writeln("\tif (self.GetType() != VarValue::Type::kType_Object || !self)")
		g.server_main_cpp.writeln("\t{")
		g.server_main_cpp.writeln("\t\t//todo error invalid self")
		g.server_main_cpp.writeln("\t\treturn env.Null();")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("\t// Создаем новый экземпляр ${s_util.gen_bind_class_name(obj_name2)}")
		g.server_main_cpp.writeln("\tNapi::EscapableHandleScope scope(env);")
		g.server_main_cpp.writeln("\tNapi::Function ctor = ${s_util.gen_ctor_name(obj_name2)}.Value();")
		g.server_main_cpp.writeln("\tNapi::Object instance = ctor.New({});")
		g.server_main_cpp.writeln("\t${s_util.gen_bind_class_name(obj_name2)}* wrapper = Napi::ObjectWrap<${s_util.gen_bind_class_name(obj_name2)}>::Unwrap(instance);")
		g.server_main_cpp.writeln("\tif (wrapper)")
		g.server_main_cpp.writeln("\t{")
		g.server_main_cpp.writeln("\t\twrapper->self = self;")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("\treturn scope.Escape(instance);")
		g.server_main_cpp.writeln("}")
	}
}

const server_main_cpp_file_start = 
"// !!! Generated automatically. Do not edit. !!!
#include \"__js_bindings.h\"
#include \"PartOne.h\"
#include \"script_objects/EspmGameObject.h\"

#ifdef GetForm
#undef GetForm
#endif

extern std::shared_ptr<PartOne> g_partOne;

namespace JSBinding {

std::optional<VarValue> LookupForm(int32_t formId)
{
	const std::shared_ptr<MpForm>& pForm = g_partOne->worldState.LookupFormById(formId);
	espm::LookupResult res = g_partOne->worldState.GetEspm().GetBrowser().LookupById(formId);

	if (!pForm && !res.rec)
	{
		return std::nullopt;
	}

	return pForm ? VarValue(pForm->ToGameObject()) : VarValue(std::make_shared<EspmGameObject>(res));
}
"

const server_main_cpp_file_end = 
"}; // end namespace JSBinding"