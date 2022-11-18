module pex

import os

import pref

pub struct Reader{
pub mut:
	path	string
	bytes	[]u8
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
	
	f.magic_number = r.read<u32>()
	f.major_version = r.read<byte>()
	f.minor_version = r.read<byte>()
	f.game_id = r.read<u16>()
	f.compilation_time = r.read_time()
	f.src_file_name = r.read<string>()
	f.user_name = r.read<string>()
	f.machine_name = r.read<string>()
	f.string_table_count = r.read<u16>()

	mut i := 0
	for i < f.string_table_count {
		f.string_table << r.read<string>()
		i++
	}
	
	f.has_debug_info = r.read<byte>()
	
	if f.has_debug_info != 0
	{
		f.modification_time = r.read_time()
		f.function_count = r.read<u16>()
		
		i = 0
		for i < f.function_count {
			mut d := DebugFunction{}

			d.object_name = r.read_string_ref() or {
				r.error(err.msg())
				return r.pex
			}
			d.state_name = r.read_string_ref() or {
				r.error(err.msg())
				return r.pex
			}
			d.function_name = r.read_string_ref() or {
				r.error(err.msg())
				return r.pex
			}
			d.function_type = r.read<byte>()
			d.instruction_count = r.read<u16>()

			mut k := 0
			for k < d.instruction_count {
				d.line_numbers << r.read<u16>()
				k++
			}

			f.functions << d
			i++
		}
	}

	f.user_flag_count = r.read<u16>()

	i = 0
	for i < f.user_flag_count{
		name := r.read_string_ref() or {
			r.error(err.msg())
			return r.pex
		}
		flag_index := r.read<byte>()

		f.user_flags << UserFlag { 
			name: name, 
			flag_index: flag_index
		}

		i++
	}

	f.object_count = r.read<u16>()

	i = 0
	for i < f.object_count{
		f.objects << r.read_object() or {
			r.error(err.msg())
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

	obj.name = r.read_string_ref() or { return err }
	obj.size = r.read<u32>()

	obj.parent_class_name = r.read_string_ref() or { return err }
	obj.docstring = r.read_string_ref() or { return err }
	obj.user_flags = r.read<u32>()
	obj.auto_state_name = r.read_string_ref() or { return err }
	
	obj.num_variables = r.read<u16>()

	mut i := 0
	for i < obj.num_variables{
		obj.variables << r.read_variable() or { return err }
		i++
	}

	obj.num_properties = r.read<u16>()

	i = 0
	for i < obj.num_properties{
		obj.properties << r.read_property() or { return err }
		i++
	}
	obj.num_states = r.read<u16>()

	i = 0
	for i < obj.num_states{
		obj.states << r.read_state() or { return err }
		i++
	}
	return obj
}

fn (mut r Reader) read_state() ?State{
	mut s := State{}

	s.name = r.read_string_ref() or { return err }
	s.num_functions = r.read<u16>()

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
	
	p.name = r.read<u16>()
	p.typ = r.read<u16>()
	p.docstring = r.read<u16>()
	p.user_flags = r.read<u32>()
	p.flags = r.read<byte>()

	if p.flags & 0b0100 != 0 {
		p.auto_var_name = r.read<u16>()
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
	func.user_flags = r.read<u32>()
	func.flags = r.read<byte>()
	
	func.num_params = r.read<u16>()
	mut i := 0
	for i < func.num_params{
		func.params << r.read_variable_type() or { return err }
		i++
	}

	func.num_locals = r.read<u16>()
	i = 0
	for i < func.num_locals{
		func.locals << r.read_variable_type() or { return err }
		i++
	}

	func.num_instructions = r.read<u16>()
	i = 0

	for i < func.num_instructions {
		func.instructions << r.read_instruction() or { return err }
		i++
	}

	return func
}

fn (mut r Reader) read_instruction() ?Instruction{
	mut inst := Instruction{}

	inst.op = opcode_from_byte(r.read<byte>())
	mut len := inst.op.get_count_arguments()

	mut i := 0
	for i < len{
		inst.args << r.read_variable_data() or { return err }
		i++
	}

	match inst.op {
		.callmethod,
		.callparent,
		.callstatic {
			
			var_len := r.read_variable_data() or { return err }
			inst.args << var_len
			len = var_len.integer
			
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
	var.user_flags = r.read<u32>()
	var.data = r.read_variable_data() or { return err }

	return var
}

fn (mut r Reader) read_variable_data() ?VariableData{
	mut data := VariableData{}

	data.typ = r.read<byte>()

	match data.typ {
		0 {} //null

		1, //identifier
		2 {//string
			data.string_id = r.read_string_ref() or { return err }
		}

		3 {//integer
			data.integer = r.read<int>()
		}

		4 {//float
			data.float = r.read<f32>()
		}

		5 {//bool
			data.boolean = r.read<byte>()
		}
		else{}
	}
	return data
}

fn (mut r Reader) error(msg string) {
	eprintln("Reader error: " + msg)
}