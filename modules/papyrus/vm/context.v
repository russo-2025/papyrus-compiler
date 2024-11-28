module vm

import pex

struct Stack[T] {
mut:
	els []T
	// нужна структуда данный ссылки на элементы которой не будут меняться 
	// или переделать инструкции, потому что при добавлении/удалении из контейнера ссылка может измениться
	// или переделать Value так что бы он хранил VariableId и корректно обрабатывал .set[i32](1) для таких переменных
}

fn (mut s Stack[T]) push(el T) {
	s.els << el
}

fn (mut s Stack[T]) push_many(els []T) {
	for el in els {
		s.els << el
	}
}

fn (mut s Stack[T]) pop() T {
	return s.els.pop()
}

fn (mut s Stack[T]) pop_len(len int) {
	for i in 0..len {
		s.els.pop()
	}
}

fn (s Stack[T]) peek() &T {
	return &s.els[s.els.len - 1]
}

fn (s Stack[T]) peek_offset(offset int) &T {
	//assert offset < s.els.len
	println("offset: ${offset} len: ${s.els.len}")
	return &s.els[s.els.len - 1 - offset]
}

fn (s Stack[T]) len() int {
	return s.els.len
}

@[heap]
struct ExecutionContext {
mut:
	pex_file				&pex.PexFile = unsafe { voidptr(0) }
	//cur_fn					&pex.Function = unsafe { voidptr(0) }
	//cur_used_temps			[]&Value
	//temps					[]Value
	funcs					map[string]&Function
	stack					Stack[Value]

	//temps for parse
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
	key := if func.is_global {
		object_name.to_lower() + "." + func.name.to_lower()
	}
	else {
		object_name.to_lower() + "." + state_name.to_lower() + "." + func.name.to_lower()
	}

	e.funcs[key] = func
}

/*
fn (mut e ExecutionContext) set_var(index int, value Value) {
	assert e.temps[index].typ == value.typ

	match value.typ {
		.bool { e.temps[index].set[bool](value.get[bool]()) }
		.integer { e.temps[index].set[i32](value.get[i32]()) }
		.float { e.temps[index].set[f32](value.get[f32]()) }
		.string { e.temps[index].set[string](value.get[string]()) }
		//TODO array object
		else { panic("TODO") }
	}
}

fn (mut e ExecutionContext) get_var(index int) &Value {
	return &e.temps[index]
}

fn (mut e ExecutionContext) free_var(index int) {
	e.temps[index].is_used = false
	e.temps[index].clear()
}

fn (mut e ExecutionContext) getset_free_var[T](value T) &Value {
	$if T is bool {
		typ := ValueType.bool
		mut v1 := e.get_free_var(typ)
		v1.data.bool = value
		return v1
	}
	$else $if T is i32 {
		typ := ValueType.integer
		mut v1 := e.get_free_var(typ)
		v1.data.integer = value
		return v1
	}
	$else $if T is f32 {
		typ := ValueType.float
		mut v1 := e.get_free_var(typ)
		v1.data.float = value
		return v1
	}
	$else $if T is string {
		typ := ValueType.string
		mut v1 := e.get_free_var(typ)
		v1.data.string = value
		return v1
	}
	$else {
		$compile_error("invalid T type")
	}
}

fn (mut e ExecutionContext) get_free_var(typ ValueType) &Value {
	for i in 0..e.temps.len {
		if !e.temps[i].is_used && e.temps[i].typ == typ {
			return i
		} 
	}

	mut v := Value{}
	v.typ = typ
	v.is_used = true
	v.is_temp = true
	v.clear()

	e.temps << v
	e.cur_used_temps << &e.temps[e.temps.len - 1]

	return &e.temps[e.temps.len - 1]
}
*/

fn (e ExecutionContext) get_string(id pex.StringId) string {
	return e.pex_file.get_string(id)
}