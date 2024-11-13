module gen_v

import papyrus.ast
import pex

fn (mut g Gen) gen_object_interface() {
	g.writeln("pub struct ${g.cur_obj_name} {")
	
	sym := g.table.get_type_symbol(g.cur_obj_type)
	g.indent_size++
	
	g.writeln("vm_handle VmHandle")

	g.indent_size--
	g.writeln("}")
	g.writeln("")

	
	g.writeln("pub fn create_array_${g.cur_obj_name.to_lower()}_from_value(value PapyrusValue) []${g.get_object_type_name(g.cur_obj_name)} {")
	g.indent_size++
	g.writeln("assert value.typ == .type_object_array")
	g.writeln("mut result := []${g.get_object_type_name(g.cur_obj_name)}{}")
	g.writeln("for elem in value.data.value_array {")
	g.writeln("\tresult << ${g.get_object_type_name(g.cur_obj_name)}{ vm_handle:  elem.object() }")
	g.writeln("}")
	g.writeln("return result")
	g.indent_size--
	g.writeln("}")

	g.writeln("")

	g.writeln("pub fn create_value_from_array_${g.cur_obj_name.to_lower()}(arr []${g.get_object_type_name(g.cur_obj_name)}) PapyrusValue {")
	g.indent_size++
	g.writeln("mut result := []PapyrusValue{}")
	g.writeln("for elem in arr {")
	g.writeln("\tresult << create_object(elem.vm_handle)")
	g.writeln("}")
	g.writeln("return PapyrusValue{ typ: .type_object_array, data: ValueData{ value_array: result } }")
	g.indent_size--
	g.writeln("}")

	for _, map_func in g.funcs {
		func := map_func[pex.empty_state_name] or { panic("wtf") }
		g.cur_fn = func

		g.writeln("")
		if func.is_global {
			g.gen_global_fn_wrapper(func)
		}
		else {
			g.gen_method_wrapper(func)
		}
		
		g.cur_fn = voidptr(0)
	}
}

fn (mut g Gen) gen_global_fn_wrapper(func &ast.FnDecl) {
	fn_name := g.get_global_fn_name(g.cur_obj_name, func.name)
	return_type := if func.return_type == ast.none_type { "" } else { g.get_type_name(func.return_type) }

	g.write("pub fn ${fn_name}(")
	g.gen_fn_args(func)
	g.write(") ${return_type} {")
	g.write_endln()
	g.indent_size++

	g.write_startln()
	if func.return_type != ast.none_type {
		g.write("result_value := ")
	}

	if func.is_native {
		g.write("game_api.call_native_static_func(\"${g.cur_obj_name}\", \"${func.name}\", ")
	}
	else {
		g.write("game_api.call_vm_static_func(\"${g.cur_obj_name}\", \"${func.name}\", ")
	}

	g.wrapper_gen_call_args(func.params)
	g.write(")")
	g.write_endln()
	
	if func.return_type != ast.none_type {
		g.write_tab("return ")
		g.gen_from_papyrus_value(func.return_type, "result_value")
		g.write_endln()
	}

	g.indent_size--
	g.writeln("}")
}

fn (mut g Gen) gen_method_wrapper(func &ast.FnDecl) {
	return_type := if func.return_type == ast.none_type { "" } else { g.get_type_name(func.return_type) }
	fn_name := g.get_method_name(func.name)

	g.write("pub fn (mut self ${g.cur_obj_name}) ${fn_name}(")
	g.gen_fn_args(func)
	g.write(") ${return_type} {")
	g.writeln("")
	g.indent_size++
	g.write_startln()
	if func.return_type != ast.none_type {
		g.write("result_value := ")
	}

	if func.is_event {
		g.write("game_api.send_event(\"${func.name}\", self.vm_handle, ")
	}
	else if func.is_native {
		g.write("game_api.call_native_method(\"${func.name}\", self.vm_handle, ")
	}
	else {
		g.write("game_api.call_vm_method(\"${func.name}\", self.vm_handle, ")
	}

	g.wrapper_gen_call_args(func.params)
	g.write(")")
	g.write_endln()
	
	if func.return_type != ast.none_type {
		g.write_tab("return ")
		g.gen_from_papyrus_value(func.return_type, "result_value")
		g.write_endln()
	}

	g.indent_size--
	g.writeln("}")
}

fn (mut g Gen) wrapper_gen_call_args(params []ast.Param) {
	if params.len == 0 {
		g.write("[]PapyrusValue{}")
	}
	else {
		g.write(" [")
		g.indent_size++
		g.write_endln()
		for i in 0..params.len {
			param := params[i]
			param_sym := g.table.get_type_symbol(param.typ)

			g.write_startln()
			g.gen_to_papyrus_value(param.typ, param.name)

			if i < params.len - 1 {
				g.write(", ")
			}
			g.write_endln()
		}
		g.indent_size--
		g.write_tab("]")
	}
}

fn (mut g Gen) gen_to_papyrus_value(typ ast.Type, name string) {
	sym := g.table.get_type_symbol(typ)

	if sym.kind == .script {
		g.write("create_papyrus_value(${name}.vm_handle)")
	}
	else if sym.kind == .array {
		arr_info := sym.info as ast.Array
		elem_type_sym := g.table.get_type_symbol(arr_info.elem_type)
		g.write("create_array[${elem_type_sym.name}](${name})")
	}
	else {
		g.write("create_papyrus_value(${name})")
	}
}

fn (mut g Gen) gen_from_papyrus_value(typ ast.Type, name string) {
	sym := g.table.get_type_symbol(typ)

	if sym.kind == .script {
		g.write("${g.get_object_type_name(sym.name)}{ vm_handle: ${name}.object() }")
	}
	else if sym.kind == .array {
		arr_info := sym.info as ast.Array
		elem_type_sym := g.table.get_type_symbol(arr_info.elem_type)

		if elem_type_sym.kind == .script {
			g.write("create_array_${elem_type_sym.name.to_lower()}_from_value(${name})")
		}
		else {
			g.write("${name}.array[${g.get_type_name(arr_info.elem_type)}]()")
		}
	}
	else {
		g.write("${name}.${g.get_type_name(typ)}()")
	}
}

fn (mut g Gen) gen_wrapper_util() {
	g.writeln("pub fn create_object(value VmHandle) PapyrusValue {")
	g.writeln("\treturn PapyrusValue{ typ: .type_object, data: ValueData{ value_object: value } }")
	g.writeln("}")

	g.write_endln()

	g.writeln("pub fn (value PapyrusValue) object() VmHandle {")
	g.writeln("\tassert value.typ == .type_object")
	g.writeln("\treturn value.data.value_object")
	g.writeln("}")

	g.write_endln()
}