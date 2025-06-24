module ts_binding

import papyrus.ast
import strings
import gen.ts_binding.server_util as s_util
import gen.ts_binding.client_util as c_util

fn (mut g Gen) gen_server_main_cpp_file() {
	g.server_main_cpp.writeln(server_main_cpp_file_start)

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		g.server_main_cpp.writeln("static v8::Persistent<v8::Function> ${s_util.gen_ctor_name(file.obj_name)};")
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

	g.server_main_cpp.writeln("void RegisterAllVMObjects(v8::Isolate* isolate, v8::Local<v8::Object> exports)")
	g.server_main_cpp.writeln("{")
	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		bind_class_name := s_util.gen_bind_class_name(sym.name)
		g.server_main_cpp.writeln("\t${bind_class_name}::Init(isolate, exports);")
	})

	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\tRegisterSpSnippet(isolate, exports);")
	g.server_main_cpp.writeln("}")

	g.server_main_cpp.writeln(server_main_cpp_file_end)
}

fn (mut g Gen) gen_server_main_cpp_fn(sym &ast.TypeSymbol, parent_sym &ast.TypeSymbol, func &ast.FnDecl) {
	js_class_name := s_util.gen_bind_class_name(sym.name)
	js_fn_name := s_util.gen_js_fn_name(func.name)

	g.server_main_cpp.writeln("void ${js_class_name}::${js_fn_name}(const v8::FunctionCallbackInfo<v8::Value>& info)")
	g.server_main_cpp.writeln("{")
	g.server_main_cpp.writeln("\ttry")
	g.server_main_cpp.writeln("\t{")

	g.server_main_cpp.writeln("\t\tv8::Isolate* isolate = info.GetIsolate();")
	g.server_main_cpp.writeln("\t\tv8::HandleScope scope(isolate);")
	g.server_main_cpp.writeln("")

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
		g.server_main_cpp.writeln("\t\tVarValue self = ${js_class_name}::UnwrapSelf(isolate, info.This());")
		g.server_main_cpp.writeln("\t\tif (!self || self.GetType() != VarValue::Type::kType_Object)")
		g.server_main_cpp.writeln("\t\t{")
		g.server_main_cpp.writeln("\t\t\tERR_AND_THROW(\"invalid self in ${js_class_name}::${js_fn_name}\");")
		g.server_main_cpp.writeln("\t\t}")
		g.server_main_cpp.writeln("")
	}
	
	if func.is_global {
		g.server_main_cpp.writeln("\t\tVarValue res = ${s_util.gen_vm_fn_impl_name(parent_sym.obj_name, func.name)}(VarValue::None(), args);")
	}
	else {
		g.server_main_cpp.writeln("\t\tVarValue res = ${s_util.gen_vm_fn_impl_name(parent_sym.obj_name, func.name)}(self, args);")
	}
	
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\t\tinfo.GetReturnValue().Set(${s_util.gen_convert_to_napivalue(g.table, func.return_type, "res")});")
	g.server_main_cpp.writeln("\t\treturn;")
	g.server_main_cpp.writeln("\t}")
	g.server_main_cpp.writeln("\tcatch(std::exception& e) {")
	g.server_main_cpp.writeln("\t\tstd::string msg = e.what();")
	g.server_main_cpp.writeln("\t\tERR(msg);")
	g.server_main_cpp.writeln("\t\tinfo.GetIsolate()->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(info.GetIsolate(), msg.c_str()).ToLocalChecked()));")
	g.server_main_cpp.writeln("\t\treturn;")
	g.server_main_cpp.writeln("\t}")
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
	
	bind_class_name := c_util.gen_bind_class_name(sym.name)
	
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

	g.server_main_cpp.writeln("void ${s_util.gen_bind_class_name(obj_name2)}::Init(v8::Isolate* isolate, v8::Local<v8::Object> exports)")
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

	g.server_main_cpp.writeln("\tv8::HandleScope scope(isolate);")
	g.server_main_cpp.writeln("\tv8::Local<v8::Context> context = isolate->GetCurrentContext();")
	g.server_main_cpp.writeln("")
	if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
		g.server_main_cpp.writeln("\tv8::Local<v8::FunctionTemplate> tpl = v8::FunctionTemplate::New(isolate, ${bind_class_name}::Сtor);")
	}
	else {
		g.server_main_cpp.writeln("\tv8::Local<v8::FunctionTemplate> tpl = v8::FunctionTemplate::New(isolate);")
	}
	g.server_main_cpp.writeln("\ttpl->SetClassName(v8CString(\"${sym.name}\"));")
	g.server_main_cpp.writeln("\ttpl->InstanceTemplate()->SetInternalFieldCount(1);")
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\tv8::Local<v8::ObjectTemplate> prototype = tpl->PrototypeTemplate();")
	g.server_main_cpp.writeln("\t// set methods")

	g.each_all_fns(sym, fn[sym](mut g Gen, _ &ast.TypeSymbol, func &ast.FnDecl) {
		assert func.is_native
		
		if func.is_global {
			return
		}

		js_class_name := c_util.gen_bind_class_name(sym.obj_name)
		js_fn_name := c_util.gen_js_fn_name(func.name)
		fn_name := func.name

		g.server_main_cpp.writeln("\tprototype->Set(v8CString(\"${fn_name}\"), v8::FunctionTemplate::New(isolate, ${js_class_name}::${js_fn_name}));")
	})

	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\tv8::Local<v8::Function> constructor = tpl->GetFunction(context).ToLocalChecked();")
	g.server_main_cpp.writeln("\t${c_util.gen_ctor_name(sym.name)}.Reset(isolate, constructor);")
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\t// set static methods")
	
	if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
		g.server_main_cpp.writeln("\tconstructor->Set(context, v8CString(\"From\"), v8::FunctionTemplate::New(isolate, ${bind_class_name}::From)->GetFunction(context).ToLocalChecked()).Check();")
	}

	g.each_all_fns(sym, fn[sym](mut g Gen, _ &ast.TypeSymbol, func &ast.FnDecl) {
		assert func.is_native
		
		if !func.is_global {
			return
		}

		js_class_name := c_util.gen_bind_class_name(sym.obj_name)
		js_fn_name := c_util.gen_js_fn_name(func.name)
		fn_name := func.name

		g.server_main_cpp.writeln("\tconstructor->Set(context, v8::String::NewFromUtf8(isolate, \"${fn_name}\").ToLocalChecked(), v8::FunctionTemplate::New(isolate, ${js_class_name}::${js_fn_name})->GetFunction(context).ToLocalChecked()).Check();")
	})

	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\t// set constructor")
	g.server_main_cpp.writeln("\texports->Set(context, v8::String::NewFromUtf8(isolate, \"${sym.name}\").ToLocalChecked(), constructor).Check();")
	g.server_main_cpp.writeln("};")

	g.server_main_cpp.writeln("")

	if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
		g.server_main_cpp.writeln("void ${bind_class_name}::Сtor(const v8::FunctionCallbackInfo<v8::Value>& args)")
		g.server_main_cpp.writeln("{")
		g.server_main_cpp.writeln("\tv8::Isolate* isolate = args.GetIsolate();")
		g.server_main_cpp.writeln("\tv8::HandleScope scope(isolate);")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tDEBUG_ASSERT(isolate);")
		g.server_main_cpp.writeln("\tDEBUG_ASSERT(!isolate->GetCurrentContext().IsEmpty());")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\ttry")
		g.server_main_cpp.writeln("\t{")
		g.server_main_cpp.writeln("\t\tif (args.IsConstructCall())")
		g.server_main_cpp.writeln("\t\t{")
		g.server_main_cpp.writeln("\t\t\targs.This()->SetAlignedPointerInInternalField(0, nullptr);")
		g.server_main_cpp.writeln("\t\t\targs.GetReturnValue().Set(args.This());")
		g.server_main_cpp.writeln("\t\t\treturn;")
		g.server_main_cpp.writeln("\t\t}")
		g.server_main_cpp.writeln("\t\telse")
		g.server_main_cpp.writeln("\t\t{")
        g.server_main_cpp.writeln("\t\t\tv8::Local<v8::Context> context = isolate->GetCurrentContext();")
        g.server_main_cpp.writeln("\t\t\tv8::Local<v8::Function> ctor = v8::Local<v8::Function>::New(isolate, ${c_util.gen_ctor_name(sym.name)});")
        g.server_main_cpp.writeln("\t\t\tv8::Local<v8::Object> instance = ctor->NewInstance(context, 0, nullptr).ToLocalChecked();")
        g.server_main_cpp.writeln("\t\t\targs.GetReturnValue().Set(instance);")
		g.server_main_cpp.writeln("\t\t\treturn;")
		g.server_main_cpp.writeln("\t\t}")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("\tcatch(std::exception& e) {")
		g.server_main_cpp.writeln("\t\tstd::string msg = e.what();")
		g.server_main_cpp.writeln("\t\tERR(msg);")
		g.server_main_cpp.writeln("\t\targs.GetIsolate()->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(args.GetIsolate(), msg.c_str()).ToLocalChecked()));")
		g.server_main_cpp.writeln("\t\treturn;")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\targs.GetReturnValue().Set(v8::Null(args.GetIsolate()));")
		g.server_main_cpp.writeln("\treturn;")
		g.server_main_cpp.writeln("}")

		g.server_main_cpp.writeln("")

		g.server_main_cpp.writeln("void ${s_util.gen_bind_class_name(obj_name2)}::From(const v8::FunctionCallbackInfo<v8::Value>& info)")
		g.server_main_cpp.writeln("{")
		g.server_main_cpp.writeln("\ttry")
		g.server_main_cpp.writeln("\t{")
		g.server_main_cpp.writeln("\t\tv8::Isolate* isolate = info.GetIsolate();")
		g.server_main_cpp.writeln("\t\tv8::HandleScope scope(isolate);")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\t\tDEBUG_ASSERT(isolate);")
		g.server_main_cpp.writeln("\t\tDEBUG_ASSERT(!isolate->GetCurrentContext().IsEmpty());")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\t\tuint32_t formId = JsHelper::ExtractUInt32(isolate, info[0], \"formId\");")
		g.server_main_cpp.writeln("\t\tstd::optional<VarValue> form = LookupForm(formId);")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\t\tif (!form.has_value())")
		g.server_main_cpp.writeln("\t\t{")
		g.server_main_cpp.writeln("\t\t\tinfo.GetReturnValue().Set(v8::Null(isolate));")
		g.server_main_cpp.writeln("\t\t}")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\t\tinfo.GetReturnValue().Set(${s_util.gen_convert_to_napivalue(g.table, obj_type, "form.value()")});")
		g.server_main_cpp.writeln("\t\treturn;")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("\tcatch(std::exception& e) {")
		g.server_main_cpp.writeln("\t\tstd::string msg = e.what();")
		g.server_main_cpp.writeln("\t\tERR(msg);")
		g.server_main_cpp.writeln("\t\tinfo.GetIsolate()->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(info.GetIsolate(), msg.c_str()).ToLocalChecked()));")
		g.server_main_cpp.writeln("\t\treturn;")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tinfo.GetReturnValue().Set(v8::Null(info.GetIsolate()));")
		g.server_main_cpp.writeln("\treturn;")
		g.server_main_cpp.writeln("};")

		g.server_main_cpp.writeln("")

		g.server_main_cpp.writeln("VarValue ${s_util.gen_bind_class_name(obj_name2)}::UnwrapSelf(v8::Isolate* isolate, v8::Local<v8::Value> value)")
		g.server_main_cpp.writeln("{")
		g.server_main_cpp.writeln("\tv8::HandleScope handleScope(isolate);")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tDEBUG_ASSERT(isolate);")
		g.server_main_cpp.writeln("\tDEBUG_ASSERT(!isolate->GetCurrentContext().IsEmpty());")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tif (!value->IsObject())")
		g.server_main_cpp.writeln("\t{")
		g.server_main_cpp.writeln("\t\treturn VarValue::None();")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tauto obj = value.As<v8::Object>();")
		g.server_main_cpp.writeln("\tif (obj.IsEmpty() || obj->InternalFieldCount() <= 0)")
		g.server_main_cpp.writeln("\t{")
		g.server_main_cpp.writeln("\t\treturn VarValue::None();")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tSelfHolder* holder = static_cast<SelfHolder*>(obj->GetAlignedPointerFromInternalField(0));")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\treturn holder->self;")
		g.server_main_cpp.writeln("};")
		
		g.server_main_cpp.writeln("")

		g.server_main_cpp.writeln("v8::Local<v8::Value> ${s_util.gen_bind_class_name(obj_name2)}::Wrap(v8::Isolate* isolate, const VarValue& self)")
		g.server_main_cpp.writeln("{")
		g.server_main_cpp.writeln("\tv8::EscapableHandleScope scope(isolate);")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tDEBUG_ASSERT(isolate);")
		g.server_main_cpp.writeln("\tDEBUG_ASSERT(!isolate->GetCurrentContext().IsEmpty());")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tif (!self)")
		g.server_main_cpp.writeln("\t{")
		g.server_main_cpp.writeln("\t\tERR(\"${bind_class_name}::Wrap - self is nullptr\");")
		g.server_main_cpp.writeln("\t\treturn scope.Escape(v8::Null(isolate));")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tv8::Local<v8::Context> context = isolate->GetCurrentContext();")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tv8::Local<v8::Function> constructor = v8::Local<v8::Function>::New(isolate, ${s_util.gen_ctor_name(sym.name)});")
		g.server_main_cpp.writeln("\tv8::Local<v8::Object> instance = constructor->NewInstance(context, 0, nullptr).ToLocalChecked();")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tDEBUG_ASSERT(!instance.IsEmpty());")
		g.server_main_cpp.writeln("\tDEBUG_ASSERT(instance->InternalFieldCount() > 0);")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tSelfHolder* holder = new SelfHolder(isolate, self, instance);")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\tinstance->SetAlignedPointerInInternalField(0, holder);")
		g.server_main_cpp.writeln("")
		g.server_main_cpp.writeln("\treturn scope.Escape(instance);")
		g.server_main_cpp.writeln("}")
	}
}

const server_main_cpp_file_start = 
"// !!! Generated automatically. Do not edit. !!!
#include \"__js_bindings.h\"
#include \"__js_rpc_server_wrap_bindings.h\"
#include <PartOne.h>
#include <script_objects/EspmGameObject.h>
#include \"ScampServer.h\"

#ifdef GetForm
#undef GetForm
#endif

extern std::shared_ptr<PartOne> g_partOne;

namespace JSBinding {

struct SelfHolder {
    VarValue                  self;
    v8::Global<v8::Object>    js_handle;     // держит js-объект до колбэка

    SelfHolder(v8::Isolate* isolate,
               const VarValue& value,
               v8::Local<v8::Object> obj)
        : self(value), js_handle(isolate, obj)
    {
        //   kParameter → одностадийный вызов, колбэк получит this
        js_handle.SetWeak(this, WeakCallback,
                          v8::WeakCallbackType::kParameter);
    }

    ~SelfHolder() {                     // гарантировано вызывается из того же
        js_handle.Reset();              // изолята, «self» можно чистить
        /* …освобождаем VarValue, если нужно… */
    }

    static void WeakCallback(const v8::WeakCallbackInfo<SelfHolder>& info)
    {
        delete info.GetParameter();     // запускает ~SelfHolder()
    }
};

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