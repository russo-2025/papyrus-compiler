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

fn (mut e ExecutionContext) get_value(operand Operand) &Value {
	return e.stack.peek_offset(operand.stack_offset)
}

fn (mut e ExecutionContext) run_commands(p RunCommandsParams) &Value {
	//println("[run] ${p.func.name}")
	//println("push stask data ${p.func.stack_data.len}")
	e.stack.push_many(p.func.stack_data.reverse())
	
	//println("push args ${p.args.len}")
	for i := p.args.len - 1; i >= 0; i-- {
		e.stack.push(p.args[i])
	}

	//println("push state name")
	e.stack.push(create_value_data[string]("default state name")) // state_name_operand
	//println("push self")
	e.stack.push(none_value) // self_operand

	//e.print_stack()

	for command in p.func.commands {
		//println(command)
		match command {
			/*InitFnStack {
				stack_count = command.data.len
				e.stack.push_many(command.data.reverse())
			}*/
			CallStatic {
				//println("[run CallStatic] ${command.name}")
				func := e.find_global_func(command.object, command.name) or { panic("fn not found") }
				mut res := e.get_value(command.result)
				mut vargs := []Value{}
				for arg in command.args {
					vargs << e.get_value(arg)
				}
				res.set_value(e.run_commands(func: func, args: vargs))
			}
			CallMethod { panic("TODO CallMethod") }
			InfixExpr {
				match command.op {
					.iadd {
						mut v1 := e.get_value(command.value1).get[i32]()
						mut v2 := e.get_value(command.value2).get[i32]()
						mut res := e.get_value(command.result)
						res.set[i32](v1 + v2)
						//println("iadd ${v1} ${v2} = ${res.get[i32]()}")
					}
					.fadd {
						mut v1 := e.get_value(command.value1).get[f32]()
						mut v2 := e.get_value(command.value2).get[f32]()
						mut res := e.get_value(command.result)
						res.set[f32](v1 + v2)
						//println("fadd ${v1} ${v2} = ${res.get[f32]()}")
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
				mut value := e.get_value(command.value)
				to_type := res.typ
				//println("[run CastExpr] ${command.value.stack_offset} -> ${command.result.stack_offset}")
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
			Return {
				res := e.get_value(command.value)
				//println("[run_commands Return] res: ${res}")
				e.stack.pop_len(p.func.stack_data.len)
				e.stack.pop_len(p.args.len)
				e.stack.pop()
				e.stack.pop()
				return res
			}
			Assign {
				mut res := e.get_value(command.result)
				res.set_value(e.get_value(command.value))
			}
		}
	}

	e.stack.pop_len(p.func.stack_data.len)
	e.stack.pop_len(p.args.len)
	e.stack.pop()
	e.stack.pop()

	return e.get_value(e.none_operand)
}

pub fn (mut e ExecutionContext) call_static(object_name string, func_name string, args []Value) ?&Value {
	mut func := e.find_global_func(object_name, func_name) or { return none }
	return e.run_commands(func: func, args: args)
}
