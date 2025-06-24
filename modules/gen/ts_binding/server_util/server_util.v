module server_util

import papyrus.ast

pub fn gen_ctor_name(obj_name string) string {
	return "${gen_bind_class_name(obj_name)}_constructor"
}

pub fn gen_js_fn_name(name string) string {
	return name
}

pub fn gen_vm_fn_impl_name(object_name string, func_name string) string {
	return "vm_${object_name}_${func_name}"
}

pub fn gen_impl_class_name(name string) string {
	return "Papyrus${name}"
}

pub fn gen_bind_class_name(name string) string {
	return "JSPapyrus${name}"
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
			return "v8::Null(isolate)"
		}
		ast.int_type {
			return "v8::Number::New(isolate, (int)${var_value})"
		}
		ast.float_type {
			return "v8::Number::New(isolate, (double)${var_value})"
		}
		ast.string_type {
			return "v8String(std::string((const char*)${var_value}))"
		}
		ast.bool_type {
			return "v8::Boolean::New(isolate, (bool)${var_value})"
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
				return "${gen_bind_class_name(type_name)}::Wrap(isolate, ${var_value})"
			}
			else {
				eprintln("TODO gen_convert_to_napivalue support type ${sym.name}")
				return "v8::Null(isolate)/*${sym.name}*/"
			}
		}
	}

}

pub fn gen_convert_to_varvalue(table &ast.Table, typ ast.Type, js_value string, desc string) string {
	type_name := table.get_type_symbol(typ).name

	match typ {
		ast.none_type {
			panic("invlid type")
		}
		ast.int_type {
			return "VarValue(JsHelper::ExtractInt32(isolate, ${js_value}, \"${desc}\"))"
		}
		ast.float_type {
			return "VarValue(JsHelper::ExtractFloat(isolate, ${js_value}, \"${desc}\"))"
		}
		ast.string_type {
			return "VarValue(JsHelper::ExtractString(isolate, ${js_value}, \"${desc}\"))"
		}
		ast.bool_type {
			return "VarValue(JsHelper::ExtractBoolean(isolate, ${js_value}, \"${desc}\"))"
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
				return "${gen_bind_class_name(type_name)}::UnwrapSelf(isolate, ${js_value})"
			}
			else {
				panic("unknown type ${sym}")
			}
		}
	}
}

pub fn gen_convert_to_varvalue_optional(table &ast.Table, typ ast.Type, js_value string, default_value string, desc string) string {
	type_name := table.get_type_symbol(typ).name

	match typ {
		ast.none_type {
			panic("invlid type")
		}
		ast.int_type {
			return "VarValue(JsHelper::ExtractOptionalInt32(isolate, ${js_value}, ${default_value}, \"${desc}\"))"
		}
		ast.float_type {
			return "VarValue(JsHelper::ExtractOptionalFloat(isolate, ${js_value}, ${default_value}, \"${desc}\"))"
		}
		ast.string_type {
			return "VarValue(JsHelper::ExtractOptionalString(isolate, ${js_value}, ${default_value}, \"${desc}\"))"
		}
		ast.bool_type {
			return "VarValue(JsHelper::ExtractOptionalBoolean(isolate, ${js_value}, ${default_value}, \"${desc}\"))"
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
				return "!${js_value}->IsUndefined() ? ${gen_bind_class_name(type_name)}::UnwrapSelf(isolate, ${js_value}) : VarValue::None()"
			}
			else {
				panic("unknown type ${sym}")
			}
		}
	}
}