module gen

import papyrus.ast
import pex
import papyrus.table
import papyrus.token

[inline]
fn (mut g Gen) get_free_temp(typ table.Type) pex.VariableData {
	assert typ != 0

	mut i := 0
	for i < g.temp_locals.len {
		local := g.temp_locals[i]

		if local.free && local.typ == typ {
			g.temp_locals[i].free = false
			return local.data
		}

		i++
	}

	local_name := if typ != table.none_type { "::temp" + g.cur_fn.info.locals.len.str() } else { "::NoneVar" }

	data := pex.VariableData{
		typ: 1
		string_id: g.gen_string_ref(local_name)
	}

	g.temp_locals << TempVariable {
		typ: typ
		data: data
		free: false
	}

	g.cur_fn.info.locals << pex.VariableType{
		name: g.gen_string_ref(local_name)
		typ: g.gen_string_ref(g.table.type_to_str(typ))
	}
	g.cur_fn.info.num_locals++

	return data
}

[inline]
fn (mut g Gen) free_temp(v pex.VariableData) {
	if v.typ != 1 {
		return
	}

	mut i := 0
	for i < g.temp_locals.len {

		if g.temp_locals[i].data.string_id == v.string_id {
			g.temp_locals[i].free = true
		}

		i++
	}
}

//v1 то к чему преобразовать и куда положить результат
//v2 что преобразовать
[inline]
fn (mut g Gen) gen_cast(v1 pex.VariableData, v2 pex.VariableData) {
	g.cur_fn.info.instructions << pex.Instruction{
		op: byte(pex.OpCode.cast)
		args: [v1, v2]
	}
}

[inline]
fn (mut g Gen) gen_infix_operator(expr &ast.InfixExpr) pex.VariableData {
	if expr.op == .ne {
		mut e := expr
		e.op = .eq
		var_data := g.gen_infix_operator(e)
		
		g.cur_fn.info.instructions << pex.Instruction{
			op: byte(pex.OpCode.not)
			args: [var_data, var_data]
		}

		return var_data
	}
	else if expr.op == .and {
		//opcode: 'assign', args: [ident(a), integer(1)]
		//opcode: 'cmp_gt', args: [ident(::temp0), integer(1), integer(11)]
		//opcode: 'cast', args: [ident(::temp0), ident(::temp0)]
		//opcode: 'jmpf', args: [ident(::temp0), integer(3)]
		//opcode: 'cmp_gt', args: [ident(::temp1), integer(1), integer(12)]
		//opcode: 'cast', args: [ident(::temp0), ident(::temp1)]
		//opcode: 'jmpf', args: [ident(::temp0), integer(3)]
		//opcode: 'assign', args: [ident(a), integer(2)]
		//opcode: 'jmp', args: [integer(1)]
		
		mut var_data := g.get_operand_from_expr(&expr.left)
		left_jmp_index := g.cur_fn.info.instructions.len
		g.cur_fn.info.instructions << pex.Instruction{
			op: byte(pex.OpCode.jmpf)
			args: [ var_data ]
		}

		g.free_temp(var_data)
		var_data = g.get_operand_from_expr(&expr.right)

		g.cur_fn.info.instructions[left_jmp_index].args << { typ: 3, integer: g.cur_fn.info.instructions.len - left_jmp_index }
		
		return var_data
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

		mut var_data := g.get_operand_from_expr(&expr.left)
		left_jmp_index := g.cur_fn.info.instructions.len
		g.cur_fn.info.instructions << pex.Instruction{
			op: byte(pex.OpCode.jmpt)
			args: [ var_data ]
		}

		g.free_temp(var_data)
		var_data = g.get_operand_from_expr(&expr.right)

		g.cur_fn.info.instructions[left_jmp_index].args << { typ: 3, integer: g.cur_fn.info.instructions.len - left_jmp_index }
		
		return var_data
	}

	/*if expr.left_type == 0 {
		println(expr)
	}*/
	mut op := g.get_infix_opcode_operator(expr.left_type, expr.op)

	left_data := g.get_operand_from_expr(&expr.left)
	mut right_data := g.get_operand_from_expr(&expr.right)

	g.free_temp(left_data)
	g.free_temp(right_data)

	var_data := g.get_free_temp(expr.result_type)

	g.cur_fn.info.instructions << pex.Instruction{
		op: byte(op)
		args: [var_data, left_data, right_data]
	}

	return var_data
	
}

[inline]
fn (mut g Gen) gen_prefix_operator(expr ast.PrefixExpr) pex.VariableData {
	mut op := g.get_prefix_opcode_operator(expr.right_type, expr.op)
	right_data := g.get_operand_from_expr(&expr.right)

	g.free_temp(right_data)
	
	var_data := g.get_free_temp(expr.right_type)

	g.cur_fn.info.instructions << pex.Instruction{
		op: byte(op)
		args: [var_data, right_data]
	}

	return var_data
}

[inline]
fn (mut g Gen) gen_call_expr(expr &ast.CallExpr) pex.VariableData {
	//opcode: 'callmethod', args: [ident(Bar), ident(arg), ident(::NoneVar)]
	//opcode: 'callstatic', args: [ident(m), ident(Log), ident(::NoneVar), string('Hello World')]

	if expr.name.to_lower() == "find" {
		return g.gen_array_find_element(expr)
	}

	if expr.is_static {
		/*if expr.return_type == 0 {
			println(expr)
		}*/

		var_data := g.get_free_temp(expr.return_type)

		mut args := []pex.VariableData{}

		//имя скрипта
		args << pex.VariableData{
			typ: 1
			string_id: g.gen_string_ref(expr.mod.to_lower())
		}
		//имя функции
		args << pex.VariableData{
			typ: 1
			string_id: g.gen_string_ref(expr.name)
		}
		//переменная для результата
		args << var_data

		//кол-во дополнительных параметров
		args << pex.VariableData{ typ:3, integer: expr.args.len}

		//аргументы функции
		for fn_arg in expr.args {
			args << g.get_operand_from_expr(&fn_arg.expr)
		}
		//добавляем инструкцию в функцию
		g.cur_fn.info.instructions << pex.Instruction{
			op: byte(pex.OpCode.callstatic)
			args: args
		}

		mut i := 3
		for i < args.len {
			g.free_temp(args[i])
			i++
		}
		/*
		//костыль который не помог(так было в оригинале) =(
		if expr.name.to_lower().starts_with("getstoragevalue") {

			tmp_data := g.get_free_temp(expr.return_type)
			g.free_temp(var_data)
			
			g.cur_fn.info.instructions << pex.Instruction{
				op: byte(pex.OpCode.assign)
				args: [tmp_data, var_data]
			}
			
			return tmp_data
		}*/

		return var_data
	}
	else {
		/*if expr.return_type == 0 {
			println(expr)
		}*/
		var_data := g.get_free_temp(expr.return_type)
		mut args := []pex.VariableData{}
		
		//имя функции
		args << pex.VariableData{
			typ: 1
			string_id: g.gen_string_ref(expr.name)
		}
		//у кого вызывать метод
		left := g.get_operand_from_expr(&expr.left)
		args << left
		g.free_temp(left)
		//переменная для результата
		args << var_data
		
		//кол-во дополнительных параметров
		args << pex.VariableData{ typ:3, integer: expr.args.len}

		//аргументы функции
		for fn_arg in expr.args {
			args << g.get_operand_from_expr(&fn_arg.expr)
		}
		//добавляем инструкцию в функцию
		g.cur_fn.info.instructions << pex.Instruction{
			op: byte(pex.OpCode.callmethod)
			args: args
		}

		mut i := 3
		for i < args.len {
			g.free_temp(args[i])
			i++
		}

		return var_data
	}
}

[inline]
fn (mut g Gen) gen_array_init(expr &ast.ArrayInit) pex.VariableData {
		//opcode: 'array_create', args: [ident(::temp0), integer(3)]
		//массив
		len_data := g.get_operand_from_expr(&expr.len)
		g.free_temp(len_data)
		//переменная для результата
		var_data := g.get_free_temp(expr.typ)
		//добавляем инструкцию в функцию
		g.cur_fn.info.instructions << pex.Instruction{
			op: byte(pex.OpCode.array_create)
			args: [var_data, len_data]
		}
		return var_data
}

[inline]
fn (mut g Gen) gen_array_find_element(expr &ast.CallExpr) pex.VariableData {
	assert expr.name.to_lower() == "find"
	assert expr.args.len == 2

	//массив для поиска
	left := g.get_operand_from_expr(&expr.left)
	g.free_temp(left)
	
	//переменная для результата
	var_data := g.get_free_temp(expr.return_type)
	
	//что искать
	value_data := g.get_operand_from_expr(&expr.args[0].expr)

	//индекс с которого начинать
	mut start_index_data := g.get_operand_from_expr(&expr.args[1].expr)

	//добавляем инструкцию в функцию
	g.cur_fn.info.instructions << pex.Instruction{
		op: byte(pex.OpCode.array_findelement)
		args: [left, var_data, value_data, start_index_data]
	}
	return var_data
}

[inline]
fn (mut g Gen) gen_array_get_element(expr &ast.IndexExpr) pex.VariableData {
	//opcode: 'array_getelement', args: [ident(::temp1), ident(arr), integer(0)]
	//массив
	left_data := g.get_operand_from_expr(&expr.left)
	index_data := g.get_operand_from_expr(&expr.index)
	g.free_temp(left_data)
	g.free_temp(index_data)
	//переменная для результата
	var_data := g.get_free_temp(expr.typ)
	//добавляем инструкцию в функцию
	g.cur_fn.info.instructions << pex.Instruction{
		op: byte(pex.OpCode.array_getelement)
		args: [var_data, left_data, index_data]
	}
	return var_data
}

[inline]
fn (mut g Gen) gen_selector(expr &ast.SelectorExpr) pex.VariableData {

	if expr.field_name.to_lower() == "length" {
		//opcode: 'array_length', args: [ident(::temp1), ident(myArray)]

		expr_data := g.get_operand_from_expr(&expr.expr)
		g.free_temp(expr_data)

		//переменная для результата
		var_data := g.get_free_temp(expr.typ)

		//добавляем инструкцию в функцию
		g.cur_fn.info.instructions << pex.Instruction{
			op: byte(pex.OpCode.array_length)
			args: [var_data, expr_data]
		}

		return var_data
	}
	else {
		//opcode: 'propget', args: [ident(myProperty), ident(arg), ident(::temp0)]

		expr_data := g.get_operand_from_expr(&expr.expr)
		g.free_temp(expr_data)

		//переменная для результата
		var_data := g.get_free_temp(expr.typ)

		//добавляем инструкцию в функцию
		g.cur_fn.info.instructions << pex.Instruction{
			op: byte(pex.OpCode.propget)
			args: [
				pex.VariableData{ typ: 1, string_id: g.gen_string_ref(expr.field_name) },
				expr_data,
				var_data
			]
		}

		return var_data
	}

	panic("wtf")
}

fn (mut g Gen) get_operand_from_expr(expr &ast.Expr) pex.VariableData {
	mut var_data := pex.VariableData{ typ: 0 }

	match expr {
		ast.InfixExpr {
			var_data = g.gen_infix_operator(&expr)
		}
		ast.ParExpr {
			var_data = g.get_operand_from_expr(&expr.expr)
		}
		ast.CallExpr {
			var_data = g.gen_call_expr(&expr)
		}
		ast.PrefixExpr {
			var_data = g.gen_prefix_operator(&expr)
		}
		ast.Ident {
			return pex.VariableData{ typ: 1, string_id: g.gen_string_ref(expr.name) }
		}
		ast.NoneLiteral {
			return pex.VariableData{ typ: 0 }
		}
		ast.IntegerLiteral {
			if expr.val.starts_with("0x") {
				var_data = g.get_free_temp(table.int_type)

				g.cur_fn.info.instructions << pex.Instruction{
					op: byte(pex.OpCode.callstatic)
					args: [
						pex.VariableData{
							typ: 1
							string_id: g.gen_string_ref("m")
						},
						pex.VariableData{
							typ: 1
							string_id: g.gen_string_ref("StringToInt")
						}
						var_data,
						pex.VariableData{ typ:3, integer: 1},
						pex.VariableData{
							typ: 2
							string_id: g.gen_string_ref(expr.val)
						}
					]
				}
			}
			else {
				return pex.VariableData{ typ: 3, integer: expr.val.int() }
			}
		}
		ast.FloatLiteral {
			return pex.VariableData{ typ: 4, float: expr.val.f32() }
		}
		ast.BoolLiteral {
			return pex.VariableData{ typ: 5, boolean: if expr.val.to_lower().bool() { byte(1) } else { byte(0) }}
		}
		ast.StringLiteral {
			return pex.VariableData{ typ: 2, string_id: g.gen_string_ref(expr.val) }
		}
		ast.ArrayInit {
			var_data = g.gen_array_init(&expr)
		}
		ast.SelectorExpr {
			var_data = g.gen_selector(&expr)
		}
		ast.IndexExpr {
			var_data = g.gen_array_get_element(&expr)
		}
		ast.CastExpr {
			expr_data := g.get_operand_from_expr(&expr.expr)
			g.free_temp(expr_data)
			var_data = g.get_free_temp(&expr.typ)
			g.gen_cast(var_data, expr_data)
		}
		ast.EmptyExpr {
			var_data = pex.VariableData{ typ: 0 }
		}
		ast.DefaultValue{
			panic("WTF")
		}
	}

	return var_data
}


[inline]
fn (mut g Gen) get_prefix_opcode_operator(typ table.Type, kind token.Kind) pex.OpCode {
	match kind {
		.minus {
			if typ == table.int_type {
				return .ineg
			}
			else if typ == table.float_type {
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
fn (mut g Gen) get_infix_opcode_operator(typ table.Type, kind token.Kind) pex.OpCode {
	match kind {
		.plus {
			if typ == table.string_type {
				return .strcat
			}
			else if typ == table.int_type {
				return .iadd
			}
			else if typ == table.float_type {
				return .fadd
			}
			else {
				panic("Gen error: operator: `$kind` not supported type: ${g.table.type_to_str(typ)}")
			}
		}
		.minus {
			if typ == table.int_type {
				return .isub
			}
			else if typ == table.float_type {
				return .fsub
			}
			else {
				panic("Gen error: operator: `$kind` not supported type: ${g.table.type_to_str(typ)}")
			}
		}
		.mul {
			if typ == table.int_type {
				return .imul
			}
			else if typ == table.float_type {
				return .fmul
			}
			else {
				panic("Gen error: operator: `$kind` not supported type: ${g.table.type_to_str(typ)}")
			}
		}
		.div {
			if typ == table.int_type {
				return .idiv
			}
			else if typ == table.float_type {
				return .fdiv
			}
			else {
				panic("Gen error: operator: `$kind` not supported type: ${g.table.type_to_str(typ)}")
			}
		}
		.mod {
			if typ == table.int_type {
				return .imod
			}
			else {
				panic("Gen error: operator: `$kind` not supported type: ${g.table.type_to_str(typ)}")
			}
		}

		.and {
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