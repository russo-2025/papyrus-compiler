module ts_binding_client

import papyrus.ast

fn (mut g Gen) gen(file &ast.File) {
	//impl_class_name := g.gen_impl_class_name(g.obj_name)
	bind_class_name := g.gen_bind_class_name(g.obj_name)

	// ============== generate h js bind =======================

	g.b_main_client_h.writeln("class ${bind_class_name} : public Napi::ObjectWrap<${bind_class_name}> {")
	g.b_main_client_h.writeln("public:")
	g.b_main_client_h.writeln("\tstatic Napi::Object Init(Napi::Env env, Napi::Object exports);")
	g.b_main_client_h.writeln("\t${bind_class_name}(const Napi::CallbackInfo& info);")
	g.b_main_client_h.writeln("\t~${bind_class_name}() {};")
	g.b_main_client_h.writeln("")
	g.b_main_client_h.writeln("\t// wrappers")
	if !g.is_no_instance_class(g.obj_type) {
		g.b_main_client_h.writeln("\tstatic Napi::Value From(const Napi::CallbackInfo& info);")
		g.b_main_client_h.writeln("\tNapi::Value As(const Napi::CallbackInfo& info);")
	}

	// ============== generate cpp js bind =======================

	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("// ==================================================================================")
	g.b_main_client_cpp.writeln("// ==================================${bind_class_name}==============================")
	g.b_main_client_cpp.writeln("")

	// ============== generate ts headers =====================
	
	if g.sym.parent_idx == 0 {
		g.b_main_client_ts.writeln("\tclass ${g.obj_name} {")
	}
	else {
		g.b_main_client_ts.writeln("\tclass ${g.obj_name} extends ${g.parent_obj_name} {")
	}
	
	if !g.is_no_instance_class(g.obj_type){
		g.b_main_client_ts.writeln("\t\tstatic From(formId: number): ${g.obj_name} | null")
		g.b_main_client_ts.writeln("\t\tAs<T>(object: any): T | null")
		g.b_main_client_ts.writeln("")
	}
	
	// ============== main register func =====================
	
	g.main_register_func.writeln("\t${bind_class_name}::Init(env, exports);")
	
	// ===========================================================

	g.b_main_client_h.writeln("\t// ${g.obj_name} methods")

	g.each_all_this_fns(g.sym, fn(mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl){
		g.gen_header_fn(g.sym, func)
		g.gen_impl_fn(g.sym, func)
		g.gen_ts_h_fn(g.sym, func)
		g.gen_rpc_clint_impl_fn(g.sym, func)
		g.gen_rpc_server_impl_fn(g.sym, func)
	})
	
	g.b_main_client_h.writeln("\t// parent methods")
	g.each_all_parent_fns(g.sym, fn(mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl){
		g.gen_header_fn(sum, func)
		g.gen_impl_fn(sum, func)
	})

	// ============== generate cpp js bind =======================
	// Init
	// constructor
	// destructor
	// From
	// IsInstance
	// ToImplValue
	// ToNapiValue
	g.gen_end_impl()
	// ============== generate h js bind =======================
	impl_type_name := g.get_impl_type_name(g.obj_type)
	g.b_main_client_h.writeln("")
	if !g.is_no_instance_class(g.obj_type) {
		g.b_main_client_h.writeln("\t// tools")
		g.b_main_client_h.writeln("\tstatic ${impl_type_name} Cast(const Napi::Value& value);")
		g.b_main_client_h.writeln("\tstatic bool IsInstance(const Napi::Value& value);")
		g.b_main_client_h.writeln("\tstatic ${impl_type_name} ToImplValue(const Napi::Value& value);")
		g.b_main_client_h.writeln("\tstatic Napi::Value ToNapiValue(Napi::Env env, ${impl_type_name} value);")
		g.b_main_client_h.writeln("")
		g.b_main_client_h.writeln("\t${impl_type_name} self = nullptr;")
		//g.b_main_client_h.writeln("\tuint32_t typeIdx = ${g.obj_type};")
	}
	g.b_main_client_h.writeln("}; // end class ${bind_class_name}")
	g.b_main_client_h.writeln("")
	
	// ============== generate ts headers =====================
	g.b_main_client_ts.writeln("\t}")
	g.b_main_client_ts.writeln("")
}

fn (mut g Gen) gen_header_fn(sym &ast.TypeSymbol, func &ast.FnDecl) {
	//js_class_name := g.gen_bind_class_name(g.obj_name)
	js_fn_name := g.gen_js_fn_name(func.name)

	if func.is_global {
		g.b_main_client_h.writeln("\tstatic Napi::Value ${js_fn_name}(const Napi::CallbackInfo& info);")
	}
	else {
		g.b_main_client_h.writeln("\tNapi::Value ${js_fn_name}(const Napi::CallbackInfo& info);")
	}
}

fn (mut g Gen) gen_impl_fn(sym &ast.TypeSymbol, func &ast.FnDecl) {
	js_class_name := g.gen_bind_class_name(g.obj_name)
	js_fn_name := g.gen_js_fn_name(func.name)

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
		param_impl_type_name := g.get_impl_type_name(param.typ)

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

			g.b_main_client_cpp.writeln("${g.gen_convert_to_varvalue_optional(param.typ, arg, default_value, arg)};")
		}
		else {
			g.b_main_client_cpp.writeln("${g.gen_convert_to_varvalue(param.typ, arg)};")
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
		return_impl_type_name := g.get_impl_type_name(func.return_type)
		g.b_main_client_cpp.write_string("\t\t${return_impl_type_name} res = ")
	}
	else {
		g.b_main_client_cpp.write_string("\t\t")
	}

	if !func.is_global || func.params.len > 0 {
		call_args_list = ", " + call_args_list
	}

	if func.is_global {
		g.b_main_client_cpp.writeln("ThreadCommunicator::GetSingleton()->ExecuteGameFunctionInUpdate(${g.get_fn_impl_name(sym.obj_name, func.name)}${call_args_list});")
	}
	else {
		g.b_main_client_cpp.writeln("ThreadCommunicator::GetSingleton()->ExecuteGameFunctionInUpdate(${g.get_fn_impl_name(sym.obj_name, func.name)}${call_args_list});")
	}
	
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\t\treturn ${g.gen_convert_to_napivalue(func.return_type, "res")};")
	g.b_main_client_cpp.writeln("\t}")

	/*
		g.b_main_client_cpp.writeln("\t\t\tstd::string errMsg = \"Failed to cast to `${g.get_impl_obj_type_name(g.obj_type)}`\"")
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

fn (mut g Gen) gen_ts_h_fn(sym &ast.TypeSymbol, func &ast.FnDecl) {
	for i in 0..func.params.len {
		param := func.params[i]
		g.temp_args.write_string(param.name)
		if param.is_optional {
			g.temp_args.write_string("?: ")
		}
		else {
			g.temp_args.write_string(": ")
		}
		g.temp_args.write_string(g.get_ts_type_name(param.typ))

		if param.is_optional {
			// если есть комментарий с пояснением например `/*int*/`
			// то удаляем */ и продолжаем комментарий
			if g.temp_args.last_n(2) == "*/" {
				g.temp_args.go_back("*/".len) // remove last `*/`
			}
			else {
				g.temp_args.write_string("/*")
			}

			match param.default_value {
				ast.NoneLiteral {
					g.temp_args.write_string(" = null*/")
				}
				ast.IntegerLiteral {
					g.temp_args.write_string(" = ${param.default_value.val}*/")
				}
				ast.FloatLiteral {
					g.temp_args.write_string(" = ${param.default_value.val}*/")
				}
				ast.BoolLiteral {
					g.temp_args.write_string(" = ${param.default_value.val}*/")
				}
				ast.StringLiteral {
					g.temp_args.write_string(" = ${param.default_value.val}*/")
				}
				else {
					panic("invalid expr in param")
				}
			}
		}
		
		if i != func.params.len - 1 {
			g.temp_args.write_string(", ")
		}
	}

	if func.is_global {
		g.b_main_client_ts.writeln("\t\tstatic ${func.name}(${g.temp_args.str()}): ${g.get_ts_type_name(func.return_type)}")
	}
	else {
		g.b_main_client_ts.writeln("\t\t${func.name}(${g.temp_args.str()}): ${g.get_ts_type_name(func.return_type)}")
	}
}