module vm

import pex

fn (mut e ExecutionContext) load_func(object_name string, state_name string, pex_func &pex.Function) {
	e.commands = []Command{ cap: 15 }
	e.fn_stack_count = e.stack.len() - 1
	e.fn_stack_data = []Value{ cap: 5 }
	e.operand_by_name = map[pex.StringId]Operand

	for i in 0..e.used_registers.len {
		e.used_registers[i] = false
	}
	e.self_operand = Operand { typ: .reg_self }
	e.state_name_operand = Operand { typ: .reg_state }

	mut fn_params := []Param{}

	for i := pex_func.info.params.len - 1; i >= 0; i-- {
		pex_param := pex_func.info.params[i]
		typ1 := get_type_from_type_name(e.get_string(pex_param.typ))
		
		e.operand_type_by_name[pex_param.name] = typ1
		e.operand_by_name[pex_param.name] = Operand {
			typ: .stack
			stack_offset: e.fn_stack_count
		}
		e.fn_stack_count++

		fn_params << Param{
			name: e.get_string(pex_param.name)
			typ: typ1
		}
	}

	for pex_local in pex_func.info.locals {
		typ2 := get_type_from_type_name(e.get_string(pex_local.typ))
		e.operand_by_name[pex_local.name] = e.create_operand(create_value_typ(typ2))
		e.operand_type_by_name[pex_local.name] = typ2
	}

	for inst in pex_func.info.instructions {
		//println("[parse] ${inst.op} e.fn_stack_count ${e.fn_stack_count}")
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
				e.commands << InfixExpr{
					op: inst.op
					result: e.parse_value(inst.args[0])
					value1: e.parse_value(inst.args[1])
					value2: e.parse_value(inst.args[2])
				}
			}
			.not,
			.ineg,
			.fneg {
				e.commands << PrefixExpr{
					op: inst.op
					result: e.parse_value(inst.args[0])
					value: e.parse_value(inst.args[1])
				}
			}
			.assign {
				e.commands << Assign{
					result: e.parse_value(inst.args[0])
					value: e.parse_value(inst.args[1])
				}
			}
			.cast {
				e.commands << CastExpr{
					result: e.parse_value(inst.args[0])
					value: e.parse_value(inst.args[1])
				}
			}
			.jmp {
				e.commands << Jump{
					offset: i32(inst.args[0].to_integer()) // TODO int -> i32
				}
			}
			.jmpt {
				e.commands << JumpTrue{
					value: e.parse_value(inst.args[0])
					offset: i32(inst.args[0].to_integer()) // TODO int -> i32
				}
			}
			.jmpf {
				e.commands << JumpFalse{
					value: e.parse_value(inst.args[0])
					offset: i32(inst.args[0].to_integer()) // TODO int -> i32
				}
			}
			.callmethod {
				args_count := inst.args[3].to_integer()

				mut intr_args := []Operand{}
				if args_count > 0 {
					for j in 0..args_count {
						intr_args << e.parse_value(inst.args[4 + j])
					}
				}
				
				e.commands << CallMethod{
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
				
				e.commands << CallStatic{
					object: e.get_string(inst.args[0].to_string_id())
					name: e.get_string(inst.args[1].to_string_id())
					result: e.parse_value(inst.args[2])
					args: intr_args
				}
			}
			.ret {
				e.commands << Return{
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

	//println("[parse fn] e.fn_stack_count: ${e.fn_stack_count}")
	e.register_func(object_name, state_name, &Function {
		name: e.get_string(pex_func.name)
		commands: e.commands
		is_global: pex_func.info.is_global()
		stack_data: e.fn_stack_data.reverse()
		params: fn_params
	})
}

fn (mut ctx ExecutionContext) find_free_reg(value Value) ?Operand {
	if value.typ == .bool {
		if !ctx.used_registers[int(OperandType.regb1)] {
			ctx.used_registers[int(OperandType.regb1)] = true
			return Operand { typ: .regb1 }
		}
		else if !ctx.used_registers[int(OperandType.regb2)] {
			ctx.used_registers[int(OperandType.regb2)] = true
			return Operand { typ: .regb2 }
		}
	}
	else if value.typ == .i32 {
		if !ctx.used_registers[int(OperandType.regi1)] {
			ctx.used_registers[int(OperandType.regi1)] = true
			return Operand { typ: .regi1 }
		}
		else if !ctx.used_registers[int(OperandType.regi2)] {
			ctx.used_registers[int(OperandType.regi2)] = true
			return Operand { typ: .regi2 }
		}
		else if !ctx.used_registers[int(OperandType.regi3)] {
			ctx.used_registers[int(OperandType.regi3)] = true
			return Operand { typ: .regi3 }
		}
	}
	else if value.typ == .f32 {
		if !ctx.used_registers[int(OperandType.regf1)] {
			ctx.used_registers[int(OperandType.regf1)] = true
			return Operand { typ: .regf1 }
		}
		else if !ctx.used_registers[int(OperandType.regf2)] {
			ctx.used_registers[int(OperandType.regf2)] = true
			return Operand { typ: .regf2 }
		}
		else if !ctx.used_registers[int(OperandType.regf3)] {
			ctx.used_registers[int(OperandType.regf3)] = true
			return Operand { typ: .regf3 }
		}
	}
	
	return none
}

@[inline]
fn (mut e ExecutionContext) create_stack_operand(value Value) Operand {
	stack_offset := e.fn_stack_count
	e.fn_stack_data << value
	e.fn_stack_count++
	return Operand {
		typ: .stack
		stack_offset: stack_offset
	}
}

@[inline]
fn (mut e ExecutionContext) create_operand(value Value) Operand {
	if operand := e.find_free_reg(value) {
		return operand
	}
	else {
		return e.create_stack_operand(value)
	}
}

fn (mut e ExecutionContext) parse_value(pex_value pex.VariableValue) Operand {
	match pex_value.typ {
		.null {
			return e.none_operand
		}
		.boolean {
			//println("[parse_value] bool ${pex_value.to_boolean()}")
			return e.create_operand(create_value_data[bool](pex_value.to_boolean() > 0))
		}
		.float {
			//println("[parse_value] float ${pex_value.to_float()} e.fn_stack_count: ${e.fn_stack_count}")
			return e.create_operand(create_value_data[f32](pex_value.to_float()))
		}
		.integer {
			//println("[parse_value] integer ${pex_value.to_integer()} e.fn_stack_count: ${e.fn_stack_count}")
			return e.create_operand(create_value_data[i32](i32(pex_value.to_integer()))) //TODO int -> i32
		}
		.str {
			return e.create_operand(create_value_data[string](pex_value.to_string(e.pex_file)))
		}
		.identifier {
			if pex_value.to_string_id() in e.operand_by_name {
				//println("[parse_value] identifier typ: ${e.local_typ_by_name[pex_value.to_string_id()]} offset: ${e.local_id_by_name[pex_value.to_string_id()]}")
				return e.operand_by_name[pex_value.to_string_id()]
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

@[inline]
fn get_type_from_type_name(name string) ValueType {
	lname := name.to_lower()
	return match lname {
		"string" { .string }
		"int" { .i32 }
		"float" { .f32 }
		"bool" { .bool }
		// TODO object
		// TODO array
		else { .object } 
	}
}