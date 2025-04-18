module ts_binding_client

import papyrus.ast

fn (mut g Gen) gen(file &ast.File) {
	//impl_class_name := g.gen_impl_class_name(g.obj_name)
	bind_class_name := g.gen_bind_class_name(g.obj_name)

	// ============== generate h js bind =======================

	g.class_bind_h.writeln("class ${bind_class_name} : public Napi::ObjectWrap<${bind_class_name}> {")
	g.class_bind_h.writeln("public:")
	g.class_bind_h.writeln("\tstatic Napi::Object Init(Napi::Env env, Napi::Object exports);")
	g.class_bind_h.writeln("\t${bind_class_name}(const Napi::CallbackInfo& info);")
	g.class_bind_h.writeln("\t~${bind_class_name}() {};")
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("\t// wrappers")

	// ============== generate cpp js bind =======================

	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("// ==================================================================================")
	g.class_bind_cpp.writeln("// ==================================${bind_class_name}==============================")
	g.class_bind_cpp.writeln("")

	// ============== generate ts headers =====================
	
	if g.sym.parent_idx == 0 {
		g.ts_headers.writeln("\tclass ${g.obj_name} {")
	}
	else {
		g.ts_headers.writeln("\tclass ${g.obj_name} extends ${g.parent_obj_name} {")
	}
	
	if g.is_form(g.sym) {
		g.ts_headers.writeln("\t\tstatic From(formId: number): ${g.obj_name} | null")
		g.ts_headers.writeln("")
	}
	
	// ============== main register func =====================
	
	g.main_register_func.writeln("\t${bind_class_name}::Init(env, exports);")
	
	// ===========================================================

	g.class_bind_h.writeln("\t// ${g.obj_name} methods")

	g.each_all_this_fns(g.sym, fn(mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl){
		g.gen_header_fn(g.sym, func)
		g.gen_impl_fn(g.sym, func)
		g.gen_ts_h_fn(g.sym, func)
	})
	
	g.class_bind_h.writeln("\t// parent methods")
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
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("\t// tools")
	if g.is_form(g.sym) {
		g.class_bind_h.writeln("\tstatic Napi::Value From(const Napi::CallbackInfo& info);")
	}
	g.class_bind_h.writeln("\tstatic bool IsInstance(const Napi::Value& value);")
	g.class_bind_h.writeln("\tstatic ${impl_type_name} ToImplValue(const Napi::Value& value);")
	g.class_bind_h.writeln("\tstatic Napi::Value ToNapiValue(Napi::Env env, ${impl_type_name} value);")
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("private:")
	g.class_bind_h.writeln("\t${impl_type_name} self = nullptr;")
	g.class_bind_h.writeln("}; // end class ${bind_class_name}")
	g.class_bind_h.writeln("")
	
	// ============== generate ts headers =====================
	g.ts_headers.writeln("\t}")
	g.ts_headers.writeln("")
}

fn (mut g Gen) gen_header_fn(sym &ast.TypeSymbol, func &ast.FnDecl) {
	//js_class_name := g.gen_bind_class_name(g.obj_name)
	js_fn_name := g.gen_js_fn_name(func.name)

	if func.is_global {
		g.class_bind_h.writeln("\tstatic Napi::Value ${js_fn_name}(const Napi::CallbackInfo& info);")
	}
	else {
		g.class_bind_h.writeln("\tNapi::Value ${js_fn_name}(const Napi::CallbackInfo& info);")
	}
}

fn (mut g Gen) gen_impl_fn(sym &ast.TypeSymbol, func &ast.FnDecl) {
	js_class_name := g.gen_bind_class_name(g.obj_name)
	js_fn_name := g.gen_js_fn_name(func.name)

	g.class_bind_cpp.writeln("Napi::Value ${js_class_name}::${js_fn_name}(const Napi::CallbackInfo& info)")
	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("\ttry")
	g.class_bind_cpp.writeln("\t{")

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
		g.class_bind_cpp.writeln("\t\t${param_impl_type_name} ${param.name} = ${g.gen_convert_to_varvalue(param.typ, arg)};")

		call_args_list += param.name

		if i != func.params.len - 1 {
			call_args_list += ", "
		}
	}

	if !func.is_global {
		if func.params.len != 0 {
			g.class_bind_cpp.writeln("")
		}

		g.class_bind_cpp.writeln("\t\tif (!self)")
		g.class_bind_cpp.writeln("\t\t{")
		g.class_bind_cpp.writeln("\t\t\tERR_AND_THROW(\"invalid self in ${js_class_name}::${js_fn_name}\");")
		g.class_bind_cpp.writeln("\t\t}")
		g.class_bind_cpp.writeln("")
	}

	g.class_bind_cpp.writeln("\t\tNapi::Env env = info.Env();")
	

	if func.return_type != ast.none_type {
		return_impl_type_name := g.get_impl_type_name(func.return_type)
		g.class_bind_cpp.write_string("\t\t${return_impl_type_name} res = ")
	}
	else {
		g.class_bind_cpp.write_string("\t\t")
	}

	if func.is_global {
		g.class_bind_cpp.writeln("${g.get_fn_impl_name(sym.obj_name, func.name)}(${call_args_list});")
	}
	else {
		g.class_bind_cpp.writeln("${g.get_fn_impl_name(sym.obj_name, func.name)}(${call_args_list});")
	}
	
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("\t\treturn ${g.gen_convert_to_napivalue(func.return_type, "res")};")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\tcatch(std::exception& e) {")
	g.class_bind_cpp.writeln("\t\tERR((std::string)e.what());")
	g.class_bind_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\treturn info.Env().Undefined();")
	g.class_bind_cpp.writeln("}")
	g.class_bind_cpp.writeln("")
}

fn (mut g Gen) gen_ts_h_fn(sym &ast.TypeSymbol, func &ast.FnDecl) {
	for i in 0..func.params.len {
		param := func.params[i]
		g.temp_args.write_string(param.name)
		g.temp_args.write_string(": ")
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
		g.ts_headers.writeln("\t\tstatic ${func.name}(${g.temp_args.str()}): ${g.get_ts_type_name(func.return_type)}")
	}
	else {
		g.ts_headers.writeln("\t\t${func.name}(${g.temp_args.str()}): ${g.get_ts_type_name(func.return_type)}")
	}
}