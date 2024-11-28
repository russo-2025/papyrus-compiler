module vm

@[params]
struct RunCommandsParams {
	commands		[]Command
	operands		[]Operand
	is_global		bool
}

fn (mut e ExecutionContext) get_value(operand Operand) &Value {
	return e.stack.peek_offset(operand.stack_offset)
}

pub fn (mut e ExecutionContext) run_commands(p RunCommandsParams) Operand {
	mut stack_count := int(0) 
	for command in p.commands {
		println(command)
		match command {
			InitFnStack {
				stack_count = command.data.len
				e.stack.push_many(command.data.reverse())
			}
			CallStatic {
				func := e.find_global_func(command.object, command.name) or { panic("fn not found") }
				return e.run_commands(commands: func.commands, operands: command.args)
			}
			CallMethod { panic("TODO CallMethod") }
			InfixExpr {
				match command.op {
					.iadd {
						mut v1 := e.get_value(command.value1).get[i32]()
						mut v2 := e.get_value(command.value2).get[i32]()
						mut res := e.get_value(command.result)
						res.set[i32](v1 + v2)
					}
					.fadd {
						mut v1 := e.get_value(command.value1).get[f32]()
						mut v2 := e.get_value(command.value2).get[f32]()
						mut res := e.get_value(command.result)
						res.set[f32](v1 + v2)
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
								res.set[bool](v1 == v2)
							}
							.float {
								mut v1 := e.get_value(command.value1).get[f32]()
								mut v2 := e.get_value(command.value2).get[f32]()
								mut res := e.get_value(command.result)
								res.set[bool](v1 == v2)
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
				//println(e)
				//println(command.value)
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

				res.set_value(value) // TODO v bug .set[&Value]()
			}
			Return { return command.value }
			Assign { panic("TODO Assign") }
		}
	}

	e.stack.pop_len(stack_count)

	return e.none_operand
}

pub fn (mut e ExecutionContext) call_static(object_name string, func_name string, args []Value) ?&Value {
	mut func := e.find_global_func(object_name, func_name) or { return none }
	//TODO []Value -> []Operand
	return e.get_value(e.run_commands(commands: func.commands))
}
