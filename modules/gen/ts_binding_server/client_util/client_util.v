module server_util

import papyrus.ast

pub fn gen_ctor_name(obj_name string) string {
	return "${gen_bind_class_name(obj_name)}_constructor"
}

pub fn gen_js_fn_name(name string) string {
	return name
}

pub fn get_fn_rpc_impl_name(object_name string, func_name string) string {
	return "RPC_${object_name}_${func_name}"
}

pub fn get_fn_impl_name(object_name string, func_name string) string {
	return "${object_name}_${func_name}"
}

pub fn gen_impl_class_name(name string) string {
	return "Papyrus${name}"
}

pub fn gen_bind_class_name(name string) string {
	return "JSPapyrus${name}"
}

pub fn get_real_impl_fn_name(obj_name string, func_name string) string {
	return "${obj_name}_${func_name}"
}

// rename impl_class_name
pub fn get_impl_obj_type_name(table &ast.Table, impl_classes map[string]string, typ ast.Type) string {
	sym := table.get_type_symbol(typ)
	name := sym.name
	assert sym.kind == .script

	res := impl_classes[name.to_lower()] or {
		eprintln("failed to find a type name for `${name}` -> `RE::TESForm`")
		return "RE::TESForm"
	}

	return res
}

pub fn is_no_instance_class(no_instance_class []ast.Type, idx ast.Type) bool {
	return idx in no_instance_class
}

pub fn get_impl_type_name(table &ast.Table, impl_classes map[string]string, typ ast.Type) string {
	sym := table.get_type_symbol(typ)
	name := sym.name

	match name.to_lower() {
		"bool" {
			return "bool"
		}
		"int" {
			return "int"
		}
		"float" {
			return "float"
		}
		"string" {
			return "std::string"
		}
		else {
			if sym.kind == .script {
				return "${get_impl_obj_type_name(table, impl_classes, typ)}*"
			}
			else {
				panic("invalid type ${name}")
			}
		}
	}
}

pub fn get_ts_type_name(table &ast.Table, typ ast.Type) string {
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
			sym := table.get_type_symbol(typ)
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

pub fn gen_convert_to_napivalue(table &ast.Table, typ ast.Type, var_value string) string {
	type_name := table.get_type_symbol(typ).name

	match typ {
		ast.none_type {
			return "info.Env().Null();"
		}
		ast.int_type {
			return "Napi::Number::New(info.Env(), ${var_value})"
		}
		ast.float_type {
			return "Napi::Number::New(info.Env(), ${var_value})"
		}
		ast.string_type {
			return "Napi::String::New(info.Env(), ${var_value})"
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
			sym := table.get_type_symbol(typ)
			if sym.kind == .script {
				return "${gen_bind_class_name(type_name)}::ToNapiValue(info.Env(), ${var_value})"
			}
			else {
				eprintln("TODO gen_convert_to_napivalue support type ${sym.name}")
				return "info.Env().Undefined()/*${sym.name}*/"
			}
		}
	}

}

// rename gen_convert_to_impl_value
pub fn gen_convert_to_varvalue(table &ast.Table, typ ast.Type, js_value string) string {
	type_name := table.get_type_symbol(typ).name

	match typ {
		ast.none_type {
			panic("invlid type")
		}
		ast.int_type {
			return "NapiHelper::ExtractInt32(${js_value}, \"${js_value}\")"
		}
		ast.float_type {
			return "NapiHelper::ExtractFloat(${js_value}, \"${js_value}\")"
		}
		ast.string_type {
			return "NapiHelper::ExtractString(${js_value}, \"${js_value}\")"
		}
		ast.bool_type {
			return "NapiHelper::ExtractBoolean(${js_value}, \"${js_value}\")"
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
			sym := table.get_type_symbol(typ)
			if sym.kind == .script {
				return "!${js_value}.IsNull() ? ${gen_bind_class_name(type_name)}::ToImplValue(${js_value}) : nullptr"
			}
			else {
				panic("unknown type ${sym}")
			}
		}
	}
}

// rename gen_convert_to_impl_value
pub fn gen_convert_to_varvalue_optional(table &ast.Table, typ ast.Type, js_value string, default_value string, desc string) string {
	type_name := table.get_type_symbol(typ).name

	match typ {
		ast.none_type {
			panic("invlid type")
		}
		ast.int_type {
			return "NapiHelper::ExtractOptionalInt32(${js_value}, ${default_value}, \"${desc}\")"
		}
		ast.float_type {
			return "NapiHelper::ExtractOptionalFloat(${js_value}, ${default_value}, \"${desc}\")"
		}
		ast.string_type {
			return "NapiHelper::ExtractOptionalString(${js_value}, ${default_value}, \"${desc}\")"
		}
		ast.bool_type {
			return "NapiHelper::ExtractOptionalBoolean(${js_value}, ${default_value}, \"${desc}\")"
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
			sym := table.get_type_symbol(typ)
			if sym.kind == .script {
				return "${js_value}.IsObject() && !${js_value}.IsNull() ? ${gen_bind_class_name(type_name)}::ToImplValue(${js_value}) : nullptr"
			}
			else {
				panic("unknown type ${sym}")
			}
		}
	}
}