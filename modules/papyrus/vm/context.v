module vm

import pex

@[heap]
struct ExecutionContext {
mut:
	pex_file				&pex.PexFile = unsafe { voidptr(0) }
	funcs					map[string]&Function
	stack					Stack[Value]
	none_operand			Operand
	instruction_count		i64

	// temps parser
	commands				[]Command
	fn_stack_count			int
	fn_stack_data			[]Value
	self_operand			Operand
	state_name_operand		Operand
	used_registers			[]bool
	operand_by_name			map[pex.StringId]Operand
	operand_type_by_name	map[pex.StringId]ValueType

	// temps exec
	registers			[]Value
	saved_registers		[][]Value
	cache_registers		[][]Value
}

pub fn create_context() &ExecutionContext {
	mut ctx := &ExecutionContext{
		stack: Stack{
			els: []Value{ cap: 100 }
		}
		used_registers: []bool{ len: int(OperandType.stack) + 1 }
		saved_registers: [][]Value{ cap: 10 }
		cache_registers: [][]Value{ cap: 10 }
	}

	none_value_offset := ctx.stack.len()
	ctx.none_operand = Operand {
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
		for i in int(OperandType.regb1)..ctx.registers.len {
			match ctx.registers[i].typ {
				.none { panic("WTF") }
				.bool { ctx.registers[i].set[bool](false) }
				.i32 { ctx.registers[i].set[i32](0) }
				.f32 { ctx.registers[i].set[f32](0.0) }
				.string { ctx.registers[i].set[string]("") }
				.object { panic("TODO") }
				.array { panic("TODO") }
			}
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
			/*create_value_typ(.i32)
			create_value_typ(.i32)
			create_value_typ(.i32)*/

			create_value_typ(.f32) // 10
			create_value_typ(.f32)
			create_value_typ(.f32)
			/*create_value_typ(.f32)
			create_value_typ(.f32)
			create_value_typ(.f32) // 15
			*/
		]
	}
	assert ctx.registers.len == int(OperandType.stack)
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

pub fn (mut e ExecutionContext) load_pex_file(pex_file &pex.PexFile) {
	e.pex_file = pex_file
	assert e.pex_file.objects.len == 1

	obj := e.pex_file.objects[0]

	object_name := e.get_string(obj.name)
	//auto_state_name := e.get_string(obj.auto_state_name)

	for pex_state in obj.states {
		state_name := e.get_string(pex_state.name)
		
		for pex_func in pex_state.functions {
			e.load_func(object_name, state_name, pex_func)
		}
	}
}

@[inline]
fn (mut e ExecutionContext) find_global_func(object_name string, func_name string) ?&Function {
	return e.funcs[object_name.to_lower() + "." + func_name.to_lower()] or { return none }
}

@[inline]
fn (mut e ExecutionContext) register_func(object_name string, state_name string, func &Function) {
	//print(func)
	key := if func.is_global {
		object_name.to_lower() + "." + func.name.to_lower()
	}
	else {
		object_name.to_lower() + "." + state_name.to_lower() + "." + func.name.to_lower()
	}

	e.funcs[key] = func
}

@[inline]
fn (e ExecutionContext) get_string(id pex.StringId) string {
	return e.pex_file.get_string(id)
}

pub fn (mut e ExecutionContext) get_executed_instructions_count() i64 {
	return e.instruction_count
}