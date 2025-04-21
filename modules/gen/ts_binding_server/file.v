module ts_binding_server

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
	
	g.ts_headers.writeln("\t\tstatic From(formId: number): ${g.obj_name} | null")
	g.ts_headers.writeln("")
	
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
	// ToVMValue
	// ToNapiValue
	g.gen_end_impl()
	// ============== generate h js bind =======================
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("\t// tools")
	g.class_bind_h.writeln("\tstatic Napi::Value From(const Napi::CallbackInfo& info);")
	g.class_bind_h.writeln("\tstatic bool IsInstance(const Napi::Value& value);")
	g.class_bind_h.writeln("\tstatic VarValue ToVMValue(const Napi::Value& value);")
	g.class_bind_h.writeln("\tstatic Napi::Value ToNapiValue(Napi::Env env, const VarValue& value);")
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("private:")
	g.class_bind_h.writeln("\tVarValue self;")
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
	g.class_bind_cpp.writeln("\t\tstd::vector<VarValue> args = {")

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

			g.class_bind_cpp.write_string("\t\t\t${g.gen_convert_to_varvalue_optional(param.typ, arg, default_value, param.name)}")
		}
		else {
			arg := "info[${i}]"
			g.class_bind_cpp.write_string("\t\t\t${g.gen_convert_to_varvalue(param.typ, arg, param.name)}")
		}
		
		g.class_bind_cpp.writeln(",")
	}

	if func.params.len > 0 {
		g.class_bind_cpp.go_back("\n,".len)
		g.class_bind_cpp.writeln("")
	}
	
	g.class_bind_cpp.writeln("\t\t};")

	if !func.is_global {
		g.class_bind_cpp.writeln("")
		g.class_bind_cpp.writeln("\t\tif (!self || self.GetType() != VarValue::Type::kType_Object)")
		g.class_bind_cpp.writeln("\t\t{")
		g.class_bind_cpp.writeln("\t\t\tthrow std::runtime_error(\"invalid self in ${js_class_name}::${js_fn_name}\");")
		g.class_bind_cpp.writeln("\t\t}")
		g.class_bind_cpp.writeln("")
	}

	g.class_bind_cpp.writeln("\t\tNapi::Env env = info.Env();")
	
	if func.is_global {
		g.class_bind_cpp.writeln("\t\tVarValue res = ${g.gen_vm_fn_impl_name(sym.obj_name, func.name)}(VarValue::None(), args);")
	}
	else {
		g.class_bind_cpp.writeln("\t\tVarValue res = ${g.gen_vm_fn_impl_name(sym.obj_name, func.name)}(self, args);")
	}
	
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("\t\treturn ${g.gen_convert_to_napivalue(func.return_type, "res")};")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\tcatch(std::exception& e) {")
	g.class_bind_cpp.writeln("\t\tspdlog::error((std::string)e.what());")
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
					panic("invalid expr in param ${param}")
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