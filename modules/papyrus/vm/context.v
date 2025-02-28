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

	scripts				[]Script
	funcs				map[string]&Function // object_name.func_name

	//native_functions	map[string]&NativeFunction // object_name.fn_name
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
	//ctx.print_loaded_scripts()
}

@[inline]
pub fn (mut ctx ExecutionContext) find_script(object_name string) ?&Script {
	for i in 0..ctx.scripts.len {
		if object_name.to_lower() == ctx.scripts[i].name {
			return &ctx.scripts[i]
		}
	}
	
	return none
}

@[inline]
pub fn (mut ctx ExecutionContext) find_method(object_name string, func_name string) ?&Function {
	func := ctx.funcs[object_name.to_lower() + "." + func_name.to_lower()] or { return none }
	assert !func.is_global
	return func
}

@[inline]
pub fn (mut ctx ExecutionContext) find_method_with_state(object_name string, state_name string, func_name string) ?&Function {
	func := ctx.funcs[object_name.to_lower() + "." + func_name.to_lower()] or { return none }
	assert !func.is_global
	return func
}

@[inline]
pub fn (mut ctx ExecutionContext) find_global_func(object_name string, func_name string) ?&Function {
	func := ctx.funcs[object_name.to_lower() + "." + func_name.to_lower()] or { return none }
	assert func.is_global
	return func
}

pub fn (mut ctx ExecutionContext) get_executed_instructions_count() i64 {
	return ctx .instruction_count
}

fn (mut ctx ExecutionContext) create_object(info &Script) &Object {
	ctx.objects << Object{
		info: info
		cur_state: info.auto_state
	}

	return &ctx.objects[ctx.objects.len - 1]
}

pub fn (mut ctx ExecutionContext) create_object_value(info &Script) Value {
	obj_ptr := ctx.create_object(info)
	mut obj_value := ctx.create_value_none_object_from_info(info)
	obj_value.bind_object(obj_ptr)
	return obj_value
}

fn (mut ctx ExecutionContext) register_script(script Script) &Script {
	ctx.scripts << script
	return &ctx.scripts[ctx.scripts.len - 1]
}

//fn (mut ctx ExecutionContext) register_state(script &Script, state &State) {}
//fn (mut ctx ExecutionContext) register_method(script &Script, state &State, func &Function) {}

pub fn (mut ctx ExecutionContext) register_native_function(native_func NativeFunction) ! {
	key := native_func.object_name.to_lower() + "." + native_func.name.to_lower()
	
	if key !in ctx.funcs {
		return error("function not found")
	}
	
	assert ctx.funcs[key].name != ""
	assert ctx.funcs[key].is_native
	assert ctx.funcs[key].is_global == native_func.is_global

	ctx.funcs[key].cb = native_func.cb
	/*
	if key in ctx.native_functions {
		return error("a native function with this name ${key} already exists")
	}

	ctx.native_functions[key] = &native_func
	*/
}
/*
pub fn (mut ctx ExecutionContext) find_native_function(object_name string, func_name string) ?&NativeFunction {
	key := object_name.to_lower() + "." + func_name.to_lower()
	if key !in ctx.native_functions { return none }
	return ctx.native_functions[key] or { return none }
}*/

pub fn (mut ctx ExecutionContext) goto_state(self &Value, name string) ! {
	mut obj := self.get_object()
	obj.cur_state = obj.info.find_state_by_name(name) or { return error("state with name `${name.to_lower()}` not found in object `${obj.info.name.to_lower()}`")}
}

fn (ctx ExecutionContext) print_loaded_scripts() {
	for script in ctx.scripts {
		println("class `${script.name}`, autostate `${script.auto_state.name}`")
		for state in script.states {
			println("\tstate `${state.name}`")
			for method in state.funcs {
				println("\t\tmethod `${method.name}`")
			}
		}
	}
}