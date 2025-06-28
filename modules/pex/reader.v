module pex

import os
import papyrus.util

pub struct Reader{
pub mut:
	bytes	[]u8
	pos		int
	pex		&PexFile
}

pub fn read_from_file(path string) &PexFile {
	if !os.is_file(path) {
		util.fatal_error("invalid file path: `${path}`")
	}

	if os.file_ext(path) != ".pex" {
		util.fatal_error("unexpected file extension `*${os.file_ext(path)}` , expecting `*.pex`")
	}

	mut bytes := os.read_bytes(path) or {
		util.fatal_error("failed to read bytes: ${err}")
	}

	assert bytes.len > 0
	
	return read(bytes)
}

pub fn read(bytes []u8) &PexFile {
	assert bytes.len > 0
	
	mut r := Reader{
		bytes: bytes
		pex: &PexFile{}
	}

	r.read_pex() or { r.error(err.msg()) }

	return r.pex
}

fn (mut r Reader) read_pex() ! {
	r.pex.magic_number = r.read[u32]()

	if r.pex.magic_number != pex.le_magic_number {
		return error("invalid magic number(${r.pex.magic_number})")
	}

	r.pex.major_version = r.read[u8]()
	r.pex.minor_version = r.read[u8]()
	game_id := r.read[u16]()
	r.pex.game_id = unsafe { pex.GameType(game_id) }

	if r.pex.game_id != .skyrim {
		return error("invalid game id(${game_id})")
	} 

	r.pex.compilation_time = r.read_time()
	r.pex.src_file_name = r.read[string]()
	r.pex.user_name = r.read[string]()
	r.pex.machine_name = r.read[string]()
	string_table_len := r.read[u16]()

	mut i := 0
	for i < string_table_len {
		r.pex.string_table << r.read[string]()
		i++
	}
	
	r.pex.has_debug_info = r.read[u8]()
	
	if r.pex.has_debug_info != 0
	{
		r.pex.modification_time = r.read_time()
		functions_len := r.read[u16]()
		
		i = 0
		for i < functions_len {
			mut d := DebugFunction{}

			d.object_name = r.read_string_ref() or { return err }
			d.state_name = r.read_string_ref() or { return err }
			d.function_name = r.read_string_ref() or { return err }
			d.function_type = r.read[u8]()
			instruction_line_numbers_len := r.read[u16]()

			mut k := 0
			for k < instruction_line_numbers_len {
				d.instruction_line_numbers << r.read[u16]()
				k++
			}

			r.pex.functions << d
			i++
		}
	}

	user_flag_len := r.read[u16]()

	i = 0
	for i < user_flag_len {
		name := r.read_string_ref() or { return err }
		flag_index := r.read[u8]()

		r.pex.user_flags << UserFlag { 
			name: name, 
			flag_index: flag_index
		}

		i++
	}

	objects_len := r.read[u16]()

	i = 0
	for i < objects_len {
		r.pex.objects << r.read_object() or { return err }
		i++
	}

	if r.pos != r.bytes.len {
		return error("number of bytes read(${r.pos}) != total bytes(${r.bytes.len})")
	}
}

fn (mut r Reader) read_object() !&Object {
	mut obj := Object{}

	obj.name = r.read_string_ref() or { return err }
	obj.size = r.read[u32]()

	obj.parent_class_name = r.read_string_ref() or { return err }
	obj.docstring = r.read_string_ref() or { return err }
	obj.user_flags = r.read[u32]()
	obj.auto_state_name = r.read_string_ref() or { return err }
	
	variables_len := r.read[u16]()

	mut i := 0
	for i < variables_len {
		obj.variables << r.read_variable() or { return err }
		i++
	}

	properties_len := r.read[u16]()

	i = 0
	for i < properties_len {
		obj.properties << r.read_property() or { return err }
		i++
	}

	states_len := r.read[u16]()

	i = 0
	for i < states_len {
		obj.states << r.read_state() or { return err }
		i++
	}
	return &obj
}

fn (mut r Reader) read_state() !&State{
	mut s := State{}

	s.name = r.read_string_ref() or { return err }
	functions_len := r.read[u16]()

	mut i := 0
	for i < functions_len {
		s.functions << r.read_named_function() or { return err }
		i++
	}
	return &s
}

fn (mut r Reader) read_named_function() !&Function{
	mut n := Function{}

	n.name = r.read_string_ref() or { return err }
	n.info = r.read_function() or { return err }

	return &n
}

fn (mut r Reader) read_property() !&Property{
	mut p := Property{}
	
	p.name = r.read[u16]()
	p.typ = r.read[u16]()
	p.docstring = r.read[u16]()
	p.user_flags = r.read[u32]()
	p.flags = r.read[u8]()

	if p.is_autovar() {
		p.auto_var_name = r.read[u16]()
	}
	else {
		if p.is_read() {
			p.read_handler = r.read_function() or { return err }
		}
		if p.is_write() {
			p.write_handler = r.read_function() or { return err }
		}
	}
	
	return &p
}

fn (mut r Reader) read_function() !FunctionInfo{
	mut func := FunctionInfo{}
	
	func.return_type = r.read_string_ref() or { return err }
	func.docstring = r.read_string_ref() or { return err }
	func.user_flags = r.read[u32]()
	func.flags = r.read[u8]()
	
	params_len := r.read[u16]()
	mut i := 0
	for i < params_len {
		func.params << r.read_variable_type() or { return err }
		i++
	}

	locals_len := r.read[u16]()
	i = 0
	for i < locals_len {
		func.locals << r.read_variable_type() or { return err }
		i++
	}

	instructions_len := r.read[u16]()
	i = 0

	for i < instructions_len {
		func.instructions << r.read_instruction() or { return err }
		i++
	}

	return func
}

fn (mut r Reader) read_instruction() !Instruction{
	mut inst := Instruction{}

	inst.op = opcode_from_byte(r.read[u8]())
	mut len := inst.op.get_count_arguments()

	mut i := 0
	for i < len{
		inst.args << r.read_variable_value() or { return err }
		i++
	}

	match inst.op {
		.callmethod,
		.callparent,
		.callstatic {
			
			value_len := r.read_variable_value() or { return err }
			inst.args << value_len
			len = value_len.to_integer()
			
			i = 0
			for i < len {
				inst.args << r.read_variable_value() or { return err }
				i++
			}
		}
		else {}
	}
	
	return inst
}

fn (mut r Reader) read_variable_type() !VariableType{
	mut t := VariableType{}
	t.name = r.read_string_ref() or { return err }
	t.typ = r.read_string_ref() or { return err }

	return t
}

fn (mut r Reader) read_variable() !&Variable{
	mut var := Variable{}

	var.name = r.read_string_ref() or { return err }
	var.type_name = r.read_string_ref() or { return err }
	var.user_flags = r.read[u32]()
	var.data = r.read_variable_value() or { return err }

	return &var
}

fn (mut r Reader) read_variable_value() !VariableValue {
	mut value := VariableValue{}

	typ := r.read[u8]()
	assert typ <= 5
	value.typ = unsafe { pex.ValueType(typ) }

	match value.typ {
		.null {}
		.identifier,
		.str {
			value.data.string_id = r.read_string_ref() or { return err }
		}
		.integer {
			value.data.integer = r.read[int]()
		}
		.float {
			value.data.float = r.read[f32]()
		}
		.boolean {
			value.data.boolean = r.read[u8]()
		}
	}

	return value
}

fn (mut r Reader) error(msg string) {
	util.fatal_error("Reader error: ${msg}")
}