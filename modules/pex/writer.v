module pex

pub struct Buffer {
pub mut:
	bytes []u8
}

pub fn (b Buffer) is_empty() bool {
	return b.bytes.len == 0
}

pub fn (mut b Buffer) clear()  {
	b.bytes.clear()
}

pub struct Writer{
pub mut:
	pex		&PexFile
	buf		&Buffer
}

pub fn write_to_buff(mut pex_file PexFile, mut out_buff Buffer) {
	assert out_buff.is_empty()
	
	mut w := Writer{
		pex:	pex_file
		buf:	unsafe { out_buff }
	}
	
	w.write_pex()

	assert w.buf == out_buff
	assert w.buf.bytes.data == out_buff.bytes.data
	assert w.buf.bytes.len == out_buff.bytes.len
	assert w.buf.bytes.cap == out_buff.bytes.cap
	assert !w.buf.is_empty()
	assert !out_buff.is_empty()
}

pub fn write(mut pex_file PexFile) []u8 {
	mut w := Writer{
		pex:	pex_file
		buf: 	&Buffer{ bytes: []u8{ cap: 2000 } }
	}
	
	w.write_pex()

	assert !w.buf.is_empty()
	return w.buf.bytes
}

@[inline]
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
	w.write(w.pex.has_debug_info)

	if w.pex.has_debug_info > 0 {
		w.write(w.pex.modification_time)

		w.write(cast_int_to_u16(w.pex.functions.len))

		for func in w.pex.functions {
			w.write(func.object_name)
			w.write(func.state_name)
			w.write(func.function_name)
			w.write(func.function_type)

			w.write(cast_int_to_u16(func.instruction_line_numbers.len))

			for line in func.instruction_line_numbers {
				w.write(line)
			}
		}
	}

	//user flags
	w.write(cast_int_to_u16(w.pex.user_flags.len))

	for flag in w.pex.user_flags {
		w.write(flag.name)
		w.write(flag.flag_index)
	}
	
	//objects
	w.write(cast_int_to_u16(w.pex.objects.len))
	
	for obj in w.pex.objects {
		w.write_object(obj)
	}
}

@[inline]
fn (mut w Writer) write_object(obj &Object) {
	w.write(obj.name)
	start_pos := w.buf.bytes.len
	w.write(obj.size)
	w.write(obj.parent_class_name)
	w.write(obj.docstring)
	w.write(obj.user_flags)
	w.write(obj.auto_state_name)

	//write variables
	w.write(cast_int_to_u16(obj.variables.len))
	for var in obj.variables {
		w.write_variable(var)
	}

	//write properties
	w.write(cast_int_to_u16(obj.properties.len))
	for prop in obj.properties {
		w.write_property(prop)
	}

	//write states
	w.write(cast_int_to_u16(obj.states.len))
	for state in obj.states {
		w.write_state(state)
	}

	//write object size
	size := w.buf.bytes.len - start_pos
	w.buf.bytes[start_pos] = u8(size>>u32(24))
	w.buf.bytes[start_pos + 1] = u8(size>>u32(16))
	w.buf.bytes[start_pos + 2] = u8(size>>u32(8))
	w.buf.bytes[start_pos + 3] = u8(size)
}

@[inline]
fn (mut w Writer) write_state(state State) {
	w.write(state.name)
	
	w.write(cast_int_to_u16(state.functions.len))
	
	for func in state.functions {
		w.write_function(func)
	}
}

@[inline]
fn (mut w Writer) write_function_info(info FunctionInfo) {
	w.write(info.return_type)
	w.write(info.docstring)

	w.write(info.user_flags)
	w.write(info.flags)

	w.write(cast_int_to_u16(info.params.len))
	
	for param in info.params {
		w.write_variable_type(param)
	}

	w.write(cast_int_to_u16(info.locals.len))

	for local in info.locals {
		w.write_variable_type(local)
	}

	w.write(cast_int_to_u16(info.instructions.len))

	for inst in info.instructions {
		w.write_instruction(inst)
	}
}

@[inline]
fn (mut w Writer) write_function(func Function) {
	w.write(func.name)
	w.write_function_info(func.info)
}

@[inline]
fn (mut w Writer) write_instruction(inst Instruction) {
	w.write(u8(inst.op))
	
	mut i := 0
	for i < inst.args.len {
		arg := inst.args[i]
		w.write_variable_value(arg)
		i++
	}
}

@[inline]
fn (mut w Writer) write_variable(var Variable) {
	w.write(var.name)
	w.write(var.type_name)
	w.write(var.user_flags)
	w.write_variable_value(var.data)
}

@[inline]
fn (mut w Writer) write_property(prop Property) {
	w.write(prop.name)
	w.write(prop.typ)
	w.write(prop.docstring)
	w.write(prop.user_flags)
	w.write(prop.flags)

	if prop.is_autovar() {
		w.write(prop.auto_var_name)
	}
	else {
		if prop.is_read() {
			w.write_function_info(prop.read_handler)
		}
		if prop.is_write() {
			w.write_function_info(prop.write_handler)
		}
	}
}

@[inline]
fn (mut w Writer) write_variable_value(value VariableValue) {
	w.write(value.typ)

	match value.typ {
		.null {}
		.identifier,
		.str {
			w.write(value.to_string_id())
		}
		.integer {
			w.write(value.to_integer())
		}
		.float {
			w.write(value.to_float())
		}
		.boolean {
			w.write(value.to_boolean())
		}
	}
}

@[inline]
fn (mut w Writer) write_variable_type(typ VariableType) {
	w.write(typ.name)
	w.write(typ.typ)
}