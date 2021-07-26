module pex

import os

import pref

struct Reader{
pub mut:
	path	string
	bytes	[]byte
	pos		int
	pex		&PexFile
}

pub fn read(pref &pref.Preferences) &PexFile {
	mut f := PexFile{}

	path := pref.paths[0]

	if !os.is_file(path) {
		eprintln("invalid file path: `$path`")
		exit(1)
	}

	if os.file_ext(path) != ".pex" {
		eprintln("unexpected file extension `*${os.file_ext(path)}` , expecting `*.pex`")
		exit(1)
	}

	println("read file: `$path`")
	
	mut r := Reader{
		path:	path
		bytes:	os.read_bytes(path) or { return &PexFile{} }
		pex:	&f
	}
	
	f.magic_number = r.read_u32()
	f.major_version = r.read_byte()
	f.minor_version = r.read_byte()
	f.game_id = r.read_u16()
	f.compilation_time = r.read_time()
	f.src_file_name = r.read_string()
	f.user_name = r.read_string()
	f.machine_name = r.read_string()
	f.string_table_count = r.read_u16()

	mut i := 0
	for i < f.string_table_count {
		f.string_table << r.read_string()
		i++
	}

	f.has_debug_info = r.read_byte()
	
	if f.has_debug_info != 0
	{
		f.modification_time = r.read_time()
		f.function_count = r.read_u16()
		
		i = 0
		for i < f.function_count {
			mut d := DebugFunction{}

			d.object_name_index = r.read_string_ref() or {
				r.error(err.msg)
				return r.pex
			}
			d.state_name_index = r.read_string_ref() or {
				r.error(err.msg)
				return r.pex
			}
			d.function_name_index = r.read_string_ref() or {
				r.error(err.msg)
				return r.pex
			}
			d.function_type = r.read_byte()
			d.instruction_count = r.read_u16()

			mut k := 0
			for k < d.instruction_count {
				d.line_numbers << r.read_u16()
				k++
			}

			f.functions << d
			i++
		}
	}

	f.user_flag_count = r.read_u16()

	i = 0
	for i < f.user_flag_count{
		name_index := r.read_string_ref() or {
			r.error(err.msg)
			return r.pex
		}
		flag_index := r.read_byte()

		f.user_flags << UserFlag { 
			name_index: name_index, 
			flag_index: flag_index
		}

		i++
	}

	f.object_count = r.read_u16()

	i = 0
	for i < f.object_count{
		f.objects << r.read_object() or {
			r.error(err.msg)
			return r.pex
		}
		i++
	}

	if r.pos != r.bytes.len {
		r.error("number of bytes read($r.pos) != total bytes($r.bytes.len)")
		return r.pex
	}

	r.pex.print()
	return r.pex
}

fn (mut r Reader) read_object() ?Object{


	mut obj := Object{}

	obj.name_index = r.read_string_ref() or { return err }
	obj.size = r.read_u32()
	obj.data = r.read_object_data() or { return err }
	return obj
}

fn (mut r Reader) read_object_data() ?ObjectData{
	mut data := ObjectData{}

	data.parent_class_name = r.read_string_ref() or { return err }
	data.docstring = r.read_string_ref() or { return err }
	data.user_flags = r.read_u32()
	data.auto_state_name = r.read_string_ref() or { return err }
	
	data.num_variables = r.read_u16()

	mut i := 0
	for i < data.num_variables{
		data.variables << r.read_variable() or { return err }
		i++
	}

	data.num_properties = r.read_u16()

	i = 0
	for i < data.num_properties{
		data.properties << r.read_property() or { return err }
		i++
	}
	data.num_states = r.read_u16()

	i = 0
	for i < data.num_states{
		data.states << r.read_state() or { return err }
		i++
	}

	return data
}

fn (mut r Reader) read_state() ?State{
	mut s := State{}

	s.name = r.read_string_ref() or { return err }
	s.num_functions = r.read_u16()

	mut i := 0
	for i < s.num_functions{
		s.functions << r.read_named_function() or { return err }
		i++
	}
	return s
}

fn (mut r Reader) read_named_function() ?Function{
	mut n := Function{}

	n.name = r.read_string_ref() or { return err }
	n.info = r.read_function() or { return err }

	return n
}

fn (mut r Reader) read_property() ?Property{
	mut p := Property{}
	
	p.name = r.read_u16()
	p.typ = r.read_u16()
	p.docstring = r.read_u16()
	p.user_flags = r.read_u32()
	p.flags = r.read_byte()
/*
	if (p.flags & 4) != 0 {
		p.auto_var_name = r.read_u16()
	}

	if (p.flags & 5) == 1 {
		p.read_handler = r.read_function() or { return err }
	}
	if (p.flags & 6) == 2 {=
		p.write_handler = r.read_function() or { return err }
	}
*/
	if p.flags & 0b0100 != 0 {
		p.auto_var_name = r.read_u16()
	}
	else {
		if p.flags & 0b0001 != 0 {
			p.read_handler = r.read_function() or { return err }
		}
		if p.flags & 0b0010 != 0 {
			p.write_handler = r.read_function() or { return err }
		}
	}
	
	return p
}

fn (mut r Reader) read_function() ?FunctionInfo{
	mut func := FunctionInfo{}
	
	func.return_type = r.read_string_ref() or { return err }
	func.docstring = r.read_string_ref() or { return err }
	func.user_flags = r.read_u32()
	func.flags = r.read_byte()
	
	func.num_params = r.read_u16()
	mut i := 0
	for i < func.num_params{
		func.params << r.read_variable_type() or { return err }
		i++
	}

	func.num_locals = r.read_u16()
	i = 0
	for i < func.num_locals{
		func.locals << r.read_variable_type() or { return err }
		i++
	}

	func.num_instructions = r.read_u16()
	i = 0

	for i < func.num_instructions {
		func.instructions << r.read_instruction() or { return err }
		i++
	}

	return func
}

fn (mut r Reader) read_instruction() ?Instruction{
	mut inst := Instruction{}
	inst.op = r.read_byte()

	if inst.op > 0x23 {
		return error("invalid opcode: 0x" + inst.op.hex())
	}

	mut len := get_count_arguments(OpCode(inst.op))

	mut i := 0
	for i < len{
		inst.args << r.read_variable_data() or { return err }
		i++
	}

	match OpCode(inst.op){
		.callmethod,
		.callparent,
		.callstatic {
			
			r.read_byte() //wtf??
			len = int(r.read_u32())
			
			i = 0
			for i < len{
				inst.args << r.read_variable_data() or { return err }
				i++
			}
		}
		else {}
	}
	
	return inst
}

//read_variable_data
fn (mut r Reader) read_variable_type() ?VariableType{
	mut t := VariableType{}
	t.name = r.read_string_ref() or { return err }
	t.typ = r.read_string_ref() or { return err }

	return t
}

fn (mut r Reader) read_variable() ?Variable{
	mut var := Variable{}

	var.name = r.read_string_ref() or { return err }
	var.type_name = r.read_string_ref() or { return err }
	var.user_flags = r.read_u32()
	var.data = r.read_variable_data() or { return err }

	return var
}

fn (mut r Reader) read_variable_data() ?VariableData{
	mut data := VariableData{}

	data.typ = r.read_byte()

	match data.typ {
		0 {} //null

		1, //identifier
		2 {//string
			data.string_id = r.read_string_ref() or { return err }
		}

		3 {//integer
			data.integer = r.read_int()
		}

		4 {//float
			data.float = r.read_f32()
		}

		5 {//bool
			data.boolean = r.read_byte()
		}
		else{}
	}
	return data
}

fn (mut r Reader) error(msg string) {
	eprintln("Reader error: " + msg)
}