module pex

//import encoding.binary
import os

import pex

struct Writer{
pub mut:
	path	string
	pex		&PexFile
	file	os.File
	bytes	[]byte
}

pub fn write(path string, pex &PexFile) {
	mut w := Writer{
		path:	path
		pex:	pex
		bytes: 	[]byte{}
		file: os.create(path) or { panic(err) }
	}
	
	w.write_pex()
	w.file.write(w.bytes) or { panic(err) }
	w.file.close()
}

fn (mut w Writer) write_pex() {

	//header
	w.write_u32(w.pex.magic_number)
	w.write_byte(w.pex.major_version)
	w.write_byte(w.pex.minor_version)
	w.write_u16(w.pex.game_id)
	w.write_u64(w.pex.compilation_time)
	
	w.write_string(w.pex.src_file_name)
	w.write_string(w.pex.user_name)
	w.write_string(w.pex.machine_name)
	
	//string table
	w.write_int_to_u16(w.pex.string_table.len)

	for str in w.pex.string_table {
		w.write_string(str)
	}

	//debug info
	//w.write_byte(0) //skip debug info

	//debug info обязательна?!
	w.write_byte(1)
	w.write_u64(1616261626)

	mut debug_fns := []DebugFunction{}

	for obj in w.pex.objects {
		for state in obj.data.states {
			for func in state.functions {
				debug_fns << DebugFunction{
					object_name_index: obj.name_index
					state_name_index: state.name
					function_name_index: func.name
					function_type: 0
					instruction_count: func.info.num_instructions
					line_numbers: []u16{}
				}
			}
		}
	}

	w.write_int_to_u16(debug_fns.len)

	for func in debug_fns {
		w.write_u16(func.object_name_index)
		w.write_u16(func.state_name_index)
		w.write_u16(func.function_name_index)
		w.write_byte(0) //type
		w.write_u16(func.instruction_count)

		mut i := 0
		for i < func.instruction_count {
			i++
			w.write_int_to_u16(i)
		}
	}


	//user flags
	w.write_int_to_u16(w.pex.user_flags.len)
	for flag in w.pex.user_flags {
		w.write_u16(flag.name_index)
		w.write_byte(flag.flag_index)
	}
	
	//objects
	assert w.pex.object_count == w.pex.objects.len
	
	w.write_int_to_u16(w.pex.objects.len)
	
	for obj in w.pex.objects {
		w.write_object(obj)
	}
}

fn (mut w Writer) write_object(obj &pex.Object) {
	
	w.write_string_ref(obj.name_index)
	start_pos := w.bytes.len
	w.write_u32(obj.size)
	w.write_string_ref(obj.data.parent_class_name)
	w.write_string_ref(obj.data.docstring)
	w.write_u32(obj.data.user_flags)
	w.write_string_ref(obj.data.auto_state_name)

	//write variables
	assert obj.data.num_variables == obj.data.variables.len
	w.write_int_to_u16(obj.data.variables.len)
	for var in obj.data.variables {
		w.write_variable(var)
	}

	//write properties
	assert obj.data.num_properties == obj.data.properties.len
	w.write_int_to_u16(obj.data.properties.len)
	for prop in obj.data.properties {
		w.write_property(prop)
	}

	//write states
	assert obj.data.num_states == obj.data.states.len
	w.write_u16(obj.data.num_states)
	for state in obj.data.states {
		w.write_state(state)
	}

	//write object size
	size := w.bytes.len - start_pos
	w.bytes[start_pos] = byte(size>>u32(24))
	w.bytes[start_pos + 1] = byte(size>>u32(16))
	w.bytes[start_pos + 2] = byte(size>>u32(8))
	w.bytes[start_pos + 3] = byte(size)
}

fn (mut w Writer) write_state(state pex.State) {

	w.write_string_ref(state.name)
	
	assert state.num_functions == state.functions.len
	w.write_u16(state.num_functions)
	
	for func in state.functions {
		w.write_function(func)
	}
}

[inline]
fn (mut w Writer) write_function_info(info pex.FunctionInfo) {
	w.write_string_ref(info.return_type)
	w.write_string_ref(info.docstring)

	w.write_u32(info.user_flags)
	w.write_byte(info.flags)

	assert info.num_params == info.params.len
	w.write_u16(info.num_params)
	
	for param in info.params {
		w.write_variable_type(param)
	}

	assert info.num_locals == info.locals.len
	w.write_u16(info.num_locals)

	for local in info.locals {
		w.write_variable_type(local)
	}

	assert info.num_instructions == info.instructions.len
	w.write_u16(info.num_instructions)

	for inst in info.instructions {
		w.write_instruction(inst)
	}
}

fn (mut w Writer) write_function(func pex.Function) {
	w.write_string_ref(func.name)
	w.write_function_info(func.info)
}

[inline]
fn (mut w Writer) write_instruction(inst pex.Instruction) {
	w.write_byte(inst.op)

	mut i := 0
	for i < inst.args.len {
		arg := inst.args[i]
		w.write_variable_data(arg)
		i++
	}
}

[inline]
fn (mut w Writer) write_variable(var pex.Variable) {
	w.write_string_ref(var.name)
	w.write_string_ref(var.type_name)
	w.write_u32(var.user_flags)
	w.write_variable_data(var.data)
}

[inline]
fn (mut w Writer) write_property(prop pex.Property) {
	w.write_string_ref(prop.name)
	w.write_string_ref(prop.typ)
	w.write_string_ref(prop.docstring)
	w.write_u32(prop.user_flags)
	w.write_byte(prop.flags)

	if prop.flags & 0b0100 != 0 {
		w.write_string_ref(prop.auto_var_name)
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
	w.write_byte(data.typ)

	match data.typ {
		0 {}
		1,
		2 {
			w.write_u16(data.string_id)
		}
		3 {
			w.write_int(data.integer)
		}
		4 {
			w.write_f32(data.float)
		}
		5 {
			w.write_byte(data.boolean)
		}
		else {
			panic("pex.Writer: invalid variable data type: 0x${data.typ.hex()}")
		}
	}
}

[inline]
fn (mut w Writer) write_variable_type(typ pex.VariableType) {
	w.write_string_ref(typ.name)
	w.write_string_ref(typ.typ)
}