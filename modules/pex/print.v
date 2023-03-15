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
	instruction_count := f.instruction_line_numbers.len
	//line_numbers := "..." //f.line_numbers

	println(tab + "object name: '$obj_name'")
	println(tab + "state name: '$state_name'")
	println(tab + "func name: '$fn_name'")
	println(tab + "type: $fn_type")
	println(tab + "instruction count: $instruction_count")
}

pub fn (p PexFile) print_instruction(inst Instruction, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }

	mut args := ""
	
	mut i := 0
	for i < inst.args.len {
		args += p.variable_value_to_str(inst.args[i])
		
		if i < inst.args.len - 1 {
			args += ", "
		}

		i++
	}

	println(tab + "opcode: '$inst.op', args: [$args]")
}

fn (p PexFile) print_variable_type(v VariableType, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }
	
	name := p.get_string(v.name)
	typ := p.get_string(v.typ)

	println(tab + "$typ $name")
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
	user_flags_hex :=  "0x" + info.user_flags.hex()
	user_flags_str :=  info.user_flags_str()
	flags_hex :=  "0x" + info.flags.hex()
	flags_str :=  info.flags_str()

	println(tab + "typ: '$typ'")
	println(tab + "doc: '$doc'")
	println(tab + "user_flags(${user_flags_hex}): ${user_flags_str}")
	println(tab + "flags(${flags_hex}): ${flags_str}")
	println(tab + "params count: '${info.params.len}'")
	
	for param in info.params {
		p.print_variable_type(param, indentSize + 1)
	}

	println(tab + "locals count: '${info.locals.len}'")
	
	for local in info.locals {
		p.print_variable_type(local, indentSize + 1)
	}

	println(tab + "instructions count: '${info.instructions.len}'")
	
	for inst in info.instructions {
		p.print_instruction(inst, indentSize + 1)
	}
}

fn (p PexFile) print_state(st State, indentSize int){
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }

	name := p.get_string(st.name)

	println(tab + "name: '$name'")
	println(tab + "functions[${st.functions.len}]:")

	mut i := 0
	for i < st.functions.len {
		p.print_func(st.functions[i], indentSize + 1)
		println("")
		i++
	}
}

fn (p PexFile) variable_value_to_str(v VariableValue) string {
	mut value_str := ""

	match v.typ {
		.null {
			value_str = "none"
		}
		.identifier {
			value_str = "ident(${p.string_table[v.to_string_id()]})"
		}
		.str {
			value_str = "string('${p.string_table[v.to_string_id()]}')"
		}
		.integer {
			value_str = "integer(${v.to_integer().str()})"
		}
		.float {
			value_str = "float(${v.to_float().str()})"
		}
		.boolean {
			value_str = "boolean(${v.to_boolean().hex()})"
		}
	}
	
	return value_str
}

fn (p PexFile) print_variable(v Variable, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }

	name := p.get_string(v.name)
	type_name := p.get_string(v.type_name)

	user_flags_hex := if v.user_flags == 0 { "0" } else { "0x" + v.user_flags.hex() }
	user_flags_str := v.user_flags_str()
	
	println(tab + "name: '$name'")
	println(tab + "type name: '$type_name'")
	println(tab + "user flags(${user_flags_hex}): $user_flags_str")
	println(tab + "data: ${p.variable_value_to_str(v.data)}")
}

fn (p PexFile) print_property(prop Property, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }

	name := p.get_string(prop.name)
	type_name := p.get_string(prop.typ)
	docstring := p.get_string(prop.docstring)
	user_flags_hex := "0x" + prop.user_flags.hex()
	user_flags_str := prop.user_flags_str()
	flags_hex := "0x" + prop.flags.hex()
	flags_str := prop.flags_str()
	auto_var_name := p.get_string(prop.auto_var_name)

	println(tab + "name: '$name'")
	println(tab + "type name: '$type_name'")
	println(tab + "doc string: '$docstring'")
	println(tab + "user flags($user_flags_hex): ${user_flags_str}")
	println(tab + "flags($flags_hex): '${flags_str}'")

	if prop.is_autovar() {
		println(tab + "auto var name: '$auto_var_name'")
	}
	else {
		if prop.is_read() {
			println(tab + "read handler:")
			p.print_func_info(prop.read_handler, indentSize + 1)
		}
		if prop.is_write() {
			println(tab + "write handler:")
			p.print_func_info(prop.write_handler, indentSize + 1)
		}
	}
}

fn (p PexFile) print_object(obj Object, indentSize int) {
	tab := if indentSize > 0 { strings.repeat(`	`, indentSize) } else { '' }
	
	name := p.get_string(obj.name)
	size := "0x" + obj.size.hex()
	parent := p.get_string(obj.parent_class_name)
	doc := p.get_string(obj.docstring)
	user_flags_hex := "0x" + obj.user_flags.hex()
	user_flags_str := obj.user_flags_str()
	auto_state_name := p.get_string(obj.auto_state_name)
	
	println(tab + "name: '$name'")
	println(tab + "size: $size")
	println(tab + "parent: '$parent'")
	println(tab + "doc: '$doc'")
	println(tab + "user flags(${user_flags_hex}): ${user_flags_str}")
	println(tab + "auto state name: '$auto_state_name'")
	
	println(tab + "variables[${obj.variables.len}]:")
	mut i := 0
	for i < obj.variables.len {
		p.print_variable(obj.variables[i], indentSize + 1)
		println("")
		i++
	}

	println(tab + "properties[${obj.properties.len}]: ")
	i = 0
	for i < obj.properties.len {
		p.print_property(obj.properties[i], indentSize + 1)
		println("")
		i++
	}
	
	println(tab + "states[${obj.states.len}]:")
	
	i = 0
	for i < obj.states.len {
		p.print_state(obj.states[i], indentSize + 1)
		i++
	}
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

	print_end_block("Header")

	print_start_block("String table")

	println("String table[${p.string_table.len}]:")
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
	
		println("functions[${p.functions.len}]: ")
		i = 0
		for i < p.functions.len {
			p.print_debug_function(p.functions[i], 1)

			if i < p.functions.len - 1 {
				print("\n")
			}

			//TODO print lines number

			i++
		}

		println("")
		print_end_block("Debug Info")
	}

	print_start_block("Objects")

	println("user_flags: ${p.user_flags_str()}")

	println("Objects[${p.objects.len}]:")
	i = 0
	for i < p.objects.len {
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