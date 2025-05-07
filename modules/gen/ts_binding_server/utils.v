module ts_binding_server

import papyrus.ast

fn (mut g Gen) each_all_files(cb fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File)) {
	for key, file in g.file_by_name {
		sym := g.table.find_type(key) or { panic("TypeSymbol not found `${key}`") }
		
		cb(mut g, sym, file)
	}
}

// this and parents
fn (mut g Gen) each_all_fns(sym &ast.TypeSymbol, cb fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl)) {
	g.each_all_this_fns(sym, cb)
	g.each_all_parent_fns(sym, cb)
}

fn (mut g Gen) each_all_this_fns(sym &ast.TypeSymbol, cb fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl)) {
	obj_name := sym.obj_name
	file := g.file_by_name[obj_name.to_lower()] or { panic("file not found `${obj_name}`") }
	
	for stmt in file.stmts {
		match stmt {
			ast.Comment {}
			ast.ScriptDecl {}
			ast.FnDecl {
				cb(mut g, sym, stmt)
			}
			else { panic("invalid top stmt ${stmt}") }
		}
	}
}

fn (mut g Gen) each_all_parent_fns(sym &ast.TypeSymbol, cb fn(mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl)) {
	mut cur_idx := sym.parent_idx
	for {
		if cur_idx == 0 {
			break
		}

		t_sym := g.table.get_type_symbol(cur_idx)
		t_name := t_sym.name
		t_file := g.file_by_name[t_name.to_lower()] or { panic("file not found `${t_name}`") }

		for stmt in t_file.stmts {
			match stmt {
				ast.Comment {}
				ast.ScriptDecl {}
				ast.FnDecl {
					cb(mut g, t_sym, stmt)
				}
				else { panic("invalid top stmt ${stmt}") }
			}
		}
		
		cur_idx = t_sym.parent_idx
	}
}

fn (mut g Gen) gen_ctor_name(obj_name string) string {
	return "${g.gen_bind_class_name(obj_name)}_constructor"
}

fn (mut g Gen) gen_js_fn_name(name string) string {
	return name
}

fn (mut g Gen) gen_vm_fn_impl_name(object_name string, func_name string) string {
	return "vm_${object_name}_${func_name}"
}

fn (mut g Gen) gen_impl_class_name(name string) string {
	return "Papyrus${name}"
}

fn (mut g Gen) gen_bind_class_name(name string) string {
	return "JSPapyrus${name}"
}

fn (mut g Gen) get_ts_type_name(typ ast.Type) string {
	match typ {
		ast.none_type {
			return "void"
		}
		ast.int_type {
			return "number /*int*/"
		}
		ast.float_type {
			return "number /*float*/"
		}
		ast.string_type {
			return "string"
		}
		ast.bool_type {
			return "boolean"
		}
		ast.array_type {
			panic("invalid type")
		}
		ast.string_array_type {
			return "string[]"
		}
		ast.int_array_type {
			return "number[] /*int[]*/"
		}
		ast.float_array_type {
			return "number[] /*float[]*/"
		}
		ast.bool_array_type {
			return "bool[]"
		}
		else {
			sym := g.table.get_type_symbol(typ)
			if sym.kind == .script {
				return "${sym.name} | null"
			}
			else {
				eprintln("TODO get_ts_type_name support type ${sym.name}")
				return "unknown/*${sym.name}*/"
			}
		}
	}
}

fn (mut g Gen) gen_convert_to_napivalue(typ ast.Type, var_value string) string {
	type_name := g.table.get_type_symbol(typ).name

	match typ {
		ast.none_type {
			return "info.Env().Null();"
		}
		ast.int_type {
			return "Napi::Number::New(info.Env(), (int)${var_value})"
		}
		ast.float_type {
			return "Napi::Number::New(info.Env(), (double)${var_value})"
		}
		ast.string_type {
			return "Napi::String::New(info.Env(), std::string((const char*)${var_value}))"
		}
		ast.bool_type {
			return "Napi::Boolean::New(info.Env(), (bool)${var_value})"
		}
		ast.array_type {
			panic("invlid type")
		}
		ast.string_array_type {
			panic("TODO type")
		}
		ast.int_array_type {
			panic("TODO type")
		}
		ast.float_array_type {
			panic("TODO type")
		}
		ast.bool_array_type {
			panic("TODO type")
		}
		else {
			sym := g.table.get_type_symbol(typ)
			if sym.kind == .script {
				return "${g.gen_bind_class_name(type_name)}::ToNapiValue(info.Env(), ${var_value})"
			}
			else {
				eprintln("TODO gen_convert_to_napivalue support type ${sym.name}")
				return "info.Env().Undefined()/*${sym.name}*/"
			}
		}
	}

}

fn (mut g Gen) gen_convert_to_varvalue(typ ast.Type, js_value string, desc string) string {
	type_name := g.table.get_type_symbol(typ).name

	match typ {
		ast.none_type {
			panic("invlid type")
		}
		ast.int_type {
			return "VarValue(NapiHelper::ExtractInt32(${js_value}, \"${desc}\"))"
		}
		ast.float_type {
			return "VarValue(NapiHelper::ExtractFloat(${js_value}, \"${desc}\"))"
		}
		ast.string_type {
			return "VarValue(NapiHelper::ExtractString(${js_value}, \"${desc}\"))"
		}
		ast.bool_type {
			return "VarValue(NapiHelper::ExtractBoolean(${js_value}, \"${desc}\"))"
		}
		ast.array_type {
			panic("invlid type")
		}
		ast.string_array_type {
			panic("TODO type")
		}
		ast.int_array_type {
			panic("TODO type")
		}
		ast.float_array_type {
			panic("TODO type")
		}
		ast.bool_array_type {
			panic("TODO type")
		}
		else {
			sym := g.table.get_type_symbol(typ)
			if sym.kind == .script {
				return "${g.gen_bind_class_name(type_name)}::ToVMValue(${js_value})"
			}
			else {
				panic("unknown type ${sym}")
			}
		}
	}
}

fn (mut g Gen) gen_convert_to_varvalue_optional(typ ast.Type, js_value string, default_value string, desc string) string {
	type_name := g.table.get_type_symbol(typ).name

	match typ {
		ast.none_type {
			panic("invlid type")
		}
		ast.int_type {
			return "VarValue(NapiHelper::ExtractOptionalInt32(${js_value}, ${default_value}, \"${desc}\"))"
		}
		ast.float_type {
			return "VarValue(NapiHelper::ExtractOptionalFloat(${js_value}, ${default_value}, \"${desc}\"))"
		}
		ast.string_type {
			return "VarValue(NapiHelper::ExtractOptionalString(${js_value}, ${default_value}, \"${desc}\"))"
		}
		ast.bool_type {
			return "VarValue(NapiHelper::ExtractOptionalBoolean(${js_value}, ${default_value}, \"${desc}\"))"
		}
		ast.array_type {
			panic("invlid type")
		}
		ast.string_array_type {
			panic("TODO type")
		}
		ast.int_array_type {
			panic("TODO type")
		}
		ast.float_array_type {
			panic("TODO type")
		}
		ast.bool_array_type {
			panic("TODO type")
		}
		else {
			sym := g.table.get_type_symbol(typ)
			if sym.kind == .script {
				return "!${js_value}.IsUndefined() ? ${g.gen_bind_class_name(type_name)}::ToVMValue(${js_value}) : VarValue::None()"
			}
			else {
				panic("unknown type ${sym}")
			}
		}
	}
}