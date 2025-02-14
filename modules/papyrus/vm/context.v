module vm

import pex

@[heap]
pub struct ExecutionContext {
mut:
	loader				Loader
	stack				Stack[Value]
	instruction_count	i64
	registers			[]Value
	saved_registers		[][]Value
	cache_registers		[][]Value
	objects				[]Object
	allocator			Allocator
	none_value			Value
	native_functions	map[string]&NativeFunction // object_name.fn_name
}

pub fn create_context() &ExecutionContext {
	mut ctx := &ExecutionContext{
		loader: Loader{
			used_registers: []bool{ len: int(OperandType.stack) + 1 }
			none_operand: Operand { typ: .none_value }
		}
		stack: Stack{
			els: []Value{ cap: 100 }
		}
		saved_registers: [][]Value{ cap: 10 }
		cache_registers: [][]Value{ cap: 10 }
		objects: []Object{ cap: 20 }
		allocator: create_allocator()
		none_value: Value{
			typ: ValueType{ raw: "none", typ: .none },
			data: ValueData{ bool: false }
		}
	}

	ctx.loader.set_context(mut ctx)
	ctx.create_registers()

	return ctx
}

@[direct_array_access; inline]
fn (mut ctx ExecutionContext) create_registers() {
	// get registers from cache
	if ctx.cache_registers.len > 0 {
		ctx.registers = ctx.cache_registers.pop()
		
		// reset values
		ctx.registers[int(OperandType.reg_self)] = ctx.none_value

		for i in int(OperandType.regb1)..ctx.registers.len {
			ctx.registers[i].clear()
		}
	}
	// create new registers
	else {
		ctx.registers = [
			ctx.none_value // self placeholder // 0
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
	assert ctx.registers.len == int(OperandType.registers_count)
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
	assert ctx.saved_registers.last().len == int(OperandType.registers_count)
}

@[direct_array_access; inline]
fn (mut ctx ExecutionContext) restore_registers() {
	if ctx.cache_registers.len < 10 {
		ctx.cache_registers << ctx.registers
		assert ctx.cache_registers.last().len == int(OperandType.registers_count)
	}

	assert ctx.saved_registers.len >= 1
	assert ctx.saved_registers.last().len == int(OperandType.registers_count)
	ctx.registers = ctx.saved_registers.pop()
	assert ctx.registers.len == int(OperandType.registers_count)
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

pub fn (mut ctx ExecutionContext) register_native_function(native_func NativeFunction) ! {
	key := native_func.object_name.to_lower() + "." + native_func.name.to_lower()

	if key in ctx.native_functions {
		return error("a native function with this name ${key} already exists")
	}

	ctx.native_functions[key] = &native_func
}

pub fn (mut ctx ExecutionContext) find_native_function(object_name string, func_name string) ?&NativeFunction {
	key := object_name.to_lower() + "." + func_name.to_lower()
	if key !in ctx.native_functions { return none }
	return ctx.native_functions[key] or { return none }
}