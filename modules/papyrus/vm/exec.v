module vm

fn (mut e ExecutionContext) print_stack() {
	for i := 0; i < e.stack.len(); i++ {
		val := e.stack.peek_offset(i)
		mut val_str := match val.typ {
			.none { "type: none" }
			.i32 { "type: integer; data: ${val.get[i32]()}" }
			.f32 { "type: float; data: ${val.get[f32]()}" }
			.bool { "type: bool; data: ${val.get[bool]()}" }
			.string { "type: string; data: ${val.get[string]()}" }
			.object { panic("TODO") }
			.array { panic("TODO") }
		}
		println("offset: ${i}; ${val_str}")
	}
}

@[direct_array_access; inline]
fn (mut e ExecutionContext) get_value(operand Operand) &Value {
	return match operand.typ {
		.reg_self,
		.reg_state,
		
		.regb1,
		.regb2,

		.regi1,
		.regi2,
		.regi3,/*
		.regi4,
		.regi5,
		.regi6,*/

		.regf1,
		.regf2,
		.regf3/*,
		.regf4,
		.regf5,
		.regf6*/ {
			&e.registers[int(operand.typ)]
		}
		.stack { e.stack.peek_offset(operand.stack_offset) }
	}
}

@[direct_array_access; inline]
fn (mut e ExecutionContext) set_value(operand Operand, val2 &Value) {
	mut val1 := match operand.typ {
		.reg_self,
		.reg_state,

		.regb1,
		.regb2,

		.regi1,
		.regi2,
		.regi3,/*
		.regi4,
		.regi5,
		.regi6,*/

		.regf1,
		.regf2,
		.regf3/*,
		.regf4,
		.regf5,
		.regf6*/ {
			&e.registers[int(operand.typ)]
		}
		.stack {
			e.stack.peek_offset(operand.stack_offset)
		}
	}

	match val1.typ {
		.none { panic("TODO") }
		.i32 {
			unsafe { val1.data.i32 = val2.data.i32 }
		}
		.f32 {
			unsafe { val1.data.f32 = val2.data.f32 }
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

fn (mut e ExecutionContext) cast_value(from_operand Operand, to_operand Operand) {
	from := e.get_value(from_operand)
	mut to := e.get_value(to_operand)

	match to.typ {
		.none { panic("TODO object -> bool") }
		.bool {
			match from.typ {
				.none { to.set_data[bool](false) }
				.bool { panic("invalid cast bool -> bool") }
				.i32 { to.set_data[bool](from.get[i32]() != 0) }
				.f32 { to.set_data[bool](from.get[f32]() != 0.0) }
				.string { to.set_data[bool](from.get[string]().len > 0) }
				.object { panic("TODO object -> bool") }
				.array { panic("TODO array -> bool") }
			}
		}
		.i32 {
			match from.typ {
				.bool { to.set_data[i32](if from.get[bool]() { i32(1) } else { i32(0) }) }
				.i32 { panic("invalid cast i32 -> i32") }
				.f32 { to.set_data[i32](i32(from.get[f32]())) } // TODO f32 to i32
				.string { to.set_data[i32](from.get[string]().i32()) }
				else { panic("invalid cast ${from.typ} -> i32") }
			}
		}
		.f32 {
			match from.typ {
				.bool { to.set_data[f32](if from.get[bool]() { f32(1.0) } else { f32(0.0) }) }
				.i32 { to.set_data[f32](f32(from.get[i32]())) } // TODO f32 to i32
				.f32 { panic("invalid cast f32 -> f32") }
				.string { to.set_data[f32](from.get[string]().f32()) }
				else { panic("invalid cast ${from.typ} -> f32") }
			}
		}
		.string {
			match from.typ {
				.none { to.set_data[string]("None") }
				.bool { to.set_data[string](if from.get[bool]() { "True" } else { "False" }) }
				.i32 { to.set_data[string](from.get[i32]().str()) }
				.f32 { to.set_data[string](from.get[f32]().str()) }
				.string { panic("invalid cast string -> string") }
				.object { panic("TODO object -> bool") }
				.array { panic("TODO array -> bool") }
			}
		}
		.object { panic("TODO cast object") }
		.array { panic("TODO cast array") }
	}
}

fn (mut e ExecutionContext) run_commands(mut func &Function) &Value {
	//println(func.name)
	//e.print_stack()
	for mut command in func.commands {
		e.instruction_count++
		//println(command)
		match mut command {
			CallStatic {
				mut call_func := &Function(unsafe {nil})
				
				if command.cache_func != none {
					call_func = command.cache_func
				}
				else {
					call_func = e.find_global_func(command.object, command.name) or { panic("fn not found") }
					command.cache_func = call_func
				}
				
				mut vargs := []Value{ cap:command.args.len }
				for arg in command.args {
					vargs << e.get_value(arg)
				}

				e.stack.push_many(call_func.stack_data.data, call_func.stack_data.len)
				e.stack.push_many(vargs.data, vargs.len)

				e.save_registers()
				tres := e.run_commands(mut call_func)
				e.restore_registers()

				e.stack.pop_len(vargs.len)
				e.stack.pop_len(call_func.stack_data.len)
				
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
			AddExprReg {
				unsafe{
					e.registers[int(command.result)].data.i32 = e.registers[int(command.value1)].data.i32 + e.registers[int(command.value2)].data.i32
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
							.i32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() == e.get_value(command.value2).get[i32]())
							}
							.f32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() == e.get_value(command.value2).get[f32]())
							}
							else { panic("TODO") }
						}
					}
					.cmp_lt {
						match e.get_value(command.value1).typ {
							.i32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() < e.get_value(command.value2).get[i32]())
							}
							.f32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() < e.get_value(command.value2).get[f32]())
							}
							else { panic("TODO") }
						}
					}
					.cmp_le {
						match e.get_value(command.value1).typ {
							.i32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() <= e.get_value(command.value2).get[i32]())
							}
							.f32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() <= e.get_value(command.value2).get[f32]())
							}
							else { panic("TODO") }
						}
					}
					.cmp_gt {
						match e.get_value(command.value1).typ {
							.i32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() > e.get_value(command.value2).get[i32]())
							}
							.f32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() > e.get_value(command.value2).get[f32]())
							}
							else { panic("TODO") }
						}
					}
					.cmp_ge {
						match e.get_value(command.value1).typ {
							.i32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() >= e.get_value(command.value2).get[i32]())
							}
							.f32 {
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
				e.cast_value(command.value, command.result)
			}
			Return {
				res := e.get_value(command.value)
				
				/*
				if res.typ == .f32 {
					println("[run Return] ${func.name} res ${res.get[f32]()} stacklen${e.stack.len()}")
				}
				else if res.typ == .i32 {
					println("[run Return] ${func.name} res ${res.get[i32]()} stacklen${e.stack.len()}")
				}
				*/

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
	
	//println("[run Return] ${func.name} stacklen${e.stack.len()}")

	return e.get_value(e.loader.none_operand)
}

pub fn (mut ctx ExecutionContext) call_static(object_name string, func_name string, args []Value) ?Value {
	mut func := ctx.find_global_func(object_name, func_name) or { return none }
	ctx.stack.push_many(func.stack_data.data, func.stack_data.len)
	ctx.stack.push_many(args.data, args.len)
	
	ctx.save_registers()
	res := ctx.run_commands(mut func)
	ctx.restore_registers()

	ctx.stack.pop_len(args.len)
	ctx.stack.pop_len(func.stack_data.len)

	//println("instruction_count: ${ctx.instruction_count} -")
	return *res
}
