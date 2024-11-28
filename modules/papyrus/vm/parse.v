module vm

import pex

fn (mut e ExecutionContext) load_func(object_name string, state_name string, pex_func &pex.Function) {
	mut commands := []Command{}

	mut fn_stack_data := []Value{}	
	mut init_fn_stack := InitFnStack {
		data: fn_stack_data
	}
	commands << init_fn_stack
	e.fn_stack_data = fn_stack_data // fix commands[0].data.len: 0 e.fn_stack_data.len: 6

	//e.fn_stack_data = []Value{}
	e.local_id_by_name = map[pex.StringId]int{}
	e.local_typ_by_name = map[pex.StringId]ValueType{}

	for pex_param in pex_func.info.params {
		typ1 := get_type_from_type_name(e.get_string(pex_param.typ))

		e.local_typ_by_name[pex_param.name] = typ1
		e.local_id_by_name[pex_param.name] = e.fn_stack_data.len

		e.fn_stack_data << create_value_typ(typ1)
	}

	for pex_local in pex_func.info.locals {
		typ2 := get_type_from_type_name(e.get_string(pex_local.typ))

		e.local_typ_by_name[pex_local.name] = typ2
		e.local_id_by_name[pex_local.name] = e.fn_stack_data.len

		e.fn_stack_data << create_value_typ(typ2)
	}

	e.self_operand = e.create_operand(none_value) // self
	e.state_name_operand = e.create_operand(create_value_data[string]("default state name"))
	
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
				commands << InfixExpr{
					op: inst.op
					result: e.parse_value(inst.args[0])
					value1: e.parse_value(inst.args[1])
					value2: e.parse_value(inst.args[2])
				}
			}
			.not { panic("TODO ${inst.op}") }
			.ineg { panic("TODO ${inst.op}") }
			.fneg { panic("TODO ${inst.op}") }
			.assign {
				commands << Assign{
					result: e.parse_value(inst.args[0])
					value: e.parse_value(inst.args[1])
				}
			}
			.cast {
				commands << CastExpr{
					result: e.parse_value(inst.args[0])
					value: e.parse_value(inst.args[1])
				}
			}
			.jmp { panic("TODO ${inst.op}") }
			.jmpt { panic("TODO ${inst.op}") }
			.jmpf { panic("TODO ${inst.op}") }
			.callmethod {
				args_count := inst.args[3].to_integer()

				mut intr_args := []Operand{}
				if args_count > 0 {
					for j in 0..args_count {
						intr_args << e.parse_value(inst.args[4 + j])
					}
				}
				
				commands << CallMethod{
					name: e.get_string(inst.args[0].to_string_id())
					self: e.parse_value(inst.args[1])
					result: e.parse_value(inst.args[2])
					args: intr_args
				}
			}
			.callparent { panic("TODO ${inst.op}") }
			.callstatic {
				args_count := inst.args[3].to_integer()
				
				mut intr_args := []Operand{}
				if args_count > 0 {
					for j in 0..args_count {
						intr_args << e.parse_value(inst.args[4 + j])
					}
				}
				
				commands << CallStatic{
					object: e.get_string(inst.args[0].to_string_id())
					name: e.get_string(inst.args[1].to_string_id())
					result: e.parse_value(inst.args[2])
					args: intr_args
				}
			}
			.ret {
				commands << Return{
					value: e.parse_value(inst.args[0])
				}
			}
			.strcat { panic("TODO ${inst.op}") }
			.propget { panic("TODO ${inst.op}") }
			.propset { panic("TODO ${inst.op}") }
			.array_create { panic("TODO ${inst.op}") }
			.array_length { panic("TODO ${inst.op}") }
			.array_getelement { panic("TODO ${inst.op}") }
			.array_setelement { panic("TODO ${inst.op}") }
			.array_findelement { panic("TODO ${inst.op}") }
			.array_rfindelement { panic("TODO ${inst.op}") }
			._opcode_end { panic("wtf") }
		}
	}

	//(commands[0] as InitFnStack).data = e.fn_stack_data
	/*
	if command := commands[0] is InitFnStack {
		command.data = e.fn_stack_data
	}
	*/
	//println(typeof(commands[0]).name)
	//mut init_stack := commands[0]
	//(commands[0] as InitFnStack).data = e.fn_stack_data
	///((commands[0]) as InitFnStack).data = e.fn_stack_data
	println("commands[0].data.len: ${(commands[0] as InitFnStack).data.len} e.fn_stack_data.len: ${e.fn_stack_data.len}")

	e.register_func(object_name, state_name, &Function {
		name: e.get_string(pex_func.name)
		commands: commands
		is_global: pex_func.info.is_global()
	})
}

fn (mut e ExecutionContext) create_operand(value Value) Operand {
	stack_offset := e.fn_stack_data.len
	e.fn_stack_data << value
	return Operand {
		stack_offset: stack_offset
	}
}

fn (mut e ExecutionContext) parse_value(pex_value pex.VariableValue) Operand {
	match pex_value.typ {
		.null {
			return e.none_operand
		}
		.boolean {
			return e.create_operand(create_value_typ(.bool))
		}
		.float {
			return e.create_operand(create_value_typ(.float))
		}
		.integer {
			return e.create_operand(create_value_typ(.integer))
		}
		.str {
			return e.create_operand(create_value_typ(.string))
		}
		.identifier {
			if pex_value.to_string_id() in e.local_id_by_name {
				return Operand {
					stack_offset: e.local_id_by_name[pex_value.to_string_id()] or { panic("local not found")}
				}
			}
			else if e.get_string(pex_value.to_string_id()).to_lower() == "::state" {
				return e.state_name_operand
			}
			else if e.get_string(pex_value.to_string_id()).to_lower() == "self" {
				return e.self_operand
			}
			else {
				panic("identifier not found ${pex_value.to_string_id()} - `${e.get_string(pex_value.to_string_id())}`")
			}
		}
	}
}

fn get_type_from_type_name(name string) ValueType {
	lname := name.to_lower()
	return match lname {
		"string" { .string }
		"int" { .integer }
		"float" { .float }
		"bool" { .bool }
		// TODO object
		// TODO array
		else { .object } 
	}
}