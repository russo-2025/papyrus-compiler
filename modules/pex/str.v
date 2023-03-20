
module pex

import strings

struct PexStrBuilder {
	pex_file	&PexFile
mut: 
	builder		strings.Builder
	indent_size	int
}

fn (mut b PexStrBuilder) write(str string) {
	b.builder.write_string(str)
}

fn (mut b PexStrBuilder) writeln(str string) {
	if b.indent_size > 0 {
		b.write(strings.repeat(`	`, b.indent_size))
	}

	b.builder.writeln(str)
}

fn (mut b PexStrBuilder) start_block(name string) {
	b.writeln("==============================${name}==============================")
}

fn (mut b PexStrBuilder) end_block(name string) {
	b.writeln("============================================================")
}

fn (mut b PexStrBuilder) object_to_string(obj &Object) {
	name := b.pex_file.get_string(obj.name)
	size := "0x" + obj.size.hex()
	parent := b.pex_file.get_string(obj.parent_class_name)
	doc := b.pex_file.get_string(obj.docstring)
	user_flags_hex := "0x" + obj.user_flags.hex()
	user_flags_str := obj.user_flags_str()
	auto_state_name := b.pex_file.get_string(obj.auto_state_name)
	
	b.writeln("name: '${name}'")
	b.writeln("size: ${size}")
	b.writeln("parent: '${parent}'")
	b.writeln("doc: '${doc}'")
	b.writeln("user flags(${user_flags_hex}): ${user_flags_str}")
	b.writeln("auto state name: '$auto_state_name'")
	
	b.writeln("variables[${obj.variables.len}]:")
	b.indent_size++
	mut i := 0
	for i < obj.variables.len {
		b.var_to_string(obj.variables[i])
		b.writeln("")
		i++
	}
	b.indent_size--

	b.writeln("properties[${obj.properties.len}]: ")
	b.indent_size++
	i = 0
	for i < obj.properties.len {
		b.prop_to_string(obj.properties[i])
		b.writeln("")
		i++
	}
	b.indent_size--
	
	b.writeln("states[${obj.states.len}]:")
	b.indent_size++
	i = 0
	for i < obj.states.len {
		b.state_to_string(obj.states[i])
		i++
	}
	b.indent_size--
}

fn (mut b PexStrBuilder) var_to_string(var &Variable) {
	name := b.pex_file.get_string(var.name)
	type_name := b.pex_file.get_string(var.type_name)

	user_flags_hex := if var.user_flags == 0 { "0" } else { "0x" + var.user_flags.hex() }
	user_flags_str := var.user_flags_str()

	data := var.data.to_string(b.pex_file)
	
	b.writeln("name: '${name}'")
	b.writeln("type name: '${type_name}'")
	b.writeln("user flags(${user_flags_hex}): $user_flags_str")
	b.writeln("data: ${data}")
}

fn (mut b PexStrBuilder) prop_to_string(prop &Property) {
	name := b.pex_file.get_string(prop.name)
	type_name := b.pex_file.get_string(prop.typ)
	docstring := b.pex_file.get_string(prop.docstring)
	user_flags_hex := "0x" + prop.user_flags.hex()
	user_flags_str := prop.user_flags_str()
	flags_hex := "0x" + prop.flags.hex()
	flags_str := prop.flags_str()
	auto_var_name := b.pex_file.get_string(prop.auto_var_name)

	b.writeln("name: '$name'")
	b.writeln("type name: '$type_name'")
	b.writeln("doc string: '$docstring'")
	b.writeln("user flags($user_flags_hex): ${user_flags_str}")
	b.writeln("flags($flags_hex): '${flags_str}'")

	if prop.is_autovar() {
		b.writeln("auto var name: '$auto_var_name'")
	}
	else {
		if prop.is_read() {
			b.writeln("read handler:")
			b.indent_size++
			b.func_info_to_string(prop.read_handler)
			b.indent_size--
		}
		if prop.is_write() {
			b.writeln("write handler:")
			b.indent_size++
			b.func_info_to_string(prop.write_handler)
			b.indent_size--
		}
	}
}

fn (mut b PexStrBuilder) state_to_string(state &State) {
	name := b.pex_file.get_string(state.name)

	b.writeln("name: '$name'")
	b.writeln("functions[${state.functions.len}]:")

	b.indent_size++
	mut i := 0
	for i < state.functions.len {
		b.func_to_string(state.functions[i])
		b.writeln("")
		i++
	}
	b.indent_size--
}

fn (mut b PexStrBuilder) func_info_to_string(info &FunctionInfo) {
	typ :=  b.pex_file.get_string(info.return_type)
	doc :=  b.pex_file.get_string(info.docstring)
	user_flags_hex :=  "0x" + info.user_flags.hex()
	user_flags_str :=  info.user_flags_str()
	flags_hex :=  "0x" + info.flags.hex()
	flags_str :=  info.flags_str()

	b.writeln("typ: '$typ'")
	b.writeln("doc: '$doc'")
	b.writeln("user_flags(${user_flags_hex}): ${user_flags_str}")
	b.writeln("flags(${flags_hex}): ${flags_str}")
	b.writeln("params count: '${info.params.len}'")
	
	b.indent_size++
	for param in info.params {
		b.writeln(param.to_string(b.pex_file))
	}
	b.indent_size--

	b.writeln("locals count: '${info.locals.len}'")
	
	b.indent_size++
	for local in info.locals {
		b.writeln(local.to_string(b.pex_file))
	}
	b.indent_size--

	b.writeln("instructions count: '${info.instructions.len}'")
	
	b.indent_size++
	for inst in info.instructions {
		b.writeln(inst.to_string(b.pex_file))
	}
	b.indent_size--
}

fn (mut b PexStrBuilder) func_to_string(func &Function) {
	name :=  b.pex_file.get_string(func.name)
	b.writeln("name: '${name}'")
	b.func_info_to_string(func.info)
}

fn (mut b PexStrBuilder) debug_func_to_string(d_func &DebugFunction) {
	obj_name := b.pex_file.get_string(d_func.object_name)
	state_name := b.pex_file.get_string(d_func.state_name)
	fn_name := b.pex_file.get_string(d_func.function_name)
	fn_type := d_func.function_type
	instruction_count := d_func.instruction_line_numbers.len
	//line_numbers := "..." //d_func.line_numbers

	b.writeln("object name: '${obj_name}'")
	b.writeln("state name: '${state_name}'")
	b.writeln("func name: '${fn_name}'")
	b.writeln("type: ${fn_type}")
	b.writeln("instruction count: ${instruction_count}")
}

pub fn (p PexFile) str() string {
	mut b := PexStrBuilder {
		pex_file: p
		builder: strings.new_builder(4000)
	}

	b.start_block("Header")

	b.writeln("magic_number: " + "0x" + p.magic_number.hex())
	b.writeln("major_version: " + p.major_version.str())
	b.writeln("minor_version: " + p.minor_version.str())
	b.writeln("game_id: " + p.game_id.str())
	b.writeln("compilation_time: " + p.compilation_time.str())
	b.writeln("src_file_name: " + p.src_file_name.str())
	b.writeln("user_name: " + p.user_name.str())
	b.writeln("machine_name: " + p.machine_name.str())

	b.end_block("Header")

	b.start_block("String table")
	b.writeln("String table[${p.string_table.len}]:")
	mut i := 0
	for i < p.string_table.len {
		str := p.string_table[i]
		b.write("string_table[$i] = '$str'")

		if i < p.string_table.len - 1 {
			b.write(", ")
		}
		else {
			b.writeln("\n")
		}

		i++
	}
	b.end_block("String table")


	if p.has_debug_info != 0 {
		b.start_block("Debug Info")

		b.writeln("modification_time: " +  p.modification_time.str())
	
		b.writeln("functions[${p.functions.len}]: ")
		b.indent_size++
		i = 0
		for i < p.functions.len {
			b.debug_func_to_string(p.functions[i])

			if i < p.functions.len - 1 {
				b.write("\n")
			}

			//TODO print lines number

			i++
		}

		b.writeln("")
		b.indent_size--

		b.end_block("Debug Info")
	}

	b.start_block("Objects")

	b.writeln("Objects[${p.objects.len}]:")

	b.indent_size++
	i = 0
	for i < p.objects.len {
		b.object_to_string(p.objects[i])
		i++
	}
	b.writeln("\t")
	b.indent_size--

	b.end_block("Objects")

	return b.builder.str()
}