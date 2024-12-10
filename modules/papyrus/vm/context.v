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
	
	//objects				[]Object
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
	}

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
			Value{ typ: .object, data: ValueData{ bool: false } } //self // 0
			create_value_data[string]("default state name")//state

			create_value_typ(.bool) // 2
			create_value_typ(.bool)

			create_value_typ(.i32) // 4
			create_value_typ(.i32)
			create_value_typ(.i32)

			create_value_typ(.f32) // 7
			create_value_typ(.f32)
			create_value_typ(.f32)
		]
	}
	assert ctx.registers.len == int(OperandType.stack)
}

@[inline]
fn (mut ctx ExecutionContext) set_self_register(value Value) {
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
pub fn (mut e ExecutionContext) load_pex_file(pex_file &pex.PexFile) {
	e.loader.load_pex_file(pex_file)
}


@[inline]
pub fn (mut e ExecutionContext) find_script(object_name string) ?&Script {
	script := e.loader.find_script(object_name) or { return none }
	return script
}

@[inline]
pub fn (mut e ExecutionContext) find_method(object_name string, state_name string, func_name string) ?&Function {
	return e.loader.find_method(object_name, state_name, func_name)
}

@[inline]
pub fn (mut e ExecutionContext) find_global_func(object_name string, func_name string) ?&Function {
	return e.loader.find_global_func(object_name, func_name)
}

pub fn (mut e ExecutionContext) get_executed_instructions_count() i64 {
	return e.instruction_count
}