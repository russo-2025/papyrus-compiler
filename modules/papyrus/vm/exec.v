module vm

fn (mut e ExecutionContext) print_stack() {
	for i := 0; i < e.stack.len(); i++ {
		val := e.stack.peek_offset(i)
		mut val_str := match val.typ.typ {
			.none { "type: none" }
			.i32 { "type: integer; data: ${val.get[i32]()}" }
			.f32 { "type: float; data: ${val.get[f32]()}" }
			.bool { "type: bool; data: ${val.get[bool]()}" }
			.string { "type: string; data: ${val.get[string]()}" }
			.object { "type: object; data: ${ptr_str( unsafe { val.data.object})}" }
			.array { panic("TODO") }
		}
		println("offset: ${i}; ${val_str}")
	}
}

@[direct_array_access; inline]
fn (mut e ExecutionContext) get_value(operand Operand) &Value {
	return match operand.typ {
		.none_value { &e.none_value }
		.stack { e.stack.peek_offset(operand.stack_offset) }
		.reg_self,
		.reg_state,
		
		.regb1,
		.regb2,

		.regi1,
		.regi2,
		.regi3,

		.regf1,
		.regf2,
		.regf3 {
			&e.registers[int(operand.typ)]
		}
		.registers_count {
			panic("WTF") //  TODO bug issue
			&e.none_value
		}
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
		.regi3,

		.regf1,
		.regf2,
		.regf3 {
			&e.registers[int(operand.typ)]
		}
		.none_value {
			panic("cannot change a Value with type None") //  TODO bug issue
			&e.none_value
		}
		.stack {
			e.stack.peek_offset(operand.stack_offset)
		}
		.registers_count {
			panic("WTF") //  TODO bug issue
			&e.none_value
		}
	}

	if !(val1.typ.typ == val2.typ.typ) {
		print_backtrace()
	}

	assert val1.typ.typ == val2.typ.typ
	assert val1.typ.raw == val2.typ.raw

	match val1.typ.typ {
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
		.object {
			unsafe { val1.data.object = val2.data.object }
		}
		.array {
			unsafe { val1.data.array = val2.data.array }
		}
	}
}

@[inline]
fn (mut e ExecutionContext) cast_value(from_operand Operand, to_operand Operand) {
	from := e.get_value(from_operand)
	mut to := e.get_value(to_operand)

	match to.typ.typ {
		.none { panic("TODO object -> bool") }
		.bool {
			match from.typ.typ {
				.none { to.set_data[bool](false) }
				.bool { panic("invalid cast bool -> bool") }
				.i32 { to.set_data[bool](from.get[i32]() != 0) }
				.f32 { to.set_data[bool](from.get[f32]() != 0.0) }
				.string { to.set_data[bool](from.get[string]().len > 0) }
				.object {
					if from.object_is_none() {
						to.set_data[bool](false)
					}
					else {
						to.set_data[bool](true)
					}
				}
				.array {
					if from.get_array_length() >= 1 {
						to.set_data[bool](true)
					}
					else {
						to.set_data[bool](false)
					}
				}
			}
		}
		.i32 {
			match from.typ.typ {
				.bool { to.set_data[i32](if from.get[bool]() { i32(1) } else { i32(0) }) }
				.i32 { panic("invalid cast i32 -> i32") }
				.f32 { to.set_data[i32](i32(from.get[f32]())) } // TODO f32 to i32
				.string { to.set_data[i32](from.get[string]().i32()) }
				else { panic("invalid cast ${from.typ} -> i32") }
			}
		}
		.f32 {
			match from.typ.typ {
				.bool { to.set_data[f32](if from.get[bool]() { f32(1.0) } else { f32(0.0) }) }
				.i32 { to.set_data[f32](f32(from.get[i32]())) } // TODO f32 to i32
				.f32 { panic("invalid cast f32 -> f32") }
				.string { to.set_data[f32](from.get[string]().f32()) }
				else { panic("invalid cast ${from.typ} -> f32") }
			}
		}
		.string {
			to.set_data[string](from.to_string())
		}
		.object {
			match from.typ.typ {
				.none {
					to.set_object_none()
				}
				.object {
					panic("TODO object <---> object; ${from.typ.raw} -> ${to.typ.raw}")
				}
				else {
					panic("invalid cast ${from.typ.raw} -> ${to.typ.raw}")
				}
			}
		}
		.array {
			panic("invalid cast ${from.typ.raw} -> ${to.typ.raw}")
		}
	}
}

@[inline; direct_array_access]
fn (mut e ExecutionContext) native_call_command(mut call Call) ! {
	assert call.is_native
	assert call.cache_func != none
	assert call.native_cache_func != none

	native_func := call.native_cache_func or { panic("invalid cache func") }

	if call.is_parent_call {
		return error("TODO support parent call")
	}

	mut vargs := []Value{ cap:call.args.len }
	for arg in call.args {
		vargs << e.get_value(arg)
	}

	self := if call.is_global { &e.none_value } else { e.get_value(call.self) }
	tres := native_func.cb(e, self, vargs) !

	e.set_value(call.result, tres)
}

@[inline; direct_array_access]
fn (mut e ExecutionContext) call_command(mut call Call) ! {
	assert !call.is_native
	assert call.cache_func != none

	mut call_func := call.cache_func or { panic("invalid cache func") }

	if call.is_parent_call {
		return error("TODO support parent call")
	}

	mut vargs := []Value{ cap:call.args.len }
	for arg in call.args {
		vargs << e.get_value(arg)
	}
	
	self := if call.is_global { &e.none_value } else { e.get_value(call.self) }
	tres := e.call(mut call_func, self, vargs) or { return error("err") }
	e.set_value(call.result, tres)
}

@[direct_array_access]
fn (mut e ExecutionContext) run_commands(mut func Function) !&Value {
	//e.print_stack()

	//eprintln("[ExecutionContext.run_commands] run ${func.name} ${e.stack.peek().get[i32]()}")
	for i := 0; i < func.commands.len; i++ {
		mut command := &func.commands[i]
		e.instruction_count++

		//eprintln("[ExecutionContext.run_commands] ${command.type_name()}")
		match mut command {
			Call {
				if command.cache_func == none && command.native_cache_func == none {
					mut call_func := &Function(unsafe {nil})

					if command.is_global {
						call_func = e.find_global_func(command.object, command.name) or { return error("global function not found") }
						command.cache_func = call_func
					}
					else {
						self := e.get_value(command.self).get_object()
						call_func = e.find_method(self.info.name, self.state.name, command.name) or { return error("method not found") }
						command.cache_func = call_func
					}

					cache_func := command.cache_func or { panic("invalid cahce func")}

					if cache_func.is_native {
						command.is_native = true
						command.native_cache_func = e.find_native_function(command.object, command.name) or { return error("native function not found") }
					}
				}

				if command.is_native {
					e.native_call_command(mut command) !
					continue
				}

				e.call_command(mut command) !
				
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
					else  { return error("invalid op in eval.PrefixExpr") }
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
						assert e.get_value(command.value1).typ.typ == e.get_value(command.value2).typ.typ

						match e.get_value(command.value1).typ.typ {
							.none { return error("TODO") }
							.bool,
							.i32,
							.f32,
							.string {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1) == e.get_value(command.value2))
							}
							.object {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1) == e.get_value(command.value2))
							}
							.array { return error("WTF ${e.get_value(command.value1).typ.raw} == ${e.get_value(command.value2).typ.raw}") }
						}
					}
					.cmp_lt {
						assert e.get_value(command.value1).typ.typ == e.get_value(command.value2).typ.typ

						match e.get_value(command.value1).typ.typ {
							.i32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() < e.get_value(command.value2).get[i32]())
							}
							.f32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() < e.get_value(command.value2).get[f32]())
							}
							else { return error("TODO") }
						}
					}
					.cmp_le {
						assert e.get_value(command.value1).typ.typ == e.get_value(command.value2).typ.typ
						
						match e.get_value(command.value1).typ.typ {
							.i32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() <= e.get_value(command.value2).get[i32]())
							}
							.f32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() <= e.get_value(command.value2).get[f32]())
							}
							else { return error("TODO") }
						}
					}
					.cmp_gt {
						assert e.get_value(command.value1).typ.typ == e.get_value(command.value2).typ.typ
						
						match e.get_value(command.value1).typ.typ {
							.i32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() > e.get_value(command.value2).get[i32]())
							}
							.f32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() > e.get_value(command.value2).get[f32]())
							}
							else { return error("TODO") }
						}
					}
					.cmp_ge {
						assert e.get_value(command.value1).typ.typ == e.get_value(command.value2).typ.typ
						
						match e.get_value(command.value1).typ.typ {
							.i32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[i32]() >= e.get_value(command.value2).get[i32]())
							}
							.f32 {
								mut res := e.get_value(command.result)
								res.set[bool](e.get_value(command.value1).get[f32]() >= e.get_value(command.value2).get[f32]())
							}
							else { return error("TODO") }
						}
					}
					.strcat {
						assert e.get_value(command.result).typ.typ == .string
						assert e.get_value(command.value1).typ.typ == .string
						assert e.get_value(command.value1).typ.typ == .string

						mut res := e.get_value(command.result)
						res.set[string](e.get_value(command.value1).get[string]() + e.get_value(command.value2).get[string]())
					}
					else { return error("invalid op in eval.InfixExpr") }
				}
			}
			CastExpr {
				e.cast_value(command.value, command.result)
			}
			Return {
				res := e.get_value(command.value)
				
				/*
				if res.typ.typ == .i32 {
					eprintln("[ExecutionContext.run_commands] end return ${func.name} - ${res.get[i32]()}")
				}
				else if res.typ.typ == .bool {
					eprintln("[ExecutionContext.run_commands] end return ${func.name} - ${res.get[bool]()}")
				}*/
				
				return res
			}
			Assign {
				e.set_value(command.result, e.get_value(command.value))
			}
			Jump {
				if command.with_condition {
					if command.true_condition {
						if e.get_value(command.value).get[bool]() {
							i-- // next for i++
							i += command.offset
							continue
						}
					}
					else {
						if !e.get_value(command.value).get[bool]() {
							i-- // next for i++
							i += command.offset
							continue
						}
					}
				}
				else {
					i-- // next for i++
					i += command.offset
				}
			}
			ArrayCreate {
				mut res := e.get_value(command.result)
				mut size := e.get_value(command.size)
				e.array_resize(mut res, size)
			}
			GetArrayLength {
				mut res := e.get_value(command.result)
				mut array := e.get_value(command.array)

				res.set[i32](array.get_array_length())
			}
			GetArrayElement {
				mut array := e.get_value(command.array)
				mut index := e.get_value(command.index)

				e.set_value(command.result, array.get_array_element(index.to_array_index()))
			}
			SetArrayElement {
				mut array := e.get_value(command.array)
				mut index := e.get_value(command.index)
				mut value := e.get_value(command.value)
				
				array.set_array_element(index, value)
			}
			FindArrayElement {
				mut array := e.get_value(command.array)
				mut value := e.get_value(command.value)
				mut start_index := e.get_value(command.start_index).get[VmArrayIndex]()

				len := array.get_array_length()
				mut found := VmArrayIndex(-1)

				if !command.is_reverse {
					for k := start_index ; k < len; k++ {
						if value == array.get_array_element(k) {
							found = VmArrayIndex(k)
							break
						}
					}
				}
				else {
					start_index = if start_index == -1 { len - 1 } else { start_index }
					
					for k := start_index ; k >= 0; k-- {
						if value == array.get_array_element(k) {
							found = VmArrayIndex(k)
							break
						}
					}
				}
					
				e.set_value(command.result, e.create_index(found))
			}
		}
	}
	
	//println("[ExecutionContext.run_commands] end ${func.name}")

	return e.get_value(e.loader.none_operand)
}

@[inline]
fn (mut ctx ExecutionContext) call(mut func Function, self &Value, args []Value) !&Value {
	ctx.save_registers()

	if !func.is_global {
		ctx.set_self_register(self)
	}

	ctx.stack.push_many(func.stack_data.data, func.stack_data.len)
	ctx.stack.push_many(args.data, args.len)

	res := ctx.run_commands(mut func) !

	ctx.stack.pop_len(args.len)
	ctx.stack.pop_len(func.stack_data.len)
	
	ctx.restore_registers()
	
	return res
}

pub fn (mut ctx ExecutionContext) call_method(self &Value, func_name string, args []Value) !&Value {
	// TODO support native funcs call
	mut func := ctx.find_method(self.get_object().info.name, self.get_object().state.name, func_name) or { return error("method with name `${self.get_object().info.name}.${self.get_object().state.name}.${func_name}` not found") }
	return ctx.call(mut func, self, args) !
}

pub fn (mut ctx ExecutionContext) call_static(object_name string, func_name string, args []Value) !&Value {
	// TODO support native funcs call
	mut func := ctx.find_global_func(object_name, func_name) or { return error("function with name `${object_name}.${func_name}` not found") }
	return ctx.call(mut func, ctx.none_value, args) !
}
