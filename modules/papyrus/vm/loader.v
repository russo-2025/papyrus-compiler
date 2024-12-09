module vm

import pex

struct Loader {
mut:
	none_operand			Operand
	pex_file				&pex.PexFile = unsafe { voidptr(0) }
	funcs					map[string]&Function
	commands				[]Command
	fn_stack_count			int
	fn_stack_data			[]Value
	self_operand			Operand
	state_name_operand		Operand
	used_registers			[]bool
	operand_by_name			map[pex.StringId]Operand
	operand_type_by_name	map[pex.StringId]ValueType
}

pub fn (mut loader Loader) load_pex_file(pex_file &pex.PexFile) {
	loader.pex_file = pex_file
	assert loader.pex_file.objects.len == 1

	obj := loader.pex_file.objects[0]

	object_name := loader.get_string(obj.name)
	//auto_state_name := loader.get_string(obj.auto_state_name)

	for pex_state in obj.states {
		state_name := loader.get_string(pex_state.name)
		
		for pex_func in pex_state.functions {
			loader.load_func(object_name, state_name, pex_func)
		}
	}
}

fn (mut loader Loader) load_func(object_name string, state_name string, pex_func &pex.Function) {
	loader.commands = []Command{ cap: 15 }
	loader.fn_stack_count = 0
	loader.fn_stack_data = []Value{ cap: 5 }
	loader.operand_by_name = map[pex.StringId]Operand

	for i in 0..loader.used_registers.len {
		loader.used_registers[i] = false
	}
	loader.self_operand = Operand { typ: .reg_self }
	loader.state_name_operand = Operand { typ: .reg_state }

	mut fn_params := []Param{ cap: pex_func.info.params.len }

	for i := pex_func.info.params.len - 1; i >= 0; i-- {
		pex_param := pex_func.info.params[i]
		typ1 := get_type_from_type_name(loader.get_string(pex_param.typ))
		
		loader.operand_type_by_name[pex_param.name] = typ1
		loader.operand_by_name[pex_param.name] = Operand {
			typ: .stack
			stack_offset: loader.fn_stack_count
		}
		loader.fn_stack_count++

		fn_params << Param{
			name: loader.get_string(pex_param.name)
			typ: typ1
		}
	}

	for pex_local in pex_func.info.locals {
		typ2 := get_type_from_type_name(loader.get_string(pex_local.typ))
		loader.operand_by_name[pex_local.name] = loader.create_operand(create_value_typ(typ2))
		loader.operand_type_by_name[pex_local.name] = typ2
	}

	for inst in pex_func.info.instructions {
		//println("[parse] ${inst.op} loader.fn_stack_count ${e.fn_stack_count}")
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
				loader.commands << InfixExpr{
					op: inst.op
					result: loader.parse_value(inst.args[0])
					value1: loader.parse_value(inst.args[1])
					value2: loader.parse_value(inst.args[2])
				}
			}
			.not,
			.ineg,
			.fneg {
				loader.commands << PrefixExpr{
					op: inst.op
					result: loader.parse_value(inst.args[0])
					value: loader.parse_value(inst.args[1])
				}
			}
			.assign {
				loader.commands << Assign{
					result: loader.parse_value(inst.args[0])
					value: loader.parse_value(inst.args[1])
				}
			}
			.cast {
				loader.commands << CastExpr{
					result: loader.parse_value(inst.args[0])
					value: loader.parse_value(inst.args[1])
				}
			}
			.jmp {
				loader.commands << Jump{
					offset: i32(inst.args[0].to_integer()) // TODO int -> i32
				}
			}
			.jmpt {
				loader.commands << JumpTrue{
					value: loader.parse_value(inst.args[0])
					offset: i32(inst.args[0].to_integer()) // TODO int -> i32
				}
			}
			.jmpf {
				loader.commands << JumpFalse{
					value: loader.parse_value(inst.args[0])
					offset: i32(inst.args[0].to_integer()) // TODO int -> i32
				}
			}
			.callmethod {
				args_count := inst.args[3].to_integer()

				mut intr_args := []Operand{}
				if args_count > 0 {
					for j in 0..args_count {
						intr_args << loader.parse_value(inst.args[4 + j])
					}
				}
				
				loader.commands << CallMethod{
					name: loader.get_string(inst.args[0].to_string_id())
					self: loader.parse_value(inst.args[1])
					result: loader.parse_value(inst.args[2])
					args: intr_args
				}
			}
			.callparent { panic("TODO ${inst.op}") }
			.callstatic {
				args_count := inst.args[3].to_integer()
				
				mut intr_args := []Operand{}
				if args_count > 0 {
					for j in 0..args_count {
						intr_args << loader.parse_value(inst.args[4 + j])
					}
				}
				
				loader.commands << CallStatic{
					object: loader.get_string(inst.args[0].to_string_id())
					name: loader.get_string(inst.args[1].to_string_id())
					result: loader.parse_value(inst.args[2])
					args: intr_args
				}
			}
			.ret {
				loader.commands << Return{
					value: loader.parse_value(inst.args[0])
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

	//println("[parse fn] loader.fn_stack_count: ${e.fn_stack_count}")
	loader.register_func(object_name, state_name, &Function {
		name: loader.get_string(pex_func.name)
		commands: loader.commands
		is_global: pex_func.info.is_global()
		stack_data: loader.fn_stack_data.reverse()
		params: fn_params
	})
}

fn (mut loader Loader) find_free_reg(value Value) ?Operand {
	if value.typ == .bool {
		if !loader.used_registers[int(OperandType.regb1)] {
			loader.used_registers[int(OperandType.regb1)] = true
			return Operand { typ: .regb1 }
		}
		else if !loader.used_registers[int(OperandType.regb2)] {
			loader.used_registers[int(OperandType.regb2)] = true
			return Operand { typ: .regb2 }
		}
	}
	else if value.typ == .i32 {
		if !loader.used_registers[int(OperandType.regi1)] {
			loader.used_registers[int(OperandType.regi1)] = true
			return Operand { typ: .regi1 }
		}
		else if !loader.used_registers[int(OperandType.regi2)] {
			loader.used_registers[int(OperandType.regi2)] = true
			return Operand { typ: .regi2 }
		}
		else if !loader.used_registers[int(OperandType.regi3)] {
			loader.used_registers[int(OperandType.regi3)] = true
			return Operand { typ: .regi3 }
		}
	}
	else if value.typ == .f32 {
		if !loader.used_registers[int(OperandType.regf1)] {
			loader.used_registers[int(OperandType.regf1)] = true
			return Operand { typ: .regf1 }
		}
		else if !loader.used_registers[int(OperandType.regf2)] {
			loader.used_registers[int(OperandType.regf2)] = true
			return Operand { typ: .regf2 }
		}
		else if !loader.used_registers[int(OperandType.regf3)] {
			loader.used_registers[int(OperandType.regf3)] = true
			return Operand { typ: .regf3 }
		}
	}
	
	return none
}

@[inline]
fn (mut loader Loader) create_stack_operand(value Value) Operand {
	stack_offset := loader.fn_stack_count
	loader.fn_stack_data << value
	loader.fn_stack_count++
	return Operand {
		typ: .stack
		stack_offset: stack_offset
	}
}

@[inline]
fn (mut loader Loader) create_operand(value Value) Operand {
	if operand := loader.find_free_reg(value) {
		return operand
	}
	else {
		return loader.create_stack_operand(value)
	}
}

fn (mut loader Loader) parse_value(pex_value pex.VariableValue) Operand {
	match pex_value.typ {
		.null {
			return loader.none_operand
		}
		.boolean {
			//println("[parse_value] bool ${pex_value.to_boolean()}")
			return loader.create_operand(create_value_data[bool](pex_value.to_boolean() > 0))
		}
		.float {
			//println("[parse_value] float ${pex_value.to_float()} loader.fn_stack_count: ${e.fn_stack_count}")
			return loader.create_operand(create_value_data[f32](pex_value.to_float()))
		}
		.integer {
			//println("[parse_value] integer ${pex_value.to_integer()} loader.fn_stack_count: ${e.fn_stack_count}")
			return loader.create_operand(create_value_data[i32](i32(pex_value.to_integer()))) //TODO int -> i32
		}
		.str {
			return loader.create_operand(create_value_data[string](pex_value.to_string(loader.pex_file)))
		}
		.identifier {
			if pex_value.to_string_id() in loader.operand_by_name {
				//println("[parse_value] identifier typ: ${e.local_typ_by_name[pex_value.to_string_id()]} offset: ${e.local_id_by_name[pex_value.to_string_id()]}")
				return loader.operand_by_name[pex_value.to_string_id()]
			}
			else if loader.get_string(pex_value.to_string_id()).to_lower() == "::state" {
				return loader.state_name_operand
			}
			else if loader.get_string(pex_value.to_string_id()).to_lower() == "self" {
				return loader.self_operand
			}
			else {
				panic("identifier not found ${pex_value.to_string_id()} - `${loader.get_string(pex_value.to_string_id())}`")
			}
		}
	}
}

@[inline]
fn (mut loader Loader) register_func(object_name string, state_name string, func &Function) {
	//print(func)
	key := if func.is_global {
		object_name.to_lower() + "." + func.name.to_lower()
	}
	else {
		object_name.to_lower() + "." + state_name.to_lower() + "." + func.name.to_lower()
	}

	loader.funcs[key] = func
}

@[inline]
fn (mut loader Loader) find_global_func(object_name string, func_name string) ?&Function {
	return loader.funcs[object_name.to_lower() + "." + func_name.to_lower()] or { return none }
}

@[inline]
fn (loader Loader) get_string(id pex.StringId) string {
	return loader.pex_file.get_string(id)
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