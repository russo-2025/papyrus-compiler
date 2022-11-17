module pex

import strings

fn print_start_block(name string) {
	print("==============================")
	print(name)
	println("==============================")
}

fn print_end_block(name string) {
	print("==============================")
	println("==============================")
}

fn (p PexFile)  print_debug_function(f DebugFunction, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }

	obj_name := p.get_string(f.object_name)
	state_name := p.get_string(f.state_name)
	fn_name := p.get_string(f.function_name)
	fn_type := f.function_type
	instruction_count := f.instruction_count
	//line_numbers := "..." //f.line_numbers

	println(tab + "object name: '$obj_name'")
	println(tab + "state name: '$state_name'")
	println(tab + "func name: '$fn_name'")
	println(tab + "type: $fn_type")
	println(tab + "instruction count: $instruction_count")
}

fn (p PexFile) print_flag(flg UserFlag) {
	name := p.get_string(flg.name)
	index := "0x" + flg.flag_index.hex()
	print("flag{ name: '$name', index: $index }")
}

pub fn (p PexFile) print_instruction(inst Instruction, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }

	op := unsafe { OpCode(inst.op) }.str()
	mut args := ""
	
	mut i := 0
	for i < inst.args.len {
		args += p.get_variable_data(inst.args[i])
		
		if i < inst.args.len - 1 {
			args += ", "
		}

		i++
	}

	println(tab + "opcode: '$op', args: [$args]")
}

fn (p PexFile) print_variable_type(v VariableType, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }
	
	name := p.get_string(v.name)
	typ := p.get_string(v.typ)

	println(tab + "$typ $name")
}

fn (p PexFile) get_formated_fn_flags(info FunctionInfo) string {
	mut str := ""

	is_global := info.flags & 0b0001
	in_native := info.flags & 0b0010

	if is_global > 0 {
		str += "global"
	}
	if is_global > 0 && in_native > 0  {
		str += " "
	}
	if in_native > 0 {
		str += "native"
	}
	return str
}

fn (p PexFile) print_func(f Function, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }

	name :=  p.get_string(f.name)
	println(tab + "name: '$name'")
	
	p.print_func_info(f.info, indentSize)
}

fn (p PexFile) print_func_info(info FunctionInfo, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }

	typ :=  p.get_string(info.return_type)
	doc :=  p.get_string(info.docstring)
	user_flags :=  "0x" + info.user_flags.hex()
	flags :=  "0x" + info.flags.hex()

	params_count := info.num_params
	locals_count := info.num_locals
	instructions_count := info.num_instructions

	println(tab + "typ: '$typ'")
	println(tab + "doc: '$doc'")
	println(tab + "user_flags: $user_flags")
	println(tab + "flags: $flags")
	println(tab + "flags: `${p.get_formated_fn_flags(info)}`")
	println(tab + "params count: '$params_count'")
	
	for param in info.params {
		p.print_variable_type(param, indentSize + 1)
	}

	println(tab + "locals count: '$locals_count'")
	
	for local in info.locals {
		p.print_variable_type(local, indentSize + 1)
	}

	println(tab + "instructions count: '$instructions_count'")
	
	for inst in info.instructions {
		p.print_instruction(inst, indentSize + 1)
	}
}

fn (p PexFile) print_state(st State, indentSize int){
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }

	name := p.get_string(st.name)
	func_count := st.num_functions

	println(tab + "name: '$name'")
	println(tab + "functions count: '$func_count'")
	println(tab + "functions:")

	mut i := 0
	for i < func_count {
		p.print_func(st.functions[i], indentSize + 1)
		println("")
		i++
	}
}

fn (p PexFile) get_variable_data(v VariableData) string {
	mut data_str := ""

	match v.typ {
		0 {
			data_str = "none"
		}
		1 {
			data_str = "ident(${p.string_table[v.string_id]})"
		}
		2 {
			data_str = "string('${p.string_table[v.string_id]}')"
		}
		3 {
			data_str = "integer(${v.integer.str()})"
		}
		4 {
			data_str = "float(${v.float.str()})"
		}
		5 {
			data_str = "boolean(${v.boolean.hex()})"
		}
		else {
			panic("invalid data type")
		}
	}
	
	return data_str
}

fn (p PexFile) print_variable(v Variable, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }

	name := p.get_string(v.name)
	type_name := p.get_string(v.type_name)
	mut user_flags := if v.user_flags == 0 { "" } else { "0x" + v.user_flags.hex() }

	if v.user_flags & 0b0010 != 0 {
		user_flags = "Conditional"
	}
	
	println(tab + "name: '$name'")
	println(tab + "type name: '$type_name'")
	println(tab + "user flags: '$user_flags'")
	println(tab + "data: ${p.get_variable_data(v.data)}")
}

fn (p PexFile) print_property(prop Property, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }

	name := p.get_string(prop.name)
	type_name := p.get_string(prop.typ)
	docstring := p.get_string(prop.docstring)
	user_flags := "0x" + prop.user_flags.hex()
	flags := "0x" + prop.flags.hex()
	auto_var_name := p.get_string(prop.auto_var_name)

	println(tab + "name: '$name'")
	println(tab + "type name: '$type_name'")
	println(tab + "doc string: '$docstring'")
	println(tab + "user flags: '$user_flags'")
	println(tab + "flags: '$flags'")

	is_autovar := (prop.flags & 0b0100) != 0
	is_read := (prop.flags & 0b0001) != 0
	is_write := (prop.flags & 0b0010) != 0

	if is_autovar {
		println(tab + "auto var name: '$auto_var_name'")
	}

	if is_read && !is_autovar {
		println(tab + "read handler:")
		p.print_func_info(prop.read_handler, indentSize + 1)
	}

	if is_write && !is_autovar {
		println(tab + "write handler:")
		p.print_func_info(prop.write_handler, indentSize + 1)
	}

}

fn (p PexFile) print_object(obj Object, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }
	
	name := p.get_string(obj.name)
	size := "0x" + obj.size.hex()
	parent := p.get_string(obj.parent_class_name)
	doc := p.get_string(obj.docstring)
	user_flags := "0x" + obj.user_flags.hex()
	auto_state_name := p.get_string(obj.auto_state_name)

	vars_count := obj.num_variables
	props_count := obj.num_properties
	states_count := obj.num_states
	
	println(tab + "name: '$name'")
	println(tab + "size: $size")
	println(tab + "parent: '$parent'")
	println(tab + "doc: '$doc'")
	println(tab + "user flags: $user_flags")
	println(tab + "auto state name: '$auto_state_name'")
	
	println(tab + "variables count: '$vars_count'")
	println(tab + "variables:")
	mut i := 0
	for i < obj.num_variables {
		p.print_variable(obj.variables[i], indentSize + 1)
		println("")
		i++
	}

	println(tab + "properties count: '$props_count'")
	println(tab + "properties: ")
	i = 0
	for i < obj.num_properties {
		p.print_property(obj.properties[i], indentSize + 1)
		println("")
		i++
	}
	
	println(tab + "states count: '$states_count'")
	println(tab + "states:")
	
	i = 0
	for i < states_count {
		p.print_state(obj.states[i], indentSize + 1)
		i++
	}
}

fn (p PexFile) get_formated_script_flags() string {
	mut str := ""

	mut i := 0
	for i < p.user_flags.len {
		flag := p.user_flags[i]
		str += "0x" + flag.flag_index.hex()
		str += " - "
		str += p.get_string(flag.name)
		
		if i < p.user_flags.len - 1 {
			str += ", "
		}

		i++
	}

	return str
}

pub fn (p PexFile) print() {
	
	print_start_block("Header")

	println("magic_number: " + "0x" + p.magic_number.hex())
	println("major_version: " + p.major_version.str())
	println("minor_version: " + p.minor_version.str())
	println("game_id: " + p.game_id.str())
	println("compilation_time: " + p.compilation_time.str())
	
	println("src_file_name: " + p.src_file_name.str())
	println("user_name: " + p.user_name.str())
	println("machine_name: " + p.machine_name.str())

	println("flags: " + p.get_formated_script_flags())

	print_end_block("Header")

	print_start_block("String table")

	println("length: " + p.string_table_count.str())
	
	mut i := 0
	for i < p.string_table.len {
		str := p.string_table[i]
		print("string_table[$i] = '$str'")

		if i < p.string_table.len - 1 {
			print(", ")
		}
		else {
			println("")
		}

		i++
	}

	print_end_block("String table")

	if p.has_debug_info != 0 {
		print_start_block("Debug Info")

		println("modification_time: " +  p.modification_time.str())
		println("function_count: " +  p.function_count.str())
	
		println("functions: ")
		i = 0
		for i < p.function_count {
			p.print_debug_function(p.functions[i], 1)

			if i < p.function_count - 1 {
				print("\n")
			}

			//TODO print lines number

			i++
		}

		println("")
		print_end_block("Debug Info")
	}

	print_start_block("Objects")
	println("length: " + p.object_count.str())
	println("Objects:")
	i = 0
	for i < p.object_count {
		p.print_object(p.objects[i], 1)
		i++
	}
	println("\t")
	print_end_block("Objects")
}

pub fn (p PexFile) print_functions_list() {
	for object in p.objects {
		for state in object.states {
			for func in state.functions {
				println(p.get_string(func.name))
			}
		}
	}
}