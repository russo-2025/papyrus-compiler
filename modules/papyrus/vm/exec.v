module vm

@[params]
struct RunCommandsParams {
	func			&Function
	//commands		[]Command
	args			[]Value
	//stack_data	[]Value
	is_global		bool
}

fn (mut e ExecutionContext) print_stack() {
	for i := 0; i < e.stack.len(); i++ {
		val := e.stack.peek_offset(i)
		mut val_str := match val.typ {
			.none { "type: none" }
			.integer { "type: integer; data: ${val.get[i32]()}" }
			.float { "type: float; data: ${val.get[f32]()}" }
			.bool { "type: bool; data: ${val.get[bool]()}" }
			.string { "type: string; data: ${val.get[string]()}" }
			.object { panic("TODO") }
			.array { panic("TODO") }
		}
		println("offset: ${i}; ${val_str}")
	}
}

fn (mut e ExecutionContext) set_value(operand Operand, val2 &Value) {
	mut val1 := e.stack.peek_offset(operand.stack_offset)

	match val1.typ {
		.none { panic("TODO") }
		.integer {
			unsafe { val1.data.integer = val2.data.integer }
		}
		.float {
			unsafe { val1.data.float = val2.data.float }
		}
		.bool {
			unsafe { val1.data.bool = val2.data.bool }
		}
		.string {
			unsafe { val1.data.string = val2.data.string }
		}
		.object { panic("TODO") }
		.array { panic("TODO") }
	}
}

fn (mut e ExecutionContext) get_value(operand Operand) &Value {
	return e.stack.peek_offset(operand.stack_offset)
}

fn (mut e ExecutionContext) run_commands(p RunCommandsParams) &Value {
	pushlen := p.func.stack_data.len + p.args.len + 1 + 1
	println("[run] ${p.func.name} stacklen${e.stack.len()} pushlen${pushlen}")
	e.stack.push_many(p.func.stack_data.reverse())
	
	for i := p.args.len - 1; i >= 0; i-- {
		e.stack.push(p.args[i])
	}

	//TODO только для методов
	e.stack.push(create_value_data[string]("default state name")) // state_name_operand
	e.stack.push(none_value) // self_operand

	//println("============")
	//e.print_stack()

	for command in p.func.commands {
		//println(command)
		match command {
			/*InitFnStack {
				stack_count = command.data.len
				e.stack.push_many(command.data.reverse())
			}*/
			CallStatic {
				func := e.find_global_func(command.object, command.name) or { panic("fn not found") }
				mut res := e.get_value(command.result)
				mut vargs := []Value{}
				for arg in command.args {
					vargs << e.get_value(arg)
				}

				tres := e.run_commands(func: func, args: vargs)
				
				e.set_value(command.result, tres)
			}
			CallMethod { panic("TODO CallMethod") }
			InfixExpr {
				match command.op {
					.iadd {
						mut v1 := e.get_value(command.value1).get[i32]()
						mut v2 := e.get_value(command.value2).get[i32]()
						mut res := e.get_value(command.result)
						res.set[i32](v1 + v2)//TODO e.set_value_data(command.result, 1)
					}
					.fadd {
						mut v1 := e.get_value(command.value1).get[f32]()
						mut v2 := e.get_value(command.value2).get[f32]()
						mut res := e.get_value(command.result)
						res.set[f32](v1 + v2) //TODO e.set_value_data(command.result, 1)
					}
					.isub,
					.fsub,
					.imul,
					.fmul,
					.idiv,
					.fdiv,
					.imod { panic("TODO InfixExpr") }
					.cmp_eq {
						match e.get_value(command.value1).typ {
							.integer {
								mut v1 := e.get_value(command.value1).get[i32]()
								mut v2 := e.get_value(command.value2).get[i32]()
								mut res := e.get_value(command.result)
								res.set[bool](v1 == v2)//TODO e.set_value_data(command.result, 1)
							}
							.float {
								mut v1 := e.get_value(command.value1).get[f32]()
								mut v2 := e.get_value(command.value2).get[f32]()
								mut res := e.get_value(command.result)
								res.set[bool](v1 == v2)//TODO e.set_value_data(command.result, 1)
							}
							else { panic("TODO") }
						}
					}
					.cmp_lt,
					.cmp_le,
					.cmp_gt,
					.cmp_ge { panic("TODO InfixExpr") }
					else { panic("invalid op in eval.InfixExpr") }
				}
			}
			CastExpr {
				mut res := e.get_value(command.result)
				mut value := e.get_value(command.value)
				to_type := res.typ
				
				match to_type {
					.none { panic("TODO") }
					.bool {
						value.cast[bool]()
					}
					.integer {
						value.cast[i32]()
					}
					.float {
						value.cast[f32]()
					}
					.string {
						value.cast[string]()
					}
					.object { panic("TODO") }
					.array { panic("TODO") }
				}

				e.set_value(command.result, e.get_value(command.value))
			}
			Return {
				res := e.get_value(command.value)

				e.stack.pop_len(p.func.stack_data.len)
				e.stack.pop_len(p.args.len)
				e.stack.pop()
				e.stack.pop()

				if res.typ == .float {
					println("[run Return] ${p.func.name} res ${res.get[f32]()} stacklen${e.stack.len()}")
				}
				else if res.typ == .integer {
					println("[run Return] ${p.func.name} res ${res.get[i32]()} stacklen${e.stack.len()}")
				}

				return res
			}
			Assign {
				e.set_value(command.result, e.get_value(command.value))
			}
		}
	}

	e.stack.pop_len(p.func.stack_data.len)
	e.stack.pop_len(p.args.len)
	e.stack.pop()
	e.stack.pop()

	println("[run Return] ${p.func.name} stacklen${e.stack.len()}")

	return e.get_value(e.none_operand)
}

pub fn (mut e ExecutionContext) call_static(object_name string, func_name string, args []Value) ?&Value {
	mut func := e.find_global_func(object_name, func_name) or { return none }
	return e.run_commands(func: func, args: args)
}
