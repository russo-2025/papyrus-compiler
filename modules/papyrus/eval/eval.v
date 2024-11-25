module eval

import pex

@[heap]
struct ExecutionContext {
mut:
	pex_file			&pex.PexFile = unsafe { voidptr(0) }
	cur_fn				&pex.Function = unsafe { voidptr(0) }
	cur_used_temps		[]&Value
	cur_locals			map[pex.StringId]&Value
	temps				[]Value
	//cur_object_name		string
	//cur_state_name		string
	//auto_state_name		string
	funcs				map[string]&Function
}

pub fn create_context() &ExecutionContext {
	return &ExecutionContext{}
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

fn (mut e ExecutionContext) load_func(object_name string, state_name string, pex_func &pex.Function) {
	e.cur_fn = unsafe { pex_func }

	var_state_name_id := e.pex_file.find_string_id("::State") or { panic("string `::State` not found")}
	e.cur_locals[var_state_name_id] = e.get_free_var(.none)

	var_self_name_id := e.pex_file.find_string_id("self") or { panic("string `self` not found")}
	e.cur_locals[var_self_name_id] = e.get_free_var(.none)

	//println(e.get_string(pex_func.name))
	for param in pex_func.info.params {
		type_name := e.get_string(param.typ)
		typ := get_type_from_type_name(type_name)
		e.cur_locals[param.name] = e.get_free_var(typ)
	}

	//println(pex_func.info.locals)
	for local in pex_func.info.locals {
		type_name := e.get_string(local.typ)
		typ := get_type_from_type_name(type_name)
		e.cur_locals[local.name] = e.get_free_var(typ)
	}

	//println(e.cur_locals)

	mut insts := []Instruction{}
	
	for inst in pex_func.info.instructions {
		//println(inst)
		match inst.op {
			.nop {}
			.iadd,
			.fadd,
			.isub,
			.fsub,
			.imul,
			.fmul,
			.idiv,
			.fdiv,
			.imod,
			.cmp_eq,
			.cmp_lt,
			.cmp_le,
			.cmp_gt,
			.cmp_ge {
				result_value := e.parse_value(inst.args[0])
				value1 := e.parse_value(inst.args[1])
				value2 := e.parse_value(inst.args[2])

				insts << InfixExpr{
					op: inst.op
					result: result_value
					value1: value1
					value2: value2
				}
			}
			.not,
			.ineg,
			.fneg { panic("TODO ${inst.op}") }
			.assign {
				result_value := e.parse_value(inst.args[0])
				value := e.parse_value(inst.args[1])

				insts << Assign{
					result: result_value
					value: value
				}
			}
			.cast {
				result_value := e.parse_value(inst.args[0])
				value := e.parse_value(inst.args[1])

				insts << CastExpr{
					result: result_value
					value: value
				}
			}
			.jmp,
			.jmpt,
			.jmpf { panic("TODO ${inst.op}") }
			.callmethod {
				fn_name := e.get_string(inst.args[0].to_string_id())
				self_value := e.parse_value(inst.args[1])
				result_value := e.parse_value(inst.args[2])
				args_count := inst.args[3].to_integer() // args count
				mut intr_args := []&Value{}

				if args_count > 0 {
					for j in 0..args_count {
						intr_args << e.parse_value(inst.args[4 + j])
					}
				}
				
				insts << CallMethod{
					name: fn_name
					self: self_value
					result: result_value
					args: intr_args
				}
			}
			.callparent,
			.callstatic,
			.ret {
				value := e.parse_value(inst.args[0])
				insts << Return{
					value: value
				}
			}
			.strcat,
			.propget,
			.propset,
			.array_create,
			.array_length,
			.array_getelement,
			.array_setelement,
			.array_findelement,
			.array_rfindelement { panic("TODO ${inst.op}") }
			._opcode_end { panic("wtf") }
		}
/*
		for i in 0..inst.args.len {
			inst_arg := inst.args[i]

			if inst.op == .callmethod {
				continue
			}
			match inst_arg.typ {
				.null { // aka none
					panic("none value in instruction??")
				}
				.identifier {
					if inst_arg.data.string_id in e.cur_locals {
						inst_operands << e.cur_locals[inst_arg.data.string_id]
					}
					else {
						panic("identifier not found ${inst_arg.data.string_id} - `${e.get_string(inst_arg.data.string_id)}`")
					}
				}
				.str { inst_operands << e.getset_free_var[string](e.get_string(inst_arg.data.string_id)) }
				.integer { inst_operands << e.getset_free_var[i32](inst_arg.data.integer) }
				.float { inst_operands << e.getset_free_var[f32](inst_arg.data.float) }
				.boolean { inst_operands << e.getset_free_var[bool](inst_arg.data.boolean != 0) }
			}
		}

		insts << Instruction {
			op: inst.op
			operands: inst_operands
		}*/
	}

	e.register_func(object_name, state_name, &Function {
		name: e.get_string(pex_func.name)
		instructions: insts
		is_global: pex_func.info.is_global()
	})
}


pub fn (mut e ExecutionContext) call_static(object_name string, func_name string, args []Value) ?&Value {
	//key := object_name.to_lower() + "." + func_name.to_lower()

	//println(e.funcs)
	mut func := e.find_global_func(object_name, func_name) or { return none }
	
	for mut inst in func.instructions {
		match mut inst {
			CallMethod { panic("TODO CallMethod") }
			InfixExpr {
				match inst.op {
					.iadd {
						op_res := inst.value1.get[i32]() + inst.value2.get[i32]()
						inst.result.set[i32](op_res)
					}
					.fadd {
						op_res := inst.value1.get[f32]() + inst.value2.get[f32]()
						inst.result.set[f32](op_res)
					}
					.isub,
					.fsub,
					.imul,
					.fmul,
					.idiv,
					.fdiv,
					.imod { panic("TODO InfixExpr") }
					.cmp_eq {
						op_res := match inst.value1.typ {
							.integer { inst.value1.get[i32]() == inst.value2.get[i32]() }
							.float { inst.value1.get[f32]() == inst.value2.get[f32]() }
							else { panic("TODO") }
						}
						inst.result.set[bool](op_res)
					}
					.cmp_lt,
					.cmp_le,
					.cmp_gt,
					.cmp_ge { panic("TODO InfixExpr") }
					else { panic("invalid op in eval.InfixExpr") }
				}
			}
			CastExpr {
				to_type := inst.result.typ
				//from_type := inst.value.typ

				match to_type {
					.none { panic("TODO") }
					.bool {
						inst.value.cast[bool]()
					}
					.integer {
						inst.value.cast[i32]()
					}
					.float {
						inst.value.cast[f32]()
					}
					.string {
						inst.value.cast[string]()
					}
					.object { panic("TODO") }
					.array { panic("TODO") }
				}

				inst.result.set(inst.value)
			}
			Return { return inst.value }
			Assign { panic("TODO Assign") }
		}
	}

	

	/*mut func := e.parse_func()

	//println(insts)
	for mut inst in func.instructions {
		println(inst.op)
		println(inst.operands)
		match inst.op {
			.nop { }
			.iadd {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .integer
				assert inst.operands[1].typ == .integer
				assert inst.operands[2].typ == .integer
				op_res := inst.operands[1].get[i32]() + inst.operands[2].get[i32]()
				inst.operands[0].set[i32](op_res)
			}
			.fadd {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .float
				assert inst.operands[1].typ == .float
				assert inst.operands[2].typ == .float
				op_res := inst.operands[1].get[f32]() + inst.operands[2].get[f32]()
				inst.operands[0].set[f32](op_res)
			}
			.isub {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .integer
				assert inst.operands[1].typ == .integer
				assert inst.operands[2].typ == .integer
				op_res := inst.operands[1].get[i32]() - inst.operands[2].get[i32]()
				inst.operands[0].set[i32](op_res)
			}
			.fsub {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .float
				assert inst.operands[1].typ == .float
				assert inst.operands[2].typ == .float
				op_res := inst.operands[1].get[f32]() - inst.operands[2].get[f32]()
				inst.operands[0].set[f32](op_res)
			}
			.imul {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .integer
				assert inst.operands[1].typ == .integer
				assert inst.operands[2].typ == .integer
				op_res := inst.operands[1].get[i32]() * inst.operands[2].get[i32]()
				inst.operands[0].set[i32](op_res)
			}
			.fmul {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .float
				assert inst.operands[1].typ == .float
				assert inst.operands[2].typ == .float
				op_res := inst.operands[1].get[f32]() * inst.operands[2].get[f32]()
				inst.operands[0].set[f32](op_res)
			}
			.idiv {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .integer
				assert inst.operands[1].typ == .integer
				assert inst.operands[2].typ == .integer
				op_res := inst.operands[1].get[i32]() / inst.operands[2].get[i32]()
				inst.operands[0].set[i32](op_res)
			}
			.fdiv {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .float
				assert inst.operands[1].typ == .float
				assert inst.operands[2].typ == .float
				op_res := inst.operands[1].get[f32]() / inst.operands[2].get[f32]()
				inst.operands[0].set[f32](op_res)
			}
			.imod {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .integer
				assert inst.operands[1].typ == .integer
				assert inst.operands[2].typ == .integer
				op_res := inst.operands[1].get[i32]() % inst.operands[2].get[i32]()
				inst.operands[0].set[i32](op_res)
			}
			.not {
				panic("not")
			}
			.ineg {
				panic("ineg")
			}
			.fneg {
				panic("fneg")
			}
			.assign {
				panic("assign")
			}
			.cast {
				assert inst.operands.len == 2
				to_type := inst.operands[0].typ
				from_type := inst.operands[1].typ

				match to_type {
					.integer {
						inst.operands[1].cast[i32]()
					}
					.float {
						inst.operands[1].cast[f32]()
					}
					.bool {
						inst.operands[1].cast[bool]()
					}
					.string {
						inst.operands[1].cast[string]()
					}
					.object { panic("TODO") }
					.array { panic("TODO") }
				}
			}
			.cmp_eq {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .bool
				assert inst.operands[1].typ == inst.operands[2].typ

				op_res := match inst.operands[1].typ {
					.integer { inst.operands[1].get[i32]() == inst.operands[2].get[i32]() }
					.float { inst.operands[1].get[f32]() == inst.operands[2].get[f32]() }
					else { panic("TODO") }
				}
				inst.operands[0].set[bool](op_res)

				println("cmp_eq res: ${inst.operands[0].get[bool]()}")
			}
			.cmp_lt {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .bool
				assert inst.operands[1].typ == inst.operands[2].typ

				op_res := match inst.operands[1].typ {
					.integer { inst.operands[1].get[i32]() < inst.operands[2].get[i32]() }
					.float { inst.operands[1].get[f32]() < inst.operands[2].get[f32]() }
					else { panic("TODO") }
				}
				inst.operands[0].set[bool](op_res)
			}
			.cmp_le {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .bool
				assert inst.operands[1].typ == inst.operands[2].typ

				op_res := match inst.operands[1].typ {
					.integer { inst.operands[1].get[i32]() <= inst.operands[2].get[i32]() }
					.float { inst.operands[1].get[f32]() <= inst.operands[2].get[f32]() }
					else { panic("TODO") }
				}
				inst.operands[0].set[bool](op_res)
			}
			.cmp_gt {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .bool
				assert inst.operands[1].typ == inst.operands[2].typ
				
				op_res := match inst.operands[1].typ {
					.integer { inst.operands[1].get[i32]() > inst.operands[2].get[i32]() }
					.float { inst.operands[1].get[f32]() > inst.operands[2].get[f32]() }
					else { panic("TODO") }
				}
				inst.operands[0].set[bool](op_res)
			}
			.cmp_ge {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .bool
				assert inst.operands[1].typ == inst.operands[2].typ
				
				op_res := match inst.operands[1].typ {
					.integer { inst.operands[1].get[i32]() >= inst.operands[2].get[i32]() }
					.float { inst.operands[1].get[f32]() >= inst.operands[2].get[f32]() }
					else { panic("TODO") }
				}
				inst.operands[0].set[bool](op_res)
			}
			.jmp {
				panic("jmp")
			}
			.jmpt {
				panic("jmpt")
			}
			.jmpf {
				panic("jmpf")
			}
			.callmethod {
				panic("callmethod")
			}
			.callparent {
				panic("callparent")
			}
			.callstatic {
				panic("callstatic")
			}
			.ret {
				panic("ret")
			}
			.strcat {
				assert inst.operands.len == 3
				assert inst.operands[0].typ == .string
				assert inst.operands[1].typ == .string
				assert inst.operands[2].typ == .string
				op_res := inst.operands[1].get[string]() + inst.operands[2].get[string]()
				inst.operands[0].set[string](op_res)
			}
			.propget {
				panic("propget")
			}
			.propset {
				panic("propset")
			}
			.array_create {
				panic("array_create")
			}
			.array_length {
				panic("array_length")
			}
			.array_getelement {
				panic("array_getelement")
			}
			.array_setelement {
				panic("array_setelement")
			}
			.array_findelement {
				panic("array_findelement")
			}
			.array_rfindelement {
				panic("array_rfindelement")
			}
			._opcode_end { panic("wtf") }
		}
	}
	*/
	mut res := Value{}
	res.typ = .bool
	res.clear()
	return &res
}

fn (mut e ExecutionContext) parse_value(pex_value pex.VariableValue) &Value {
	match pex_value.typ {
		.null { // aka none
			return e.get_free_var(.none)
		}
		.identifier {
			if pex_value.to_string_id() in e.cur_locals {
				return e.cur_locals[pex_value.to_string_id()] or { panic("not found") }
			}
			else {
				panic("identifier not found ${pex_value.to_string_id()} - `${e.get_string(pex_value.to_string_id())}`")
			}
		}
		.str { return e.getset_free_var[string](e.get_string(pex_value.to_string_id())) }
		.integer { return e.getset_free_var[i32](i32(pex_value.to_integer()))}
		.float { return e.getset_free_var[f32](pex_value.to_float())}
		.boolean { return e.getset_free_var[bool](pex_value.to_boolean() != 0)}
	}
}

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

fn (e ExecutionContext) get_string(id pex.StringId) string {
	return e.pex_file.get_string(id)
}