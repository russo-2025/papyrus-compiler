module vm

@[params]
struct RunCommandsParams {
	func		&Function
	//args		[]Value
	is_global	bool
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
	/*mut val1 := match operand.typ {
		.reg_i1 { &e.reg_i1 }
		.reg_i2 { &e.reg_i2 }
		.reg_i3 { &e.reg_i3 }
		.reg_i4 { &e.reg_i4 }
		.reg_f1 { &e.reg_f1 }
		.reg_f2 { &e.reg_f2 }
		.reg_f3 { &e.reg_f3 }
		.reg_f4 { &e.reg_f4 }
		.int_value { &none_value }
		.float_value { &none_value }
		.stack { e.stack.peek_offset(operand.stack_offset) }
	} */
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
	/*match operand.typ {
		.reg_i1 { return &e.reg_i1 }
		.reg_i2 { return &e.reg_i2 }
		.reg_i3 { return &e.reg_i3 }
		.reg_i4 { return &e.reg_i4 }
		.reg_f1 { return &e.reg_f1 }
		.reg_f2 { return &e.reg_f2 }
		.reg_f3 { return &e.reg_f3 }
		.reg_f4 { return &e.reg_f4 }
		.int_value { panic("wtf") }
		.float_value { panic("wtf") }
		.stack { return e.stack.peek_offset(operand.stack_offset) }
	}*/

	return e.stack.peek_offset(operand.stack_offset)
}

fn (mut e ExecutionContext) run_commands(p RunCommandsParams) &Value {
	/*e.stack.push_many(p.func.stack_data.reverse())
	
	for i := p.args.len - 1; i >= 0; i-- {
		e.stack.push(p.args[i])
	}

	//TODO только для методов
	e.stack.push(create_value_data[string]("default state name")) // state_name_operand
	e.stack.push(none_value) // self_operand

*/
	//println(p.func.name)
	//e.print_stack()
	for command in p.func.commands {
		//println(command)
		match command {
			CallStatic {
				func := e.find_global_func(command.object, command.name) or { panic("fn not found") }
				
				mut vargs := []Value{ cap:command.args.len }
				for arg in command.args {
					vargs << e.get_value(arg)
				}

				e.stack.push_many(func.stack_data.reverse())

				for i := vargs.len - 1; i >= 0; i-- {
					e.stack.push(vargs[i])
				}

				e.stack.push(create_value_data[string]("default state name")) // state_name_operand
				e.stack.push(none_value) // self_operand

				tres := e.run_commands(func: func, /*args: vargs*/)

				e.stack.pop_len(func.stack_data.len)
				e.stack.pop_len(command.args.len)
				e.stack.pop()
				e.stack.pop()
				
				e.set_value(command.result, tres)
			}
			CallMethod { panic("TODO CallMethod") }
			PrefixExpr {
				match command.op {
					.not {
						mut res := e.get_value(command.result)
						res.set[bool](!e.get_value(command.value).get[bool]())
					}
					.ineg {
						mut res := e.get_value(command.result)
						res.set[i32](-e.get_value(command.value).get[i32]())
					}
					.fneg {
						mut res := e.get_value(command.result)
						res.set[f32](-e.get_value(command.value).get[f32]())
					}
					else  { panic("invalid op in eval.PrefixExpr") }
				}
				
			}
			InfixExpr {
				match command.op {
					.iadd {
						mut res := e.get_value(command.result)
						res.set[i32](e.get_value(command.value1).get[i32]() + e.get_value(command.value2).get[i32]()) 
					}
					.fadd {
						mut res := e.get_value(command.result)
						res.set[f32](e.get_value(command.value1).get[f32]() + e.get_value(command.value2).get[f32]()) 
					}
					.isub {
						mut res := e.get_value(command.result)
						res.set[i32](e.get_value(command.value1).get[i32]() - e.get_value(command.value2).get[i32]()) 
					}
					.fsub {
						mut res := e.get_value(command.result)
						res.set[f32](e.get_value(command.value1).get[f32]() - e.get_value(command.value2).get[f32]()) 
					}
					.imul {
						mut res := e.get_value(command.result)
						res.set[i32](e.get_value(command.value1).get[i32]() * e.get_value(command.value2).get[i32]()) 
					}
					.fmul {
						mut res := e.get_value(command.result)
						res.set[f32](e.get_value(command.value1).get[f32]() * e.get_value(command.value2).get[f32]()) 
					}
					.idiv {
						mut res := e.get_value(command.result)
						res.set[i32](e.get_value(command.value1).get[i32]() / e.get_value(command.value2).get[i32]()) 
					}
					.fdiv {
						mut res := e.get_value(command.result)
						res.set[f32](e.get_value(command.value1).get[f32]() / e.get_value(command.value2).get[f32]()) 
					}
					.imod {
						mut res := e.get_value(command.result)
						res.set[i32](e.get_value(command.value1).get[i32]() % e.get_value(command.value2).get[i32]()) 
					}
					.cmp_eq {
						match e.get_value(command.value1).typ {
							.integer {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() == e.get_value(command.value2).get[i32]())
							}
							.float {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() == e.get_value(command.value2).get[f32]())
							}
							else { panic("TODO") }
						}
					}
					.cmp_lt {
						match e.get_value(command.value1).typ {
							.integer {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() < e.get_value(command.value2).get[i32]())
							}
							.float {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() < e.get_value(command.value2).get[f32]())
							}
							else { panic("TODO") }
						}
					}
					.cmp_le {
						match e.get_value(command.value1).typ {
							.integer {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() <= e.get_value(command.value2).get[i32]())
							}
							.float {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() <= e.get_value(command.value2).get[f32]())
							}
							else { panic("TODO") }
						}
					}
					.cmp_gt {
						match e.get_value(command.value1).typ {
							.integer {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() > e.get_value(command.value2).get[i32]())
							}
							.float {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() > e.get_value(command.value2).get[f32]())
							}
							else { panic("TODO") }
						}
					}
					.cmp_ge {
						match e.get_value(command.value1).typ {
							.integer {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() >= e.get_value(command.value2).get[i32]())
							}
							.float {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() >= e.get_value(command.value2).get[f32]())
							}
							else { panic("TODO") }
						}
					}
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
/*
				e.stack.pop_len(p.func.stack_data.len)
				e.stack.pop_len(p.args.len)
				e.stack.pop()
				e.stack.pop()
*/
				/*if res.typ == .float {
					println("[run Return] ${p.func.name} res ${res.get[f32]()} stacklen${e.stack.len()}")
				}
				else if res.typ == .integer {
					println("[run Return] ${p.func.name} res ${res.get[i32]()} stacklen${e.stack.len()}")
				}*/

				return res
			}
			Assign {
				e.set_value(command.result, e.get_value(command.value))
			}
			Jump {
				panic("TODO")
			}
			JumpTrue {
				panic("TODO")
			}
			JumpFalse {
				panic("TODO")
			}
		}
	}
/*
	e.stack.pop_len(p.func.stack_data.len)
	e.stack.pop_len(p.args.len)
	e.stack.pop()
	e.stack.pop()
*/
	//println("[run Return] ${p.func.name} stacklen${e.stack.len()}")

	return e.get_value(e.none_operand)
}

pub fn (mut e ExecutionContext) call_static(object_name string, func_name string, args []Value) ?&Value {
	mut func := e.find_global_func(object_name, func_name) or { return none }
	e.stack.push_many(func.stack_data.reverse())
	/*for arg in args {
		e.stack.push(arg)
	}*/
	for i := args.len - 1; i >= 0; i-- {
		e.stack.push(args[i])
	}

	e.stack.push(create_value_data[string]("default state name")) // state_name_operand
	e.stack.push(none_value) // self_operand
	res := e.run_commands(func: func/*, args: args*/)

	e.stack.pop_len(func.stack_data.len)
	e.stack.pop_len(args.len)
	e.stack.pop()
	e.stack.pop()

	return res
}
