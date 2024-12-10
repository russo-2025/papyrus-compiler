module vm

import pex

struct Loader {
mut:
	//temps
	pex_file				&pex.PexFile = unsafe { voidptr(0) }
	cur_script				&Script = unsafe { voidptr(0) }
	cur_state				&State = unsafe { voidptr(0) }
	commands				[]Command
	fn_stack_count			int
	fn_stack_data			[]Value
	used_registers			[]bool
	operand_by_name			map[pex.StringId]Operand
	operand_type_by_name	map[pex.StringId]ValueType
	state_name_operand		Operand
	self_operand			Operand

	none_operand			Operand
	funcs					map[string]&Function
	scripts					[]Script
}

pub fn (mut loader Loader) load_pex_file(pex_file &pex.PexFile) {
	loader.pex_file = pex_file
	assert loader.pex_file.objects.len == 1

	pex_obj := loader.pex_file.objects[0]

	pex_object_name := loader.get_string(pex_obj.name)
	auto_state_name := loader.get_string(pex_obj.auto_state_name)
	
	loader.cur_script = &Script{
		name: pex_object_name
		parent: none
		variables: []Variable{ cap: pex_obj.variables.len }
		properties: []Property{ cap: pex_obj.properties.len }
		states: []State{ cap: pex_obj.states.len }
	}

	// TODO set loader.cur_script.parent

	for pex_state in pex_obj.states {
		state_name := loader.get_string(pex_state.name)

		loader.cur_state = &State {
			name: state_name
			funcs: []Function{ cap: pex_state.functions.len }
		}

		if state_name == auto_state_name {
			loader.cur_script.auto_state = loader.cur_state
		}
		
		for pex_func in pex_state.functions {
			loader.load_func(pex_object_name, state_name, pex_func)
		}
		
		loader.cur_script.states << loader.cur_state
	}

	loader.scripts << loader.cur_script

	loader.print_loaded_scripts()
}

fn (mut loader Loader) print_loaded_scripts() {
	for script in loader.scripts {
		println("class `${script.name}`, autostate `${script.auto_state.name}`")
		for state in script.states {
			println("\tstate `${state.name}`")
			for method in state.funcs {
				println("\t\tmethod `${method.name}`")
			}
		}
	}
}

fn (mut loader Loader) load_func(object_name string, state_name string, pex_func &pex.Function) {
	loader.commands = []Command{ cap: pex_func.info.instructions.len }
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
			.cmp_ge,
			.strcat {
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
				loader.commands << Jump{
					value: loader.parse_value(inst.args[0])
					offset: i32(inst.args[0].to_integer()) // TODO int -> i32
					with_condition: true
					true_condition: true
				}
			}
			.jmpf {
				loader.commands << Jump{
					value: loader.parse_value(inst.args[0])
					offset: i32(inst.args[0].to_integer()) // TODO int -> i32
					with_condition: true
				}
			}
			.callmethod {
				args_count := inst.args[3].to_integer()

				mut intr_args := []Operand{ cap: args_count }
				if args_count > 0 {
					for j in 0..args_count {
						intr_args << loader.parse_value(inst.args[4 + j])
					}
				}
				
				loader.commands << Call{
					name: loader.get_string(inst.args[0].to_string_id())
					self: loader.parse_value(inst.args[1])
					result: loader.parse_value(inst.args[2])
					args: intr_args
				}
			}
			.callstatic {
				args_count := inst.args[3].to_integer()
				
				mut intr_args := []Operand{ cap: args_count }
				if args_count > 0 {
					for j in 0..args_count {
						intr_args << loader.parse_value(inst.args[4 + j])
					}
				}
				
				loader.commands << Call{
					object: loader.get_string(inst.args[0].to_string_id())
					name: loader.get_string(inst.args[1].to_string_id())
					result: loader.parse_value(inst.args[2])
					args: intr_args
					is_global: true
				}
			}
			.callparent {
				args_count := inst.args[2].to_integer()

				mut intr_args := []Operand{ cap: args_count }
				if args_count > 0 {
					for j in 0..args_count {
						intr_args << loader.parse_value(inst.args[3 + j])
					}
				}
				
				loader.commands << Call{
					name: loader.get_string(inst.args[0].to_string_id())
					result: loader.parse_value(inst.args[1])
					args: intr_args
					is_parent_call: true
				}
			}
			.ret {
				loader.commands << Return{
					value: loader.parse_value(inst.args[0])
				}
			}
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

	func := Function {
		name: loader.get_string(pex_func.name)
		commands: loader.commands
		is_global: pex_func.info.is_global()
		stack_data: loader.fn_stack_data.reverse()
		params: fn_params
	}

	if func.is_global {
		key := object_name.to_lower() + "." + func.name.to_lower()
		loader.cur_state.funcs << func
		loader.funcs[key] = &loader.cur_state.funcs[loader.cur_state.funcs.len - 1]
	}
	else {
		key := object_name.to_lower() + "." + state_name.to_lower() + "." + func.name.to_lower()
		loader.cur_state.funcs << func
		loader.funcs[key] = &loader.cur_state.funcs[loader.cur_state.funcs.len - 1]
	}
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
			return loader.create_stack_operand(create_value_data[bool](pex_value.to_boolean() > 0))
		}
		.float {
			return loader.create_stack_operand(create_value_data[f32](pex_value.to_float()))
		}
		.integer {
			return loader.create_stack_operand(create_value_data[i32](i32(pex_value.to_integer()))) //TODO int -> i32
		}
		.str {
			return loader.create_stack_operand(create_value_data[string](pex_value.to_string(loader.pex_file)))
		}
		.identifier {
			if pex_value.to_string_id() in loader.operand_by_name {
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
fn (mut loader Loader) find_script(object_name string) ?&Script {
	for i in 0..loader.scripts.len {
		if object_name == loader.scripts[i].name {
			return &loader.scripts[i]
		}
	}
	
	return none
}

@[inline]
fn (mut loader Loader) find_global_func(object_name string, func_name string) ?&Function {
	return loader.funcs[object_name.to_lower() + "." + func_name.to_lower()] or { return none }
}

@[inline]
fn (mut loader Loader) find_method(object_name string, state_name string, func_name string) ?&Function {
	return loader.funcs[object_name.to_lower() + "." + state_name.to_lower() + "." + func_name.to_lower()] or { return none }
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