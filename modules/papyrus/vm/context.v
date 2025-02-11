module vm

import pex

@[heap]
struct ExecutionContext {
mut:
	loader				Loader
	stack				Stack[Value]
	instruction_count	i64
	registers			[]Value
	saved_registers		[][]Value
	cache_registers		[][]Value
	objects				[]Object
	allocator			Allocator
}

pub fn create_context() &ExecutionContext {
	mut ctx := &ExecutionContext{
		loader: Loader{
			used_registers: []bool{ len: int(OperandType.stack) + 1 }
		}
		stack: Stack{
			els: []Value{ cap: 100 }
		}
		saved_registers: [][]Value{ cap: 10 }
		cache_registers: [][]Value{ cap: 10 }
		objects: []Object{ cap: 20 }
		allocator: create_allocator()
	}

	ctx.loader.set_context(mut ctx)

	none_value_offset := ctx.stack.len()
	ctx.loader.none_operand = Operand {
		stack_offset: none_value_offset
	}
	ctx.stack.push(none_value)

	ctx.create_registers()

	return ctx
}

@[direct_array_access; inline]
fn (mut ctx ExecutionContext) create_registers() {
	// get registers from cache
	if ctx.cache_registers.len > 0 {
		ctx.registers = ctx.cache_registers.pop()
		
		// reset values
		ctx.registers[int(OperandType.reg_self)] = none_value

		for i in int(OperandType.regb1)..ctx.registers.len {
			ctx.registers[i].clear()
		}
	}
	// create new registers
	else {
		ctx.registers = [
			none_value // placeholder self // 0
			ctx.create_string("default state name") //state

			ctx.create_bool(false) // 2
			ctx.create_bool(false)

			ctx.create_int(0) // 4
			ctx.create_int(0)
			ctx.create_int(0)

			ctx.create_float(0.0) // 7
			ctx.create_float(0.0)
			ctx.create_float(0.0)
		]
	}
	assert ctx.registers.len == int(OperandType.stack)
}

@[inline]
fn (mut ctx ExecutionContext) set_self_register(value Value) {
	assert value.typ.typ == .object
	ctx.registers[int(OperandType.reg_self)] = value
}

@[direct_array_access; inline]
fn (mut ctx ExecutionContext) save_registers() {
	ctx.saved_registers << ctx.registers
	ctx.create_registers()
	assert ctx.saved_registers.last().len == int(OperandType.stack)
}

@[direct_array_access; inline]
fn (mut ctx ExecutionContext) restore_registers() {
	if ctx.cache_registers.len < 10 {
		ctx.cache_registers << ctx.registers
		assert ctx.cache_registers.last().len == int(OperandType.stack)
	}

	assert ctx.saved_registers.len >= 1
	assert ctx.saved_registers.last().len == int(OperandType.stack)
	ctx.registers = ctx.saved_registers.pop()
	assert ctx.registers.len == int(OperandType.stack)
}

@[inline]
pub fn (mut ctx ExecutionContext) load_pex_file(pex_file &pex.PexFile) {
	ctx.loader.load_pex_file(pex_file)
}

@[inline]
pub fn (mut ctx ExecutionContext) find_script(object_name string) ?&Script {
	script := ctx.loader.find_script(object_name) or { return none }
	return script
}

@[inline]
pub fn (mut ctx ExecutionContext) find_method(object_name string, state_name string, func_name string) ?&Function {
	return ctx.loader.find_method(object_name, state_name, func_name)
}

@[inline]
pub fn (mut ctx ExecutionContext) find_global_func(object_name string, func_name string) ?&Function {
	return ctx.loader.find_global_func(object_name, func_name)
}

pub fn (mut ctx ExecutionContext) get_executed_instructions_count() i64 {
	return ctx .instruction_count
}

fn (mut ctx ExecutionContext) create_object(info &Script) &Object {
	ctx.objects << Object{
		info: info
		state: info.auto_state
	}

	return &ctx.objects[ctx.objects.len - 1]
}

pub fn (mut ctx ExecutionContext) create_object_value(info &Script) Value {
	obj_ptr := ctx.create_object(info)
	mut obj_value := ctx.create_value_none_object_from_info(info)
	obj_value.bind_object(obj_ptr)
	return obj_value
}