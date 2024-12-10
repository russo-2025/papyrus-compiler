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

@[inline]
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

@[inline]
pub fn (mut ctx ExecutionContext) create_object(script &Script) Value {
	assert script.name != ""
	assert script.auto_state != voidptr(0)

	obj := &Object{
		info: script
		state: script.auto_state
	}

	mut obj_value := create_value_typ(.object)
	obj_value.set_object(obj)

	return obj_value
}

@[direct_array_access]
fn (mut e ExecutionContext) run_commands(mut func &Function) &Value {
	//e.print_stack()
	for i := 0; i < func.commands.len; i++ {
		mut command := &func.commands[i]
		e.instruction_count++

		match mut command {
			Call {
				mut call_func := &Function(unsafe {nil})
				
				if command.cache_func != none {
					call_func = command.cache_func
				}
				else if command.is_global {
					call_func = e.find_global_func(command.object, command.name) or { panic("global function not found") }
					command.cache_func = call_func
				}
				else {
					obj := e.get_value(command.self).get_object()
					call_func = e.find_method(command.object, obj.state.name, command.name) or { panic("method not found") }
					command.cache_func = call_func
				}

				assert command.is_global == func.is_global

				if command.is_parent_call {
					panic("TODO support parent call")
				}

				mut vargs := []Value{ cap:command.args.len }
				for arg in command.args {
					vargs << e.get_value(arg)
				}
				
				self := if command.is_global { &none_value } else { e.get_value(command.self) }
				tres := e.call(mut call_func, self, vargs) or { panic("err") }
				e.set_value(command.result, tres)
				
			}
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
					.strcat {
						mut res := e.get_value(command.result)
						res.set[string](e.get_value(command.value1).get[string]() + e.get_value(command.value2).get[string]())
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
				if command.with_condition {
					if command.true_condition {
						if e.get_value(command.value).get[bool]() {
							i += command.offset
							continue
						}
					}
					else {
						if !e.get_value(command.value).get[bool]() {
							i += command.offset
							continue
						}
					}
				}

				i += command.offset
			}
		}
	}
	
	//println("[run Return] ${func.name} stacklen${e.stack.len()}")

	return e.get_value(e.loader.none_operand)
}

@[inline]
fn (mut ctx ExecutionContext) call(mut func Function, self &Value, args []Value) ?&Value {
	ctx.save_registers()

	if !func.is_global {
		ctx.set_self_register(self)
	}
	ctx.stack.push_many(func.stack_data.data, func.stack_data.len)
	ctx.stack.push_many(args.data, args.len)

	res := ctx.run_commands(mut func)

	ctx.stack.pop_len(args.len)
	ctx.stack.pop_len(func.stack_data.len)
	
	ctx.restore_registers()
	
	return res
}

pub fn (mut ctx ExecutionContext) call_method(self &Value, func_name string, args []Value) ?&Value {
	mut func := ctx.find_method(self.get_object().info.name, self.get_object().state.name, func_name) or { return none }
	return ctx.call(mut func, self, args)
}

pub fn (mut ctx ExecutionContext) call_static(object_name string, func_name string, args []Value) ?&Value {
	mut func := ctx.find_global_func(object_name, func_name) or { return none }
	return ctx.call(mut func, none_value, args)
}
