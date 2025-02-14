module vm

import pex

struct Loader {
mut:
	ctx						&ExecutionContext = unsafe { voidptr(0) }
	funcs					map[string]&Function
	scripts					[]Script

	//temps
	pex_file				&pex.PexFile = unsafe { voidptr(0) }
	cur_script				&Script = unsafe { voidptr(0) }
	cur_state				&State = unsafe { voidptr(0) }
	commands				[]Command
	fn_stack_count			int
	fn_stack_data			[]Value
	used_registers			[]bool
	operand_by_name			map[string]Operand
	operand_type_by_name	map[string]ValueType
	state_name_operand		Operand
	self_operand			Operand
	none_operand			Operand
}

fn (mut loader Loader) set_context(mut ctx ExecutionContext) {
	loader.ctx = ctx
}

pub fn (mut loader Loader) load_pex_file(pex_file &pex.PexFile) {
	loader.pex_file = pex_file
	assert loader.pex_file.objects.len == 1

	pex_obj := loader.pex_file.objects[0]

	pex_object_name := loader.get_string(pex_obj.name).to_lower()
	auto_state_name := loader.get_string(pex_obj.auto_state_name).to_lower()
	
	loader.cur_script = &Script{
		name: pex_object_name
		parent: none
		variables: []Variable{ cap: pex_obj.variables.len }
		properties: []Property{ cap: pex_obj.properties.len }
		states: []State{ cap: pex_obj.states.len }
	}

	loader.scripts << loader.cur_script
	loader.cur_script = &loader.scripts[loader.scripts.len - 1]

	// TODO set loader.cur_script.parent

	for pex_state in pex_obj.states {
		state_name := loader.get_string(pex_state.name).to_lower()

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

	//loader.scripts << loader.cur_script

	//loader.print_loaded_scripts()
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
	loader.operand_by_name = map[string]Operand

	for i in 0..loader.used_registers.len {
		loader.used_registers[i] = false
	}
	loader.self_operand = Operand { typ: .reg_self }
	loader.state_name_operand = Operand { typ: .reg_state }

	mut fn_params := []Param{ cap: pex_func.info.params.len }

	for i := pex_func.info.params.len - 1; i >= 0; i-- {
		pex_param := pex_func.info.params[i]
		typ1 := get_type_from_type_name(loader.get_string(pex_param.typ))
		
		name := loader.get_string(pex_param.name).to_lower()
		loader.operand_type_by_name[name] = typ1
		loader.operand_by_name[name] = Operand {
			typ: .stack
			stack_offset: loader.fn_stack_count
		}
		loader.fn_stack_count++

		fn_params << Param{
			name: loader.get_string(pex_param.name).to_lower()
			typ: typ1
		}
	}

	for pex_local in pex_func.info.locals {
		typ2 := get_type_from_type_name(loader.get_string(pex_local.typ))
		name := loader.get_string(pex_local.name).to_lower()
		loader.operand_by_name[name] = loader.create_operand(typ2)
		loader.operand_type_by_name[name] = typ2
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
					offset: i32(inst.args[1].to_integer()) // TODO int -> i32
					with_condition: true
					true_condition: true
				}
			}
			.jmpf {
				loader.commands << Jump{
					value: loader.parse_value(inst.args[0])
					offset: i32(inst.args[1].to_integer()) // TODO int -> i32
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
			.array_create {
				loader.commands << ArrayCreate{
					result: loader.parse_value(inst.args[0])
					size: loader.parse_value(inst.args[1])
				}
			}
			.array_length {
				loader.commands << GetArrayLength{
					result: loader.parse_value(inst.args[0])
					array: loader.parse_value(inst.args[1])
				}
			}
			.array_getelement {
				loader.commands << GetArrayElement{
					result: loader.parse_value(inst.args[0])
					array: loader.parse_value(inst.args[1])
					index: loader.parse_value(inst.args[2])
				}
			}
			.array_setelement {
				loader.commands << SetArrayElement{
					array: loader.parse_value(inst.args[0])
					index: loader.parse_value(inst.args[1])
					value: loader.parse_value(inst.args[2])
				}
			}
			.array_findelement,
			.array_rfindelement {
				loader.commands << FindArrayElement{
					array: loader.parse_value(inst.args[0])
					result: loader.parse_value(inst.args[1])
					value: loader.parse_value(inst.args[2])
					start_index: loader.parse_value(inst.args[3])
					is_reverse: if inst.op == .array_findelement { false } else { true }
				}
			}
			.propget { panic("TODO ${inst.op}") }
			.propset { panic("TODO ${inst.op}") }
			._opcode_end { panic("wtf") }
		}
	}

	func := Function {
		name: loader.get_string(pex_func.name)
		commands: loader.commands
		is_global: pex_func.info.is_global()
		is_native: pex_func.info.is_native()
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

fn (mut loader Loader) find_free_reg(typ ValueType) ?Operand {
	if typ.typ == .bool {
		if !loader.used_registers[int(OperandType.regb1)] {
			loader.used_registers[int(OperandType.regb1)] = true
			return Operand { typ: .regb1 }
		}
		else if !loader.used_registers[int(OperandType.regb2)] {
			loader.used_registers[int(OperandType.regb2)] = true
			return Operand { typ: .regb2 }
		}
	}
	else if typ.typ == .i32 {
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
	else if typ.typ == .f32 {
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
fn (mut loader Loader) create_operand(typ ValueType) Operand {
	if operand := loader.find_free_reg(typ) {
		return operand
	}
	else if typ.typ == .none {
		return loader.none_operand
	}
	else {
		value := match typ.typ {
			.none {
				panic("WTF") // TODO bug issue
				loader.ctx.none_value
			}
			.bool {
				loader.ctx.create_bool(false)
			}
			.i32 {
				loader.ctx.create_int(0)
			}
			.f32 {
				loader.ctx.create_float(0.0)
			}
			.string {
				loader.ctx.create_string("")
			}
			.object {
				loader.ctx.create_value_none_object_from_script_name(typ.raw)
			}
			.array {
				loader.ctx.create_array(typ)
			}
		}
		return loader.create_stack_operand(value)
	}
}

// TODO rename
fn (mut loader Loader) parse_value(pex_value pex.VariableValue) Operand {
	match pex_value.typ {
		.null {
			return loader.none_operand
		}
		.boolean {
			return loader.create_stack_operand(loader.ctx.create_bool(pex_value.to_boolean() > 0))
		}
		.float {
			return loader.create_stack_operand(loader.ctx.create_float(pex_value.to_float()))
		}
		.integer {
			return loader.create_stack_operand(loader.ctx.create_int(i32(pex_value.to_integer()))) //TODO int -> i32
		}
		.str {
			return loader.create_stack_operand(loader.ctx.create_string(pex_value.to_string(loader.pex_file)))
		}
		.identifier {
			name :=  loader.get_string(pex_value.to_string_id()).to_lower()
			if name in loader.operand_by_name {
				return loader.operand_by_name[name]
			}
			else if name == "::state" {
				return loader.state_name_operand
			}
			else if name == "self" {
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
		if object_name.to_lower() == loader.scripts[i].name {
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

	match lname {
		"none" { return ValueType{ raw: lname, typ: .none } }
		"string" { return ValueType{ raw: lname, typ: .string } }
		"int" { return ValueType{ raw: lname, typ: .i32 } }
		"float" { return ValueType{ raw: lname, typ: .f32 } }
		"bool" { return ValueType{ raw: lname, typ: .bool } }
		else {
			if lname.ends_with("[]") {
				return ValueType{
					raw: lname,
					typ: .array,
					elem_typ: get_type_from_type_name(lname.all_before("[]")).typ
				}
			}

			return ValueType{ raw: lname, typ: .object }
		} 
	}
}