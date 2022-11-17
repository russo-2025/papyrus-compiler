module pex

//import encoding.binary
import os

import pex

pub struct Writer{
pub mut:
	path	string
	pex		&PexFile
	bytes	[]u8
}

pub fn write(path string, pex &PexFile) {
	mut w := Writer{
		path:	path
		pex:	pex
		bytes: 	[]u8{}
	}
	
	w.write_pex()

	mut file := os.create(path) or { panic(err) }
	file.write(w.bytes) or { panic(err) }
	file.close()
}

fn (mut w Writer) write_pex() {

	//header
	w.write(w.pex.magic_number)
	w.write(w.pex.major_version)
	w.write(w.pex.minor_version)
	w.write(w.pex.game_id)
	w.write(w.pex.compilation_time)
	
	w.write(w.pex.src_file_name)
	w.write(w.pex.user_name)
	w.write(w.pex.machine_name)
	
	//string table
	w.write(cast_int_to_u16(w.pex.string_table.len))

	for str in w.pex.string_table {
		w.write(str)
	}

	//debug info
	//w.write(0) //skip debug info

	//debug info обязательна?!
	w.write(1)
	w.write(1616261626)

	mut debug_fns := []DebugFunction{}

	for obj in w.pex.objects {
		for state in obj.states {
			for func in state.functions {
				debug_fns << DebugFunction{
					object_name: obj.name
					state_name: state.name
					function_name: func.name
					function_type: 0
					instruction_count: func.info.num_instructions
					line_numbers: []u16{}
				}
			}
		}
	}

	w.write(cast_int_to_u16(debug_fns.len))

	for func in debug_fns {
		w.write(func.object_name)
		w.write(func.state_name)
		w.write(func.function_name)
		w.write(0) //type
		w.write(func.instruction_count)

		mut i := 0
		for i < func.instruction_count {
			i++
			w.write(cast_int_to_u16(i))
		}
	}


	//user flags
	w.write(cast_int_to_u16(w.pex.user_flags.len))
	for flag in w.pex.user_flags {
		w.write(flag.name)
		w.write(flag.flag_index)
	}
	
	//objects
	assert w.pex.object_count == w.pex.objects.len
	
	w.write(cast_int_to_u16(w.pex.objects.len))
	
	for obj in w.pex.objects {
		w.write_object(obj)
	}
}

fn (mut w Writer) write_object(obj &pex.Object) {
	
	w.write(obj.name)
	start_pos := w.bytes.len
	w.write(obj.size)
	w.write(obj.parent_class_name)
	w.write(obj.docstring)
	w.write(obj.user_flags)
	w.write(obj.auto_state_name)

	//write variables
	assert obj.num_variables == obj.variables.len
	w.write(cast_int_to_u16(obj.variables.len))
	for var in obj.variables {
		w.write_variable(var)
	}

	//write properties
	assert obj.num_properties == obj.properties.len
	w.write(cast_int_to_u16(obj.properties.len))
	for prop in obj.properties {
		w.write_property(prop)
	}

	//write states
	assert obj.num_states == obj.states.len
	w.write(obj.num_states)
	for state in obj.states {
		w.write_state(state)
	}

	//write object size
	size := w.bytes.len - start_pos
	w.bytes[start_pos] = u8(size>>u32(24))
	w.bytes[start_pos + 1] = u8(size>>u32(16))
	w.bytes[start_pos + 2] = u8(size>>u32(8))
	w.bytes[start_pos + 3] = u8(size)
}

fn (mut w Writer) write_state(state pex.State) {

	w.write(state.name)
	
	assert state.num_functions == state.functions.len
	w.write(state.num_functions)
	
	for func in state.functions {
		w.write_function(func)
	}
}

[inline]
fn (mut w Writer) write_function_info(info pex.FunctionInfo) {
	w.write(info.return_type)
	w.write(info.docstring)

	w.write(info.user_flags)
	w.write(info.flags)

	assert info.num_params == info.params.len
	w.write(info.num_params)
	
	for param in info.params {
		w.write_variable_type(param)
	}

	assert info.num_locals == info.locals.len
	w.write(info.num_locals)

	for local in info.locals {
		w.write_variable_type(local)
	}

	assert info.num_instructions == info.instructions.len
	w.write(info.num_instructions)

	for inst in info.instructions {
		w.write_instruction(inst)
	}
}

fn (mut w Writer) write_function(func pex.Function) {
	w.write(func.name)
	w.write_function_info(func.info)
}

[inline]
fn (mut w Writer) write_instruction(inst pex.Instruction) {
	w.write(byte(inst.op))
	
	mut i := 0
	for i < inst.args.len {
		arg := inst.args[i]
		w.write_variable_data(arg)
		i++
	}
}

[inline]
fn (mut w Writer) write_variable(var pex.Variable) {
	w.write(var.name)
	w.write(var.type_name)
	w.write(var.user_flags)
	w.write_variable_data(var.data)
}

[inline]
fn (mut w Writer) write_property(prop pex.Property) {
	w.write(prop.name)
	w.write(prop.typ)
	w.write(prop.docstring)
	w.write(prop.user_flags)
	w.write(prop.flags)

	if prop.flags & 0b0100 != 0 {
		w.write(prop.auto_var_name)
	}
	else {
		if prop.flags & 0b0001 != 0 {
			w.write_function_info(prop.read_handler)
		}
		if prop.flags & 0b0010 != 0 {
			w.write_function_info(prop.write_handler)
		}
	}
}

[inline]
fn (mut w Writer) write_variable_data(data pex.VariableData) {
	w.write(data.typ)

	match data.typ {
		0 {}
		1,
		2 {
			w.write(data.string_id)
		}
		3 {
			w.write(data.integer)
		}
		4 {
			w.write(data.float)
		}
		5 {
			w.write(data.boolean)
		}
		else {
			panic("pex.Writer: invalid variable data type: 0x${data.typ.hex()}")
		}
	}
}

[inline]
fn (mut w Writer) write_variable_type(typ pex.VariableType) {
	w.write(typ.name)
	w.write(typ.typ)
}