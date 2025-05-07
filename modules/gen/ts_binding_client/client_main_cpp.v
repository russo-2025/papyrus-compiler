module ts_binding_client

import papyrus.ast
import strings
import gen.ts_binding_client.client_util as c_util

fn (mut g Gen) gen_client_main_cpp_file() {
	g.b_main_client_cpp.writeln(client_main_cpp_start_file)

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		g.b_main_client_cpp.writeln("static Napi::FunctionReference ${c_util.gen_ctor_name(file.obj_name)};")
	})
	
	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		bind_class_name := c_util.gen_bind_class_name(sym.obj_name)
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("// ==================================================================================")
		g.b_main_client_cpp.writeln("// ==================================${bind_class_name}==============================")
		g.b_main_client_cpp.writeln("")

		g.each_all_this_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl) {
			g.gen_client_main_cpp_fn(sym, sym, func)
		})
		
		g.each_all_parent_fns(sym, fn[sym](mut g Gen, parent_sym &ast.TypeSymbol, func &ast.FnDecl) {
			g.gen_client_main_cpp_fn(sym, parent_sym, func)
		})

		g.gen_client_main_cpp_end_class(sym)
	})
	
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("void RegisterAllVMObjects(Napi::Env env, Napi::Object exports)")
	g.b_main_client_cpp.writeln("{")
	
	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		bind_class_name := c_util.gen_bind_class_name(sym.obj_name)
		g.main_register_func.writeln("\t${bind_class_name}::Init(env, exports);")
	})

	g.b_main_client_cpp.writeln(g.main_register_func.str())
	g.b_main_client_cpp.writeln("}")
	g.b_main_client_cpp.writeln("}; // end namespace JSBinding")
}

fn (mut g Gen) gen_client_main_cpp_fn(sym &ast.TypeSymbol, parent_sym &ast.TypeSymbol, func &ast.FnDecl) {
	// Init
	// constructor
	// destructor
	// From
	// IsInstance
	// ToImplValue
	// ToNapiValue

	js_class_name := c_util.gen_bind_class_name(sym.name)
	js_fn_name := c_util.gen_js_fn_name(func.name)

	g.b_main_client_cpp.writeln("Napi::Value ${js_class_name}::${js_fn_name}(const Napi::CallbackInfo& info)")
	g.b_main_client_cpp.writeln("{")
	g.b_main_client_cpp.writeln("\ttry")
	g.b_main_client_cpp.writeln("\t{")

	mut call_args_list := ""

	if !func.is_global {
		call_args_list += "self"

		if func.params.len >= 1 {
			call_args_list += ", "
		}
	}

	for i in 0..func.params.len {
		param := func.params[i]
		arg := "info[${i}]"
		param_impl_type_name := c_util.get_impl_type_name(g.table, g.client_impl_classes, param.typ)

		g.b_main_client_cpp.write_string("\t\t${param_impl_type_name} ${param.name} = ")

		if param.is_optional {
			default_value := match param.default_value {
				ast.NoneLiteral {
					"nullptr"
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

			g.b_main_client_cpp.writeln("${c_util.gen_convert_to_varvalue_optional(g.table, param.typ, arg, default_value, arg)};")
		}
		else {
			g.b_main_client_cpp.writeln("${c_util.gen_convert_to_varvalue(g.table, param.typ, arg)};")
		}

		call_args_list += param.name

		if i != func.params.len - 1 {
			call_args_list += ", "
		}
	}

	if !func.is_global {
		if func.params.len != 0 {
			g.b_main_client_cpp.writeln("")
		}

		g.b_main_client_cpp.writeln("\t\tif (!self)")
		g.b_main_client_cpp.writeln("\t\t{")
		g.b_main_client_cpp.writeln("\t\t\tERR_AND_THROW(\"invalid self in ${js_class_name}::${js_fn_name}\");")
		g.b_main_client_cpp.writeln("\t\t}")
		g.b_main_client_cpp.writeln("")
	}

	g.b_main_client_cpp.writeln("\t\tNapi::Env env = info.Env();")
	

	if func.return_type != ast.none_type {
		return_impl_type_name := c_util.get_impl_type_name(g.table, g.client_impl_classes, func.return_type)
		g.b_main_client_cpp.write_string("\t\t${return_impl_type_name} res = ")
	}
	else {
		g.b_main_client_cpp.write_string("\t\t")
	}

	if !func.is_global || func.params.len > 0 {
		call_args_list = ", " + call_args_list
	}

	if func.is_global {
		g.b_main_client_cpp.writeln("ThreadCommunicator::GetSingleton()->ExecuteGameFunctionInUpdate(${c_util.get_fn_impl_name(parent_sym.obj_name, func.name)}${call_args_list});")
	}
	else {
		g.b_main_client_cpp.writeln("ThreadCommunicator::GetSingleton()->ExecuteGameFunctionInUpdate(${c_util.get_fn_impl_name(parent_sym.obj_name, func.name)}${call_args_list});")
	}
	
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\t\treturn ${c_util.gen_convert_to_napivalue(g.table, func.return_type, "res")};")
	g.b_main_client_cpp.writeln("\t}")

	/*
		g.b_main_client_cpp.writeln("\t\t\tstd::string errMsg = \"Failed to cast to `${g.get_impl_obj_type_name(obj_type)}`\"")
		g.b_main_client_cpp.writeln("\t\t\tERR(errMsg);")
		g.b_main_client_cpp.writeln("\t\t\tNapi::Error err = Napi::Error::New(info.Env(), errMsg);")
		g.b_main_client_cpp.writeln("\t\t\terr.ThrowAsJavaScriptException();")
	*/
	g.b_main_client_cpp.writeln("\tcatch(Napi::Error& err) {")
	g.b_main_client_cpp.writeln("\t\tERR(err.what());")
	g.b_main_client_cpp.writeln("\t\tERR(\"trace: {}\", err.Get(\"stack\").ToString().Utf8Value());")
	
	g.b_main_client_cpp.writeln("\t\terr.ThrowAsJavaScriptException();")
	g.b_main_client_cpp.writeln("\t}")
	g.b_main_client_cpp.writeln("\tcatch(std::exception& e) {")
	g.b_main_client_cpp.writeln("\t\tERR(e.what());")
	g.b_main_client_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
	g.b_main_client_cpp.writeln("\t}")
	g.b_main_client_cpp.writeln("\treturn info.Env().Undefined();")
	g.b_main_client_cpp.writeln("}")
	g.b_main_client_cpp.writeln("")
}

fn (mut g Gen) gen_client_main_cpp_end_class(sym &ast.TypeSymbol) {
	obj_type := g.table.find_type_idx(sym.name)
	impl_type_name := c_util.get_impl_type_name(g.table, g.client_impl_classes, obj_type)
	impl_obj_type_name := c_util.get_impl_obj_type_name(g.table, g.client_impl_classes, obj_type)
	bind_class_name := c_util.gen_bind_class_name(sym.name)

	mut init_methods_bind_cpp := strings.new_builder(300)
	mut init_methods_bind_cpp_ptr := &init_methods_bind_cpp

	g.each_all_fns(sym, fn[mut init_methods_bind_cpp_ptr, sym](mut g Gen, _ &ast.TypeSymbol, func &ast.FnDecl){
		js_class_name := c_util.gen_bind_class_name(sym.obj_name)
		js_fn_name := c_util.gen_js_fn_name(func.name)
		fn_name := func.name

		if func.is_global {
			init_methods_bind_cpp_ptr.write_string("\t\tStaticMethod(\"${fn_name}\", &${js_class_name}::${js_fn_name})")
		}
		else {
			init_methods_bind_cpp_ptr.write_string("\t\tInstanceMethod(\"${fn_name}\", &${js_class_name}::${js_fn_name})")
		}
		
		init_methods_bind_cpp_ptr.write_string(",\n")
	})
	
	if init_methods_bind_cpp.len > 0 {
		init_methods_bind_cpp.go_back(",\n".len) // remove last `,` + `\n`
	}

	g.b_main_client_cpp.writeln("Napi::Object ${bind_class_name}::Init(Napi::Env env, Napi::Object exports)")
	g.b_main_client_cpp.writeln("{")

	g.b_main_client_cpp.writeln("\tNapi::HandleScope scope(env);")
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\tNapi::Function func = DefineClass(env, \"${sym.name}\", {")

	if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
		g.b_main_client_cpp.writeln("\t\tStaticMethod(\"From\", &${bind_class_name}::From),")
		g.b_main_client_cpp.write_string("\t\tInstanceMethod(\"As\", &${bind_class_name}::As)")
		if init_methods_bind_cpp.len != 0 {
			g.b_main_client_cpp.writeln(",")
		}
		else {
			g.b_main_client_cpp.writeln("")
		}
	}
	g.b_main_client_cpp.writeln("${init_methods_bind_cpp.str()}")
	g.b_main_client_cpp.writeln("\t});")
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\t${c_util.gen_ctor_name(sym.name)} = Napi::Persistent(func);")
	g.b_main_client_cpp.writeln("\t${c_util.gen_ctor_name(sym.name)}.SuppressDestruct();")
	g.b_main_client_cpp.writeln("\texports.Set(\"${sym.name}\", func);")
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\treturn exports;")
	g.b_main_client_cpp.writeln("}")

	g.b_main_client_cpp.writeln("")
	
	g.b_main_client_cpp.write_string("${bind_class_name}::${bind_class_name}(const Napi::CallbackInfo& info) : ObjectWrap(info)")

	g.b_main_client_cpp.writeln("{")
	g.b_main_client_cpp.writeln("}")

	g.b_main_client_cpp.writeln("")
	
	if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
		g.b_main_client_cpp.writeln("Napi::Value ${bind_class_name}::From(const Napi::CallbackInfo& info)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\ttry")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tuint32_t formId = NapiHelper::ExtractUInt32(info[0], \"formId\");")
		g.b_main_client_cpp.writeln("\t\t${impl_type_name} obj = RE::TESForm::LookupByID<${impl_obj_type_name}>(formId);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t\tif(!obj) {")
		g.b_main_client_cpp.writeln("\t\t\treturn info.Env().Null();")
		g.b_main_client_cpp.writeln("\t\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t\treturn ${c_util.gen_convert_to_napivalue(g.table, obj_type, "obj")};")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\tcatch(std::exception& e) {")
		g.b_main_client_cpp.writeln("\t\tERR((std::string)e.what());")
		g.b_main_client_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\treturn info.Env().Null();")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		g.b_main_client_cpp.writeln("Napi::Value ${bind_class_name}::As(const Napi::CallbackInfo& info)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\ttry")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tif(!${bind_class_name}::IsInstance(this->Value()))")
		g.b_main_client_cpp.writeln("\t\t{")
		g.b_main_client_cpp.writeln("\t\t\treturn info.Env().Null();")
		g.b_main_client_cpp.writeln("\t\t}")
		g.b_main_client_cpp.writeln("\t\tNapi::Value class_ctor = info[0];")
		g.each_all_parent(sym, fn(mut g Gen, file &ast.File, idx ast.Type, sym &ast.TypeSymbol) {
			cur_bind_class_name := c_util.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\t\tif(class_ctor == ${c_util.gen_ctor_name(sym.name)}.Value())")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\treturn ${cur_bind_class_name}::ToNapiValue(info.Env(), this->self->As<${c_util.get_impl_obj_type_name(g.table, g.client_impl_classes, idx)}>());")
			g.b_main_client_cpp.writeln("\t\t}")
		})
		g.each_all_child(obj_type, fn(mut g Gen, idx ast.Type, sym &ast.TypeSymbol){
			cur_bind_class_name := c_util.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\t\tif(class_ctor == ${c_util.gen_ctor_name(sym.name)}.Value())")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\treturn ${cur_bind_class_name}::ToNapiValue(info.Env(), this->self->As<${c_util.get_impl_obj_type_name(g.table, g.client_impl_classes, idx)}>());")
			g.b_main_client_cpp.writeln("\t\t}")
		})
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\tcatch(std::exception& e)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tERR((std::string)e.what());")
		g.b_main_client_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\treturn info.Env().Null();")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		g.b_main_client_cpp.writeln("${impl_type_name} ${bind_class_name}::Cast(const Napi::Value& value)")
		g.b_main_client_cpp.writeln("{")
		g.each_all_parent(sym, fn[impl_type_name, impl_obj_type_name](mut g Gen, file &ast.File, idx ast.Type, sym &ast.TypeSymbol) {
			cur_bind_class_name := c_util.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\tif(${cur_bind_class_name}::IsInstance(value))")
			g.b_main_client_cpp.writeln("\t{")
			g.b_main_client_cpp.writeln("\t\tNapi::Object obj = value.As<Napi::Object>();")
			g.b_main_client_cpp.writeln("\t\t${cur_bind_class_name}* wrapper = Napi::ObjectWrap<${cur_bind_class_name}>::Unwrap(obj);")
			g.b_main_client_cpp.writeln("\t\t${impl_type_name} res = wrapper->self->As<${impl_obj_type_name}>();")
			g.b_main_client_cpp.writeln("\t\tif (!res)")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\tstd::string errMsg = \"Failed to cast to `${impl_obj_type_name}`\";")
			g.b_main_client_cpp.writeln("\t\t\tERR(errMsg);")
			g.b_main_client_cpp.writeln("\t\t\tthrow Napi::Error::New(value.Env(), errMsg);")
			g.b_main_client_cpp.writeln("\t\t}")
			g.b_main_client_cpp.writeln("\t\treturn res;")
			g.b_main_client_cpp.writeln("\t}")
		})
		g.each_all_child(obj_type, fn[impl_type_name, impl_obj_type_name](mut g Gen, idx ast.Type, sym &ast.TypeSymbol){
			cur_bind_class_name := c_util.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\tif(${cur_bind_class_name}::IsInstance(value))")
			g.b_main_client_cpp.writeln("\t{")
			g.b_main_client_cpp.writeln("\t\tNapi::Object obj = value.As<Napi::Object>();")
			g.b_main_client_cpp.writeln("\t\t${cur_bind_class_name}* wrapper = Napi::ObjectWrap<${cur_bind_class_name}>::Unwrap(obj);")
			g.b_main_client_cpp.writeln("\t\t${impl_type_name} res = wrapper->self->As<${impl_obj_type_name}>();")
			g.b_main_client_cpp.writeln("\t\tif (!res)")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\tstd::string errMsg = \"Failed to cast to `${impl_obj_type_name}`\";")
			g.b_main_client_cpp.writeln("\t\t\tERR(errMsg);")
			g.b_main_client_cpp.writeln("\t\t\tthrow Napi::Error::New(value.Env(), errMsg);")
			g.b_main_client_cpp.writeln("\t\t}")
			g.b_main_client_cpp.writeln("\t\treturn res;")
			g.b_main_client_cpp.writeln("\t}")
		})

		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\treturn nullptr;")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		g.b_main_client_cpp.writeln("bool ${bind_class_name}::IsInstance(const Napi::Value& value)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tif (!value.IsObject())")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\treturn false;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\tNapi::Object obj = value.As<Napi::Object>();")
		g.b_main_client_cpp.writeln("\treturn obj.InstanceOf(${c_util.gen_ctor_name(sym.name)}.Value());")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		g.b_main_client_cpp.writeln("${impl_type_name} ${bind_class_name}::ToImplValue(const Napi::Value& value)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tif (IsInstance(value))")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tNapi::Object obj = value.As<Napi::Object>();")
		g.b_main_client_cpp.writeln("\t\t${bind_class_name}* wrapper = Napi::ObjectWrap<${bind_class_name}>::Unwrap(obj);")
		g.b_main_client_cpp.writeln("\t\treturn wrapper->self;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t${impl_type_name} res = Cast(value);")
		g.b_main_client_cpp.writeln("\tif(!res)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tERR(\"invalid cast in (${bind_class_name}::ToImplValue)\");")
		g.b_main_client_cpp.writeln("\t\tthrow Napi::Error::New(value.Env(), std::string(\"invalid cast in (${bind_class_name}::ToImplValue)\"));")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\treturn res;")
		g.b_main_client_cpp.writeln("}")
		
		g.b_main_client_cpp.writeln("")

		g.b_main_client_cpp.writeln("Napi::Value ${bind_class_name}::ToNapiValue(Napi::Env env, ${impl_type_name} self)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tif (!self)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tERR(\"invalid object in cast (${bind_class_name}::ToNapiValue)\")")
		g.b_main_client_cpp.writeln("\t\treturn env.Null();")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\t// Создаем новый экземпляр ${bind_class_name}")
		g.b_main_client_cpp.writeln("\tNapi::EscapableHandleScope scope(env);")
		g.b_main_client_cpp.writeln("\tNapi::Function ctor = ${c_util.gen_ctor_name(sym.name)}.Value();")
		g.b_main_client_cpp.writeln("\tNapi::Object instance = ctor.New({});")
		g.b_main_client_cpp.writeln("\t${bind_class_name}* wrapper = Napi::ObjectWrap<${bind_class_name}>::Unwrap(instance);")
		g.b_main_client_cpp.writeln("\tif (wrapper)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\twrapper->self = self;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\treturn scope.Escape(instance);")
		g.b_main_client_cpp.writeln("}")
	}
}

const client_main_cpp_start_file =  
"// !!! Generated automatically. Do not edit. !!!

#include \"__js_bindings.h\"
#include \"../ThreadCommunicator.h\"

#ifdef GetForm
#undef GetForm
#endif

namespace JSBinding {
"