module pex

import os

pub struct Reader{
pub mut:
	bytes	[]byte
	pos		int
	pex		&PexFile
}

pub fn read_from_file(path string) &PexFile {
	if !os.is_file(path) {
		eprintln("invalid file path: `$path`")
		exit(1)
	}

	if os.file_ext(path) != ".pex" {
		eprintln("unexpected file extension `*${os.file_ext(path)}` , expecting `*.pex`")
		exit(1)
	}

	println("read file: `$path`")

	mut bytes := os.read_bytes(path) or { panic(err) }

	return read(bytes)
}

pub fn read(bytes []byte) &PexFile {
	mut r := Reader{
		bytes: bytes
		pex: &PexFile{}
	}

	r.read_pex() or { r.error(err.msg()) }

	return r.pex
}

fn (mut r Reader) read_pex() ! {
	r.pex.magic_number = r.read[u32]()
	r.pex.major_version = r.read[byte]()
	r.pex.minor_version = r.read[byte]()
	r.pex.game_id = r.read[u16]()
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
	
	r.pex.has_debug_info = r.read[byte]()
	
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
			d.function_type = r.read[byte]()
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
		flag_index := r.read[byte]()

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
		return error("number of bytes read($r.pos) != total bytes($r.bytes.len)")
	}
}

fn (mut r Reader) read_object() !&Object {
	mut obj := Object{}

	obj.name = r.read_string_ref() or { return err }
	obj.size = r.read[u32]()

	obj.parent_class_name = r.read_string_ref() or { return err }
	obj.docstring = r.read_string_ref() or { return err }
	obj.user_flags = r.read[u32]()
	obj.default_state_name = r.read_string_ref() or { return err }
	
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
	p.flags = r.read[byte]()

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
	func.flags = r.read[byte]()
	
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

	inst.op = opcode_from_byte(r.read[byte]())
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
	var.data = r.read_variable_data() or { return err }

	return &var
}

fn (mut r Reader) read_variable_data() !VariableData{
	mut data := VariableData{}

	data.typ = r.read[byte]()

	match data.typ {
		0 {} //null
		1, //identifier
		2 {//string
			data.string_id = r.read_string_ref() or { return err }
		}
		3 {//integer
			data.integer = r.read[int]()
		}
		4 {//float
			data.float = r.read[f32]()
		}
		5 {//bool
			data.boolean = r.read[byte]()
		}
		else{}
	}
	return data
}

fn (mut r Reader) error(msg string) {
	eprintln("Reader error: " + msg)
}