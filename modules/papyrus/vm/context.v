module vm

import pex

@[heap]
struct ExecutionContext {
mut:
	pex_file				&pex.PexFile = unsafe { voidptr(0) }
	funcs					map[string]&Function
	stack					Stack[Value]

	//temps for parse
	fn_stack_count		int
	fn_stack_data		[]Value
	local_id_by_name	map[pex.StringId]int
	local_typ_by_name	map[pex.StringId]ValueType
	none_operand		Operand
	self_operand		Operand
	state_name_operand	Operand
}

pub fn create_context() &ExecutionContext {
	mut ctx := &ExecutionContext{}

	none_value_offset := ctx.stack.len()
	ctx.none_operand = Operand {
		stack_offset: none_value_offset
	}
	ctx.stack.push(none_value)

	return ctx
}

pub fn (mut e ExecutionContext) load_pex_file(pex_file &pex.PexFile) {
	e.pex_file = pex_file
	assert e.pex_file.objects.len == 1

	obj := e.pex_file.objects[0]

	object_name := e.get_string(obj.name)
	auto_state_name := e.get_string(obj.auto_state_name)

	for pex_state in obj.states {
		state_name := e.get_string(pex_state.name)
		
		for pex_func in pex_state.functions {
			e.load_func(object_name, state_name, pex_func)
		}
	}
}

fn (mut e ExecutionContext) find_global_func(object_name string, func_name string) ?&Function {
	return e.funcs[object_name.to_lower() + "." + func_name.to_lower()] or { return none }
}

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

fn (e ExecutionContext) get_string(id pex.StringId) string {
	return e.pex_file.get_string(id)
}