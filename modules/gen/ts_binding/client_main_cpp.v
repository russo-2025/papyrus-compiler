module ts_binding

import papyrus.ast
import gen.ts_binding.client_util as c_util

fn (mut g Gen) gen_client_main_cpp_file() {
	g.b_main_client_cpp.writeln(client_main_cpp_start_file)

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		g.b_main_client_cpp.writeln("static v8::Persistent<v8::Function> ${c_util.gen_ctor_name(file.obj_name)};")
	})
	
	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		bind_class_name := c_util.gen_bind_class_name(sym.obj_name)
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("// ==================================================================================")
		g.b_main_client_cpp.writeln("// ==================================${bind_class_name}==============================")
		g.b_main_client_cpp.writeln("")

		g.each_all_this_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl) {
			assert func.is_native
		
			g.gen_client_main_cpp_fn(sym, sym, func)
		})
		
		g.each_all_parent_fns(sym, fn[sym](mut g Gen, parent_sym &ast.TypeSymbol, func &ast.FnDecl) {
			assert func.is_native
		
			g.gen_client_main_cpp_fn(sym, parent_sym, func)
		})

		g.gen_client_main_cpp_end_class(sym)
	})
	
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("void RegisterAllVMObjects(v8::Isolate* isolate, v8::Local<v8::Object> exports)")
	g.b_main_client_cpp.writeln("{")
	
	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		bind_class_name := c_util.gen_bind_class_name(sym.obj_name)
		g.b_main_client_cpp.writeln("\t${bind_class_name}::Init(isolate, exports);")
	})

	g.b_main_client_cpp.writeln("}")
	g.b_main_client_cpp.writeln("}; // end namespace JSBinding")
}

fn (mut g Gen) gen_client_main_cpp_fn(sym &ast.TypeSymbol, parent_sym &ast.TypeSymbol, func &ast.FnDecl) {
	// Init
	// constructor
	// destructor
	// From
	// IsInstance
	// Unwrap
	// Wrap

	obj_type := g.table.find_type_idx(sym.name)
	js_class_name := c_util.gen_bind_class_name(sym.name)
	js_fn_name := c_util.gen_js_fn_name(func.name)
	impl_type_name := c_util.get_impl_type_name(g.table, g.client_impl_classes, obj_type)

	g.b_main_client_cpp.writeln("void ${js_class_name}::${js_fn_name}(const v8::FunctionCallbackInfo<v8::Value>& args)")
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

	g.b_main_client_cpp.writeln("\t\tv8::Isolate* isolate = args.GetIsolate();")
	g.b_main_client_cpp.writeln("\t\tv8::HandleScope scope(isolate);")
	
	if func.params.len != 0 {
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t\t// unwrap args")
	}

	for i in 0..func.params.len {
		param := func.params[i]
		arg := "args[${i}]"
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

	g.b_main_client_cpp.writeln("")
	
	if !func.is_global {
		g.b_main_client_cpp.writeln("\t\t${impl_type_name} self = ${js_class_name}::UnwrapSelf(isolate, args.This());")
		g.b_main_client_cpp.writeln("\t\tif(!self)")
		g.b_main_client_cpp.writeln("\t\t{")
		g.b_main_client_cpp.writeln("\t\t\tERR_AND_THROW(\"self is nullptr ${js_class_name}::${js_fn_name}\");")
		g.b_main_client_cpp.writeln("\t\t}")
		g.b_main_client_cpp.writeln("")
	}
	
	g.b_main_client_cpp.writeln("\t\t// call game func")

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
	g.b_main_client_cpp.writeln("\t\t// return value")
	g.b_main_client_cpp.writeln("\t\targs.GetReturnValue().Set(${c_util.gen_convert_to_napivalue(g.table, func.return_type, "res")});")
	g.b_main_client_cpp.writeln("\t}")

	g.b_main_client_cpp.writeln("\tcatch(std::exception& e) {")
	g.b_main_client_cpp.writeln("\t\tstd::string msg = e.what();")
	g.b_main_client_cpp.writeln("\t\tERR(msg);")
	g.b_main_client_cpp.writeln("\t\targs.GetIsolate()->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(args.GetIsolate(), msg.c_str()).ToLocalChecked()));")
	g.b_main_client_cpp.writeln("\t\treturn;")
	g.b_main_client_cpp.writeln("\t}")
	g.b_main_client_cpp.writeln("}")
	g.b_main_client_cpp.writeln("")
}

fn (mut g Gen) gen_client_main_cpp_end_class(sym &ast.TypeSymbol) {
	obj_type := g.table.find_type_idx(sym.name)
	impl_type_name := c_util.get_impl_type_name(g.table, g.client_impl_classes, obj_type)
	impl_obj_type_name := c_util.get_impl_obj_type_name(g.table, g.client_impl_classes, obj_type)
	bind_class_name := c_util.gen_bind_class_name(sym.name)

	g.b_main_client_cpp.writeln("void ${bind_class_name}::Init(v8::Isolate* isolate, v8::Local<v8::Object> exports)")
	g.b_main_client_cpp.writeln("{")
	g.b_main_client_cpp.writeln("\tv8::HandleScope scope(isolate);")
	g.b_main_client_cpp.writeln("\tv8::Local<v8::Context> context = isolate->GetCurrentContext();")
	g.b_main_client_cpp.writeln("")
	if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
		g.b_main_client_cpp.writeln("\tv8::Local<v8::FunctionTemplate> tpl = v8::FunctionTemplate::New(isolate, ${bind_class_name}::Сtor);")
	}
	else {
		g.b_main_client_cpp.writeln("\tv8::Local<v8::FunctionTemplate> tpl = v8::FunctionTemplate::New(isolate);")
	}
	g.b_main_client_cpp.writeln("\ttpl->SetClassName(v8::String::NewFromUtf8(isolate, \"${sym.name}\").ToLocalChecked());")
	g.b_main_client_cpp.writeln("\ttpl->InstanceTemplate()->SetInternalFieldCount(1);")
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\tv8::Local<v8::ObjectTemplate> prototype = tpl->PrototypeTemplate();")
	g.b_main_client_cpp.writeln("\t// set methods")
	
	if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
		g.b_main_client_cpp.writeln("\tprototype->Set(v8::String::NewFromUtf8(isolate, \"As\").ToLocalChecked(), v8::FunctionTemplate::New(isolate, ${bind_class_name}::As));")
	}

	g.each_all_fns(sym, fn[sym](mut g Gen, _ &ast.TypeSymbol, func &ast.FnDecl) {
		assert func.is_native
		
		if func.is_global {
			return
		}

		js_class_name := c_util.gen_bind_class_name(sym.obj_name)
		js_fn_name := c_util.gen_js_fn_name(func.name)
		fn_name := func.name

		g.b_main_client_cpp.writeln("\tprototype->Set(v8::String::NewFromUtf8(isolate, \"${fn_name}\").ToLocalChecked(), v8::FunctionTemplate::New(isolate, ${js_class_name}::${js_fn_name}));")
	})

	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\tv8::Local<v8::Function> constructor = tpl->GetFunction(context).ToLocalChecked();")
	g.b_main_client_cpp.writeln("\t${c_util.gen_ctor_name(sym.name)}.Reset(isolate, constructor);")
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\t// set static methods")
	
	if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
		g.b_main_client_cpp.writeln("\tconstructor->Set(context, v8::String::NewFromUtf8(isolate, \"From\").ToLocalChecked(), v8::FunctionTemplate::New(isolate, ${bind_class_name}::From)->GetFunction(context).ToLocalChecked()).Check();")
	}

	g.each_all_fns(sym, fn[sym](mut g Gen, _ &ast.TypeSymbol, func &ast.FnDecl) {
		assert func.is_native
		
		if !func.is_global {
			return
		}

		js_class_name := c_util.gen_bind_class_name(sym.obj_name)
		js_fn_name := c_util.gen_js_fn_name(func.name)
		fn_name := func.name

		g.b_main_client_cpp.writeln("\tconstructor->Set(context, v8::String::NewFromUtf8(isolate, \"${fn_name}\").ToLocalChecked(), v8::FunctionTemplate::New(isolate, ${js_class_name}::${js_fn_name})->GetFunction(context).ToLocalChecked()).Check();")
	})

	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\t// set constructor")
	g.b_main_client_cpp.writeln("\texports->Set(context, v8::String::NewFromUtf8(isolate, \"${sym.name}\").ToLocalChecked(), constructor).Check();")
	g.b_main_client_cpp.writeln("}")

	g.b_main_client_cpp.writeln("")
	
	if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {

		// CONSTRUCTOR
		g.b_main_client_cpp.writeln("void ${bind_class_name}::Сtor(const v8::FunctionCallbackInfo<v8::Value>& args)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tv8::Isolate* isolate = args.GetIsolate();")
		g.b_main_client_cpp.writeln("\tv8::HandleScope scope(isolate);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tsp_assert(isolate);")
		g.b_main_client_cpp.writeln("\tsp_assert(!isolate->GetCurrentContext().IsEmpty());")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\ttry")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tif (args.IsConstructCall())")
		g.b_main_client_cpp.writeln("\t\t{")
		g.b_main_client_cpp.writeln("\t\t\targs.This()->SetAlignedPointerInInternalField(0, nullptr);")
		g.b_main_client_cpp.writeln("\t\t\targs.GetReturnValue().Set(args.This());")
		g.b_main_client_cpp.writeln("\t\t\treturn;")
		g.b_main_client_cpp.writeln("\t\t}")
		g.b_main_client_cpp.writeln("\t\telse")
		g.b_main_client_cpp.writeln("\t\t{")
        g.b_main_client_cpp.writeln("\t\t\tv8::Local<v8::Context> context = isolate->GetCurrentContext();")
        g.b_main_client_cpp.writeln("\t\t\tv8::Local<v8::Function> ctor = v8::Local<v8::Function>::New(isolate, ${c_util.gen_ctor_name(sym.name)});")
        g.b_main_client_cpp.writeln("\t\t\tv8::Local<v8::Object> instance = ctor->NewInstance(context, 0, nullptr).ToLocalChecked();")
        g.b_main_client_cpp.writeln("\t\t\targs.GetReturnValue().Set(instance);")
		g.b_main_client_cpp.writeln("\t\t\treturn;")
		g.b_main_client_cpp.writeln("\t\t}")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\tcatch(std::exception& e) {")
		g.b_main_client_cpp.writeln("\t\tstd::string msg = e.what();")
		g.b_main_client_cpp.writeln("\t\tERR(msg);")
		g.b_main_client_cpp.writeln("\t\targs.GetIsolate()->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(args.GetIsolate(), msg.c_str()).ToLocalChecked()));")
		g.b_main_client_cpp.writeln("\t\treturn;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\targs.GetReturnValue().Set(v8::Null(args.GetIsolate()));")
		g.b_main_client_cpp.writeln("\treturn;")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		// FROM
		g.b_main_client_cpp.writeln("void ${bind_class_name}::From(const v8::FunctionCallbackInfo<v8::Value>& args)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\ttry")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tv8::Isolate* isolate = args.GetIsolate();")
		g.b_main_client_cpp.writeln("\t\tv8::HandleScope scope(isolate);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t\tsp_assert(isolate);")
		g.b_main_client_cpp.writeln("\t\tsp_assert(!isolate->GetCurrentContext().IsEmpty());")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t\tuint32_t formId = JsHelper::ExtractUInt32(isolate, args[0], \"formId\");")
		g.b_main_client_cpp.writeln("\t\t${impl_type_name} obj = RE::TESForm::LookupByID<${impl_obj_type_name}>(formId);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t\tif(!obj) {")
		g.b_main_client_cpp.writeln("\t\t\targs.GetReturnValue().Set(v8::Null(isolate));")
		g.b_main_client_cpp.writeln("\t\t\treturn;")
		g.b_main_client_cpp.writeln("\t\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t\targs.GetReturnValue().Set(${c_util.gen_convert_to_napivalue(g.table, obj_type, "obj")});")
		g.b_main_client_cpp.writeln("\t\treturn;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\tcatch(std::exception& e) {")
		g.b_main_client_cpp.writeln("\t\tstd::string msg = e.what();")
		g.b_main_client_cpp.writeln("\t\tERR(msg);")
		g.b_main_client_cpp.writeln("\t\targs.GetIsolate()->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(args.GetIsolate(), msg.c_str()).ToLocalChecked()));")
		g.b_main_client_cpp.writeln("\t\treturn;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\targs.GetReturnValue().Set(v8::Null(args.GetIsolate()));")
		g.b_main_client_cpp.writeln("\treturn;")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		// AS

		g.b_main_client_cpp.writeln("void ${bind_class_name}::As(const v8::FunctionCallbackInfo<v8::Value>& args)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tv8::Isolate* isolate = args.GetIsolate();")
		g.b_main_client_cpp.writeln("\tv8::HandleScope scope(isolate);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tsp_assert(isolate);")
		g.b_main_client_cpp.writeln("\tsp_assert(!isolate->GetCurrentContext().IsEmpty());")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\ttry")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\t${impl_type_name} self = ${bind_class_name}::UnwrapSelf(isolate, args.This());")
		g.b_main_client_cpp.writeln("\t\tif(!self)")
		g.b_main_client_cpp.writeln("\t\t{")
		g.b_main_client_cpp.writeln("\t\t\targs.GetReturnValue().Set(v8::Null(isolate));")
		g.b_main_client_cpp.writeln("\t\t\treturn;")
		g.b_main_client_cpp.writeln("\t\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t\tauto class_ctor = args[0];")
		g.each_all_parent(sym, fn(mut g Gen, file &ast.File, idx ast.Type, sym &ast.TypeSymbol) {
			cur_bind_class_name := c_util.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\t\tif(class_ctor == ${c_util.gen_ctor_name(sym.name)})")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\targs.GetReturnValue().Set(${cur_bind_class_name}::Wrap(isolate, self->As<${c_util.get_impl_obj_type_name(g.table, g.client_impl_classes, idx)}>()));")
			g.b_main_client_cpp.writeln("\t\t\treturn;")
			g.b_main_client_cpp.writeln("\t\t}")
		})
		g.each_all_child(obj_type, fn(mut g Gen, idx ast.Type, sym &ast.TypeSymbol){
			cur_bind_class_name := c_util.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\t\tif(class_ctor == ${c_util.gen_ctor_name(sym.name)})")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\targs.GetReturnValue().Set(${cur_bind_class_name}::Wrap(isolate, self->As<${c_util.get_impl_obj_type_name(g.table, g.client_impl_classes, idx)}>()));")
			g.b_main_client_cpp.writeln("\t\t\treturn;")
			g.b_main_client_cpp.writeln("\t\t}")
		})
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\tcatch(std::exception& e)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tstd::string msg = e.what();")
		g.b_main_client_cpp.writeln("\t\tERR(msg);")
		g.b_main_client_cpp.writeln("\t\targs.GetIsolate()->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(args.GetIsolate(), msg.c_str()).ToLocalChecked()));")
		g.b_main_client_cpp.writeln("\t\treturn;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\targs.GetReturnValue().Set(v8::Null(isolate));")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")


		// CAST

		g.b_main_client_cpp.writeln("${impl_type_name} ${bind_class_name}::Cast(v8::Isolate* isolate, v8::Local<v8::Value> value)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tv8::HandleScope scope(isolate);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tsp_assert(isolate);")
		g.b_main_client_cpp.writeln("\tsp_assert(!isolate->GetCurrentContext().IsEmpty());")
		g.b_main_client_cpp.writeln("")

		g.each_all_parent(sym, fn[impl_type_name, impl_obj_type_name](mut g Gen, file &ast.File, idx ast.Type, sym &ast.TypeSymbol) {
			cur_bind_class_name := c_util.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\tif(${cur_bind_class_name}::IsInstance(isolate, value));")
			g.b_main_client_cpp.writeln("\t{")
			g.b_main_client_cpp.writeln("\t\t${c_util.get_impl_obj_type_name(g.table, g.client_impl_classes, idx)}* object = ${cur_bind_class_name}::Unwrap(isolate, value);")
			g.b_main_client_cpp.writeln("")
			g.b_main_client_cpp.writeln("\t\tif (!object)")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\tstd::string msg = \"object is nullptr`\";")
			g.b_main_client_cpp.writeln("\t\t\tERR(msg);")
			g.b_main_client_cpp.writeln("\t\t\tisolate->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(isolate, msg.c_str()).ToLocalChecked()));")
			g.b_main_client_cpp.writeln("\t\t\treturn nullptr;")
			g.b_main_client_cpp.writeln("\t\t}")
			g.b_main_client_cpp.writeln("")
			g.b_main_client_cpp.writeln("\t\t${impl_type_name} res = object->As<${impl_obj_type_name}>();")
			g.b_main_client_cpp.writeln("\t\tif (!res)")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\tstd::string msg = \"Failed to cast to `${impl_obj_type_name}`\";")
			g.b_main_client_cpp.writeln("\t\t\tERR(msg);")
			g.b_main_client_cpp.writeln("\t\t\tisolate->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(isolate, msg.c_str()).ToLocalChecked()));")
			g.b_main_client_cpp.writeln("\t\t\treturn nullptr;")
			g.b_main_client_cpp.writeln("\t\t}")
			g.b_main_client_cpp.writeln("\t\treturn res;")
			g.b_main_client_cpp.writeln("\t}")
		})
		g.each_all_child(obj_type, fn[impl_type_name, impl_obj_type_name](mut g Gen, idx ast.Type, sym &ast.TypeSymbol){
			cur_bind_class_name := c_util.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\tif(${cur_bind_class_name}::IsInstance(isolate, value));")
			g.b_main_client_cpp.writeln("\t{")
			g.b_main_client_cpp.writeln("\t\t${c_util.get_impl_obj_type_name(g.table, g.client_impl_classes, idx)}* object = ${cur_bind_class_name}::Unwrap(isolate, value);")
			g.b_main_client_cpp.writeln("")
			g.b_main_client_cpp.writeln("\t\tif (!object)")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\tstd::string msg = \"object is nullptr`\";")
			g.b_main_client_cpp.writeln("\t\t\tERR(msg);")
			g.b_main_client_cpp.writeln("\t\t\tisolate->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(isolate, msg.c_str()).ToLocalChecked()));")
			g.b_main_client_cpp.writeln("\t\t\treturn nullptr;")
			g.b_main_client_cpp.writeln("\t\t}")
			g.b_main_client_cpp.writeln("")
			g.b_main_client_cpp.writeln("\t\t${impl_type_name} res = object->As<${impl_obj_type_name}>();")
			g.b_main_client_cpp.writeln("\t\tif (!res)")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\tstd::string msg = \"Failed to cast to `${impl_obj_type_name}`\";")
			g.b_main_client_cpp.writeln("\t\t\tERR(msg);")
			g.b_main_client_cpp.writeln("\t\t\tisolate->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(isolate, msg.c_str()).ToLocalChecked()));")
			g.b_main_client_cpp.writeln("\t\t\treturn nullptr;")
			g.b_main_client_cpp.writeln("\t\t}")
			g.b_main_client_cpp.writeln("\t\treturn res;")
			g.b_main_client_cpp.writeln("\t}")
		})

		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\treturn nullptr;")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		// IsInstance

		g.b_main_client_cpp.writeln("bool ${bind_class_name}::IsInstance(v8::Isolate* isolate, v8::Local<v8::Value> value)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tv8::HandleScope handleScope(isolate);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tsp_assert(isolate);")
		g.b_main_client_cpp.writeln("\tsp_assert(!isolate->GetCurrentContext().IsEmpty());")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tif (!value->IsObject())")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\treturn false;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tauto obj = value.As<v8::Object>();")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tif (obj->InternalFieldCount() < 1)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\treturn false;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tv8::Local<v8::Context> context = isolate->GetCurrentContext();")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tv8::Local<v8::Function> cons = ${c_util.gen_ctor_name(sym.name)}.Get(isolate);")
		g.b_main_client_cpp.writeln("\tv8::Maybe<bool> result = obj->InstanceOf(context, cons);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tif(!result.IsNothing() && result.FromJust())")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tvoid* ptr = obj->GetAlignedPointerFromInternalField(0);")
		g.b_main_client_cpp.writeln("\t\treturn ptr != nullptr;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\treturn false;")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		// Unwrap

		g.b_main_client_cpp.writeln("${impl_type_name} ${bind_class_name}::Unwrap(v8::Isolate* isolate, v8::Local<v8::Value> value)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tv8::HandleScope handleScope(isolate);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tsp_assert(isolate);")
		g.b_main_client_cpp.writeln("\tsp_assert(!isolate->GetCurrentContext().IsEmpty());")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tif (IsInstance(isolate, value))")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tauto obj = value.As<v8::Object>();")
		g.b_main_client_cpp.writeln("\t\t${impl_type_name} self = static_cast<${impl_type_name}>(obj->GetAlignedPointerFromInternalField(0));")
		g.b_main_client_cpp.writeln("\t\treturn self;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t${impl_type_name} res = Cast(isolate, value);")
		g.b_main_client_cpp.writeln("\tif(!res)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tERR_AND_THROW(\"invalid cast in (${bind_class_name}::Unwrap)\");")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\treturn res;")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		// UnwrapSelf

		g.b_main_client_cpp.writeln("${impl_type_name} ${bind_class_name}::UnwrapSelf(v8::Isolate* isolate, v8::Local<v8::Value> value)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tv8::HandleScope handleScope(isolate);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tsp_assert(isolate);")
		g.b_main_client_cpp.writeln("\tsp_assert(!isolate->GetCurrentContext().IsEmpty());")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tif (!value->IsObject())")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\treturn nullptr;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tauto obj = value.As<v8::Object>();")
		g.b_main_client_cpp.writeln("\tif (obj.IsEmpty() || obj->InternalFieldCount() <= 0)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\treturn nullptr;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\treturn static_cast<${impl_type_name}>(obj->GetAlignedPointerFromInternalField(0));")
		g.b_main_client_cpp.writeln("}")
		
		g.b_main_client_cpp.writeln("")

		// Wrap

		g.b_main_client_cpp.writeln("v8::Local<v8::Value> ${bind_class_name}::Wrap(v8::Isolate* isolate, ${impl_type_name} self)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tv8::EscapableHandleScope scope(isolate);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tsp_assert(isolate);")
		g.b_main_client_cpp.writeln("\tsp_assert(!isolate->GetCurrentContext().IsEmpty());")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tif (!self)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tERR(\"${bind_class_name}::Wrap - self is nullptr\");")
		g.b_main_client_cpp.writeln("\t\treturn scope.Escape(v8::Null(isolate));")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tv8::Local<v8::Context> context = isolate->GetCurrentContext();")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tv8::Local<v8::Function> constructor = v8::Local<v8::Function>::New(isolate, ${c_util.gen_ctor_name(sym.name)});")
		g.b_main_client_cpp.writeln("\tv8::Local<v8::Object> instance = constructor->NewInstance(context, 0, nullptr).ToLocalChecked();")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tsp_assert(!instance.IsEmpty());")
		g.b_main_client_cpp.writeln("\tsp_assert(instance->InternalFieldCount() > 0);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\tinstance->SetAlignedPointerInInternalField(0, self);")
		g.b_main_client_cpp.writeln("")
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