module gen_pex

import papyrus.ast
import pex
import papyrus.token

[inline]
fn (mut g Gen) get_free_temp(typ ast.Type) pex.VariableData {
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

	local_name := if typ != ast.none_type { "::temp" + g.cur_fn.info.locals.len.str() } else { "::NoneVar" }

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

//v1 what to convert to and where to put the result
//v2 what to convert
[inline]
fn (mut g Gen) gen_cast(v1 pex.VariableData, v2 pex.VariableData) {
	g.cur_fn.info.instructions << pex.Instruction{
		op: pex.OpCode.cast
		args: [v1, v2]
	}
}

[inline]
fn (mut g Gen) gen_infix_operator(mut expr &ast.InfixExpr) pex.VariableData {
	if expr.op == .ne {
		mut e := expr
		e.op = .eq
		var_data := g.gen_infix_operator(mut e)
		
		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.not
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
		
		mut var_data := g.get_operand_from_expr(mut &expr.left)
		left_jmp_index := g.cur_fn.info.instructions.len
		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.jmpf
			args: [ var_data ]
		}

		g.free_temp(var_data)
		var_data = g.get_operand_from_expr(mut &expr.right)

		g.cur_fn.info.instructions[left_jmp_index].args << pex.VariableData{ typ: 3, integer: g.cur_fn.info.instructions.len - left_jmp_index }
		
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

		mut var_data := g.get_operand_from_expr(mut &expr.left)
		left_jmp_index := g.cur_fn.info.instructions.len
		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.jmpt
			args: [ var_data ]
		}

		g.free_temp(var_data)
		var_data = g.get_operand_from_expr(mut &expr.right)

		g.cur_fn.info.instructions[left_jmp_index].args << pex.VariableData{ typ: 3, integer: g.cur_fn.info.instructions.len - left_jmp_index }
		
		return var_data
	}
	
	mut op := g.get_infix_opcode_operator(expr.left_type, expr.op)

	left_data := g.get_operand_from_expr(mut &expr.left)
	mut right_data := g.get_operand_from_expr(mut &expr.right)

	g.free_temp(left_data)
	g.free_temp(right_data)

	var_data := g.get_free_temp(expr.result_type)

	g.cur_fn.info.instructions << pex.Instruction{
		op: op
		args: [var_data, left_data, right_data]
	}

	return var_data
	
}

[inline]
fn (mut g Gen) gen_prefix_operator(mut expr ast.PrefixExpr) pex.VariableData {
	mut op := g.get_prefix_opcode_operator(expr.right_type, expr.op)
	right_data := g.get_operand_from_expr(mut &expr.right)

	g.free_temp(right_data)
	
	var_data := g.get_free_temp(expr.right_type)

	g.cur_fn.info.instructions << pex.Instruction{
		op: op
		args: [var_data, right_data]
	}

	return var_data
}

[inline]
fn (mut g Gen) gen_call(calltype pex.OpCode, mut expr &ast.CallExpr) pex.VariableData {
	var_data := g.get_free_temp(expr.return_type)
	mut args := []pex.VariableData{}

	if calltype == .callstatic {
		//имя скрипта
		args << pex.VariableData{
			typ: 1
			string_id: g.gen_string_ref(expr.obj_name)
		}
	}

	//имя функции
	args << pex.VariableData{
		typ: 1
		string_id: g.gen_string_ref(expr.name)
	}

	if calltype == .callmethod {
		//у кого вызывать метод

		left := expr.left

		if left is ast.EmptyExpr {
			args << pex.VariableData{
				typ: 1
				string_id:  g.gen_string_ref("self")
			}
		}
		else {
			left_obj := g.get_operand_from_expr(mut &expr.left)
			args << left_obj
			g.free_temp(left_obj)
		}
	}

	//переменная для результата
	args << var_data

	//кол-во дополнительных параметров
	args << pex.VariableData{ typ:3, integer: expr.args.len }

	mut vars := []pex.VariableData{}

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

	return var_data
}

[inline]
fn (mut g Gen) gen_call_expr(mut expr &ast.CallExpr) pex.VariableData {
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
fn (mut g Gen) gen_array_init(mut expr &ast.ArrayInit) pex.VariableData {
		//opcode: 'array_create', args: [ident(::temp0), integer(3)]
		//массив
		len_data := g.get_operand_from_expr(mut &expr.len)
		g.free_temp(len_data)
		//переменная для результата
		var_data := g.get_free_temp(expr.typ)
		//добавляем инструкцию в функцию
		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.array_create
			args: [var_data, len_data]
		}
		return var_data
}

[inline]
fn (mut g Gen) gen_array_find_element(mut expr &ast.CallExpr) pex.VariableData {
	lname := expr.name.to_lower()
	
	assert lname == "find" || lname == "rfind" 
	assert expr.args.len == 2

	//массив для поиска
	left := g.get_operand_from_expr(mut &expr.left)
	g.free_temp(left)
	
	//переменная для результата
	var_data := g.get_free_temp(expr.return_type)
	
	//что искать
	value_data := g.get_operand_from_expr(mut &expr.args[0].expr)

	//индекс с которого начинать
	mut start_index_data := g.get_operand_from_expr(mut &expr.args[1].expr)

	//добавляем инструкцию в функцию
	g.cur_fn.info.instructions << pex.Instruction{
		op: if lname == 'find' { pex.OpCode.array_findelement } else { pex.OpCode.array_rfindelement }
		args: [left, var_data, value_data, start_index_data]
	}
	return var_data
}

[inline]
fn (mut g Gen) gen_array_get_element(mut expr &ast.IndexExpr) pex.VariableData {
	//opcode: 'array_getelement', args: [ident(::temp1), ident(arr), integer(0)]
	//массив
	left_data := g.get_operand_from_expr(mut &expr.left)
	index_data := g.get_operand_from_expr(mut &expr.index)
	g.free_temp(left_data)
	g.free_temp(index_data)
	//переменная для результата
	var_data := g.get_free_temp(expr.typ)
	//добавляем инструкцию в функцию
	g.cur_fn.info.instructions << pex.Instruction{
		op: pex.OpCode.array_getelement
		args: [var_data, left_data, index_data]
	}
	return var_data
}

[inline]
fn (mut g Gen) gen_selector(mut expr &ast.SelectorExpr) pex.VariableData {

	if expr.field_name.to_lower() == "length" {
		//opcode: 'array_length', args: [ident(::temp1), ident(myArray)]

		expr_data := g.get_operand_from_expr(mut &expr.expr)
		g.free_temp(expr_data)

		//переменная для результата
		var_data := g.get_free_temp(expr.typ)

		//добавляем инструкцию в функцию
		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.array_length
			args: [var_data, expr_data]
		}

		return var_data
	}
	
	//opcode: 'propget', args: [ident(myProperty), ident(arg), ident(::temp0)]

	expr_data := g.get_operand_from_expr(mut &expr.expr)
	g.free_temp(expr_data)

	//переменная для результата
	var_data := g.get_free_temp(expr.typ)

	//добавляем инструкцию в функцию
	g.cur_fn.info.instructions << pex.Instruction{
		op: pex.OpCode.propget
		args: [
			pex.VariableData{ typ: 1, string_id: g.gen_string_ref(expr.field_name) },
			expr_data,
			var_data
		]
	}

	return var_data
}

fn (mut g Gen) get_operand_from_expr(mut expr &ast.Expr) pex.VariableData {
	mut var_data := pex.VariableData{ typ: 0 }

	match mut expr {
		ast.InfixExpr {
			var_data = g.gen_infix_operator(mut &expr)
		}
		ast.ParExpr {
			var_data = g.get_operand_from_expr(mut &expr.expr)
		}
		ast.CallExpr {
			var_data = g.gen_call_expr(mut &expr)
		}
		ast.PrefixExpr {
			var_data = g.gen_prefix_operator(mut &expr)
		}
		ast.Ident {
			if expr.is_property {
				if f := g.table.find_property(g.cur_obj_name, expr.name) {
					
					if token.Kind.key_auto in f.flags {
						return pex.VariableData{ typ: 1, string_id: g.gen_string_ref(f.default_var_name) }
					}

					return g.gen_selector(mut &ast.SelectorExpr{
						expr: ast.Ident {
							name: 'self'
							typ: ast.Type(g.table.find_type_idx(g.cur_obj_name))
						}
						field_name: expr.name
						typ: f.typ
					})
				}

			}

			return pex.VariableData{ typ: 1, string_id: g.gen_string_ref(expr.name) }
		}
		ast.NoneLiteral {
			return pex.VariableData{ typ: 0 }
		}
		ast.IntegerLiteral {
			if g.pref.crutches_enabled && expr.val.starts_with("0x") {
				var_data = g.get_free_temp(ast.int_type)

				g.cur_fn.info.instructions << pex.Instruction{
					op: pex.OpCode.callstatic
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
			var_data = g.gen_array_init(mut &expr)
		}
		ast.SelectorExpr {
			var_data = g.gen_selector(mut &expr)
		}
		ast.IndexExpr {
			var_data = g.gen_array_get_element(mut &expr)
		}
		ast.CastExpr {
			expr_data := g.get_operand_from_expr(mut &expr.expr)
			g.free_temp(expr_data)
			var_data = g.get_free_temp(&expr.typ)
			g.gen_cast(var_data, expr_data)
		}
		ast.EmptyExpr {
			panic("wtf") //var_data = pex.VariableData{ typ: 0 }
		}
	}

	return var_data
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