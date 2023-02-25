module gen_pex

import papyrus.ast
import pex
import papyrus.token

[inline]
fn (mut g Gen) get_free_temp(typ ast.Type) pex.VariableValue {
	assert typ != 0

	for i := 0; i < g.temp_locals.len; i++ {
		local := g.temp_locals[i]

		if local.free && local.typ == typ {
			g.temp_locals[i].free = false
			return local.value
		}
	}

	local_name := if typ != ast.none_type { "::temp" + g.cur_fn.info.locals.len.str() } else { "::NoneVar" }

	value := pex.value_ident(g.gen_string_ref(local_name))

	g.temp_locals << TempVariable {
		typ: typ
		value: value
		free: false
	}

	g.cur_fn.info.locals << pex.VariableType{
		name: g.gen_string_ref(local_name)
		typ: g.gen_string_ref(g.table.type_to_str(typ))
	}

	return value
}

[inline]
fn (mut g Gen) free_temp(value pex.VariableValue) {
	if value.typ != .identifier {
		return
	}

	for i := 0; i < g.temp_locals.len; i++ {
		if g.temp_locals[i].value.to_string_id() == value.to_string_id() {
			g.temp_locals[i].free = true
		}
	}
}

//v1 what to convert to and where to put the result
//v2 what to convert
[inline]
fn (mut g Gen) gen_cast(v1 pex.VariableValue, v2 pex.VariableValue) {
	g.cur_fn.info.instructions << pex.Instruction{
		op: pex.OpCode.cast
		args: [v1, v2]
	}
}

[inline]
fn (mut g Gen) gen_infix_operator(mut expr &ast.InfixExpr) pex.VariableValue {
	if expr.op == .ne {
		mut e := expr
		e.op = .eq
		result_value := g.gen_infix_operator(mut e)
		
		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.not
			args: [result_value, result_value]
		}

		return result_value
	}
	else if expr.op == .logical_and {
		//opcode: 'assign', args: [ident(a), integer(1)]
		//opcode: 'cmp_gt', args: [ident(::temp0), integer(1), integer(11)]
		//opcode: 'cast', args: [ident(::temp0), ident(::temp0)]
		//opcode: 'jmpf', args: [ident(::temp0), integer(3)]
		//opcode: 'cmp_gt', args: [ident(::temp1), integer(1), integer(12)]
		//opcode: 'cast', args: [ident(::temp0), ident(::temp1)]
		//opcode: 'jmpf', args: [ident(::temp0), integer(3)]
		//opcode: 'assign', args: [ident(a), integer(2)]
		//opcode: 'jmp', args: [integer(1)]
		
		mut result_value := g.get_operand_from_expr(mut &expr.left)
		left_jmp_index := g.cur_fn.info.instructions.len
		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.jmpf
			args: [ result_value ]
		}

		g.free_temp(result_value)
		result_value = g.get_operand_from_expr(mut &expr.right)

		g.cur_fn.info.instructions[left_jmp_index].args << pex.value_integer(g.cur_fn.info.instructions.len - left_jmp_index)
		
		return result_value
	}
	else if expr.op == .logical_or {
		//opcode: 'assign', args: [ident(a), integer(1)]
		//opcode: 'cmp_gt', args: [ident(::temp0), integer(1), integer(11)]
		//opcode: 'cast', args: [ident(::temp0), ident(::temp0)]
		//opcode: 'jmpt', args: [ident(::temp0), integer(3)]
		//opcode: 'cmp_gt', args: [ident(::temp1), integer(1), integer(12)]
		//opcode: 'cast', args: [ident(::temp0), ident(::temp1)]
		//opcode: 'jmpf', args: [ident(::temp0), integer(3)]
		//opcode: 'assign', args: [ident(a), integer(2)]
		//opcode: 'jmp', args: [integer(1)]

		mut result_value := g.get_operand_from_expr(mut &expr.left)
		left_jmp_index := g.cur_fn.info.instructions.len
		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.jmpt
			args: [ result_value ]
		}

		g.free_temp(result_value)
		result_value = g.get_operand_from_expr(mut &expr.right)

		g.cur_fn.info.instructions[left_jmp_index].args << pex.value_integer(g.cur_fn.info.instructions.len - left_jmp_index)
		
		return result_value
	}
	
	mut op := g.get_infix_opcode_operator(expr.left_type, expr.op)

	left_value := g.get_operand_from_expr(mut &expr.left)
	mut right_value := g.get_operand_from_expr(mut &expr.right)

	g.free_temp(left_value)
	g.free_temp(right_value)

	result_value := g.get_free_temp(expr.result_type)

	g.cur_fn.info.instructions << pex.Instruction{
		op: op
		args: [result_value, left_value, right_value]
	}

	return result_value
	
}

[inline]
fn (mut g Gen) gen_prefix_operator(mut expr ast.PrefixExpr) pex.VariableValue {
	mut op := g.get_prefix_opcode_operator(expr.right_type, expr.op)
	right_value := g.get_operand_from_expr(mut &expr.right)

	g.free_temp(right_value)
	
	result_value := g.get_free_temp(expr.right_type)

	g.cur_fn.info.instructions << pex.Instruction{
		op: op
		args: [result_value, right_value]
	}

	return result_value
}

[inline]
fn (mut g Gen) gen_call(calltype pex.OpCode, mut expr &ast.CallExpr) pex.VariableValue {
	result_value := g.get_free_temp(expr.return_type)
	mut args := []pex.VariableValue{}

	if calltype == .callstatic {
		//имя скрипта
		args << pex.value_ident(g.gen_string_ref(expr.obj_name))
	}

	//имя функции
	args << pex.value_ident(g.gen_string_ref(expr.name))

	if calltype == .callmethod {
		//у кого вызывать метод

		left := expr.left

		if left is ast.EmptyExpr {
			args << pex.value_ident(g.gen_string_ref("self"))
		}
		else {
			left_obj := g.get_operand_from_expr(mut &expr.left)
			args << left_obj
			g.free_temp(left_obj)
		}
	}

	//переменная для результата
	args << result_value

	//кол-во дополнительных параметров
	args << pex.value_integer(expr.args.len)

	mut vars := []pex.VariableValue{}

	//аргументы функции
	for mut fn_arg in expr.args {
		args << g.get_operand_from_expr(mut &fn_arg.expr)
		vars << args.last()
	}

	//помечаем переменные как свободные
	for var in vars {
		g.free_temp(var)
	}

	//добавляем инструкцию в функцию
	g.cur_fn.info.instructions << pex.Instruction{
		op: calltype
		args: args
	}

	return result_value
}

[inline]
fn (mut g Gen) gen_call_expr(mut expr &ast.CallExpr) pex.VariableValue {
	//opcode: 'callstatic', args: [ident(m), ident(Log), ident(::NoneVar), string('Hello World')]
	//opcode: 'callmethod', args: [ident(Bar), ident(arg), ident(::NoneVar)]
	//opcode: 'callmethod', args: [ident(Foo), ident(a), ident(::NoneVar), integer(123)]
	//opcode: 'callparent', args: [ident(Foo), ident(::NoneVar), integer(123)]

	lname := expr.name.to_lower()

	if lname == "find" || lname == "rfind"  {
		return g.gen_array_find_element(mut expr)
	}

	if expr.is_global {
		return g.gen_call(.callstatic, mut expr)
	}
	else {
		if mut expr.left is ast.Ident {
			if expr.left.name.to_lower() == "parent" {
				return g.gen_call(.callparent, mut expr)
			}
		}

		return g.gen_call(.callmethod, mut expr)
	}
}

[inline]
fn (mut g Gen) gen_array_init(mut expr &ast.ArrayInit) pex.VariableValue {
		//opcode: 'array_create', args: [ident(::temp0), integer(3)]
		//массив
		len_value := g.get_operand_from_expr(mut &expr.len)
		g.free_temp(len_value)
		//переменная для результата
		result_value := g.get_free_temp(expr.typ)
		//добавляем инструкцию в функцию
		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.array_create
			args: [result_value, len_value]
		}
		return result_value
}

[inline]
fn (mut g Gen) gen_array_find_element(mut expr &ast.CallExpr) pex.VariableValue {
	lname := expr.name.to_lower()
	
	assert lname == "find" || lname == "rfind" 
	assert expr.args.len == 2

	//массив для поиска
	target_value := g.get_operand_from_expr(mut &expr.left)
	g.free_temp(target_value)
	
	//переменная для результата
	result_value := g.get_free_temp(expr.return_type)
	
	//что искать
	value := g.get_operand_from_expr(mut &expr.args[0].expr)

	//индекс с которого начинать
	mut value_start_index := g.get_operand_from_expr(mut &expr.args[1].expr)

	//добавляем инструкцию в функцию
	g.cur_fn.info.instructions << pex.Instruction{
		op: if lname == 'find' { pex.OpCode.array_findelement } else { pex.OpCode.array_rfindelement }
		args: [target_value, result_value, value, value_start_index]
	}
	return result_value
}

[inline]
fn (mut g Gen) gen_array_get_element(mut expr &ast.IndexExpr) pex.VariableValue {
	//opcode: 'array_getelement', args: [ident(::temp1), ident(arr), integer(0)]
	//массив
	left_value := g.get_operand_from_expr(mut &expr.left)
	index_value := g.get_operand_from_expr(mut &expr.index)
	g.free_temp(left_value)
	g.free_temp(index_value)
	//переменная для результата
	result_value := g.get_free_temp(expr.typ)
	//добавляем инструкцию в функцию
	g.cur_fn.info.instructions << pex.Instruction{
		op: pex.OpCode.array_getelement
		args: [result_value, left_value, index_value]
	}
	return result_value
}

[inline]
fn (mut g Gen) gen_selector(mut expr &ast.SelectorExpr) pex.VariableValue {

	if expr.field_name.to_lower() == "length" {
		//opcode: 'array_length', args: [ident(::temp1), ident(myArray)]

		expr_value := g.get_operand_from_expr(mut &expr.expr)
		g.free_temp(expr_value)

		//переменная для результата
		result_value := g.get_free_temp(expr.typ)

		//добавляем инструкцию в функцию
		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.array_length
			args: [result_value, expr_value]
		}

		return result_value
	}
	
	//opcode: 'propget', args: [ident(myProperty), ident(arg), ident(::temp0)]

	expr_value := g.get_operand_from_expr(mut &expr.expr)
	g.free_temp(expr_value)

	//переменная для результата
	result_value := g.get_free_temp(expr.typ)

	//добавляем инструкцию в функцию
	g.cur_fn.info.instructions << pex.Instruction{
		op: pex.OpCode.propget
		args: [
			pex.value_ident(g.gen_string_ref(expr.field_name)),
			expr_value,
			result_value
		]
	}

	return result_value
}

fn (mut g Gen) get_operand_from_expr(mut expr &ast.Expr) pex.VariableValue {
	mut result_value := pex.value_none()

	match mut expr {
		ast.InfixExpr {
			result_value = g.gen_infix_operator(mut &expr)
		}
		ast.ParExpr {
			result_value = g.get_operand_from_expr(mut &expr.expr)
		}
		ast.CallExpr {
			result_value = g.gen_call_expr(mut &expr)
		}
		ast.PrefixExpr {
			result_value = g.gen_prefix_operator(mut &expr)
		}
		ast.Ident {
			if expr.is_object_var_or_prpperty {
				sym := g.table.get_type_symbol(g.cur_obj_type)
				if prop := sym.find_property(expr.name) {
					
					if prop.is_auto {
						return pex.value_ident(g.gen_string_ref(prop.auto_var_name))
					}

					return g.gen_selector(mut &ast.SelectorExpr{
						expr: ast.Ident {
							name: 'self'
							typ: ast.Type(g.table.find_type_idx(g.cur_obj_name))
						}
						field_name: expr.name
						typ: prop.typ
					})
				}

			}

			return pex.value_ident(g.gen_string_ref(expr.name))
		}
		ast.NoneLiteral {
			return pex.value_none()
		}
		ast.IntegerLiteral {
			if g.pref.crutches_enabled && expr.val.starts_with("0x") {
				result_value = g.get_free_temp(ast.int_type)

				g.cur_fn.info.instructions << pex.Instruction{
					op: pex.OpCode.callstatic
					args: [
						pex.value_ident(g.gen_string_ref("m")),
						pex.value_ident(g.gen_string_ref("StringToInt"))
						result_value,
						pex.value_integer(1),
						pex.value_string(g.gen_string_ref(expr.val))
					]
				}
			}
			else {
				return pex.value_integer(expr.val.int())
			}
			
		}
		ast.FloatLiteral {
			return pex.value_float(expr.val.f32())
		}
		ast.BoolLiteral {
			return pex.value_bool(if expr.val.to_lower().bool() { byte(1) } else { byte(0) })
		}
		ast.StringLiteral {
			return pex.value_string(g.gen_string_ref(expr.val))
		}
		ast.ArrayInit {
			result_value = g.gen_array_init(mut &expr)
		}
		ast.SelectorExpr {
			result_value = g.gen_selector(mut &expr)
		}
		ast.IndexExpr {
			result_value = g.gen_array_get_element(mut &expr)
		}
		ast.CastExpr {
			expr_value := g.get_operand_from_expr(mut &expr.expr)
			g.free_temp(expr_value)
			result_value = g.get_free_temp(&expr.typ)
			g.gen_cast(result_value, expr_value)
		}
		ast.EmptyExpr {
			panic("wtf")
		}
	}

	return result_value
}


[inline]
fn (mut g Gen) get_prefix_opcode_operator(typ ast.Type, kind token.Kind) pex.OpCode {
	match kind {
		.minus {
			if typ == ast.int_type {
				return .ineg
			}
			else if typ == ast.float_type {
				return .fneg
			}
			else {
				panic("Gen error: operator: `$kind` not supported type: ${g.table.type_to_str(typ)}")
			}
		}
		.not {
			return .not
		}
		else {
			panic("Gen error: invalid infix operator: `$kind`")
		}
	}
}

[inline]
fn (mut g Gen) get_infix_opcode_operator(typ ast.Type, kind token.Kind) pex.OpCode {
	match kind {
		.plus {
			if typ == ast.string_type {
				return .strcat
			}
			else if typ == ast.int_type {
				return .iadd
			}
			else if typ == ast.float_type {
				return .fadd
			}
			else {
				panic("Gen error: operator: `$kind` not supported type: ${g.table.type_to_str(typ)}")
			}
		}
		.minus {
			if typ == ast.int_type {
				return .isub
			}
			else if typ == ast.float_type {
				return .fsub
			}
			else {
				panic("Gen error: operator: `$kind` not supported type: ${g.table.type_to_str(typ)}")
			}
		}
		.mul {
			if typ == ast.int_type {
				return .imul
			}
			else if typ == ast.float_type {
				return .fmul
			}
			else {
				panic("Gen error: operator: `$kind` not supported type: ${g.table.type_to_str(typ)}")
			}
		}
		.div {
			if typ == ast.int_type {
				return .idiv
			}
			else if typ == ast.float_type {
				return .fdiv
			}
			else {
				panic("Gen error: operator: `$kind` not supported type: ${g.table.type_to_str(typ)}")
			}
		}
		.mod {
			if typ == ast.int_type {
				return .imod
			}
			else {
				panic("Gen error: operator: `$kind` not supported type: ${g.table.type_to_str(typ)}")
			}
		}

		.logical_and {
			panic("Gen error: infix operator: `and`")
		}
		.logical_or {
			panic("Gen error: infix operator: `or`")
		}

		.eq {
			return .cmp_eq
		}
		.ne {
			panic("Gen error: infix operator: `not equal`")
		}
		.gt {
			return .cmp_gt
		}
		.lt {
			return .cmp_lt
		}
		.ge {
			return .cmp_ge
		}
		.le {
			return .cmp_le
		}

		else {
			panic("Gen error: invalid infix operator: `$kind`")
		}
	}
}