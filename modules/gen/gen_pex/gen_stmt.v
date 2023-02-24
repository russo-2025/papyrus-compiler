module gen_pex

import papyrus.ast
import papyrus.token
import pex

[inline]
fn (mut g Gen) script_decl(mut s &ast.ScriptDecl) {
	mut obj := g.create_obj(s.name, s.parent_name)

	g.pex.objects << obj
	
	g.cur_obj = g.pex.objects[g.pex.objects.len - 1]

	g.cur_obj_name = s.name
	g.cur_obj_type = g.table.find_type_idx(s.name)
	
	for flag in s.flags {
		if flag == .key_hidden {
			g.cur_obj.user_flags |= 0b0001
		}
		else if flag == .key_conditional {
			g.cur_obj.user_flags |= 0b0010
		}
		else {
			panic("invalid flag: `${flag.str()}`")
		}
	}

	state := g.create_state(pex.empty_state_name)
	g.cur_obj.states << state

	g.cur_state = state
	g.empty_state = state
	
	g.add_default_functions_to_state(mut g.empty_state)

	g.pex.user_flags << pex.UserFlag{
		name: g.gen_string_ref("hidden")
		flag_index: 0
	}
	g.pex.user_flags << pex.UserFlag{
		name: g.gen_string_ref("conditional")
		flag_index: 1
	}
}

[inline]
fn (mut g Gen) state_decl(mut s &ast.StateDecl) {
	if s.is_auto {
		g.cur_obj.auto_state_name = g.gen_string_ref(s.name)
	}

	mut state := g.create_state(s.name)
	g.cur_obj.states << state
	
	g.cur_state = g.cur_obj.states[g.cur_obj.states.len - 1]

	for mut func in s.fns {
		g.fn_decl(mut &func)
	}
	
	g.cur_state = g.empty_state
}

[inline]
fn (mut g Gen) if_stmt(mut s &ast.If) {
	//opcode: 'assign', args: [ident(ff), integer(11)]
	//opcode: 'jmpf', args: [integer(1), integer(3)]
	//opcode: 'assign', args: [ident(ff), integer(22)]
	//opcode: 'jmp', args: [integer(7)]
	//opcode: 'jmpf', args: [integer(2), integer(3)]
	//opcode: 'assign', args: [ident(ff), integer(33)]
	//opcode: 'jmp', args: [integer(4)]
	//opcode: 'jmpf', args: [integer(3), integer(3)]
	//opcode: 'assign', args: [ident(ff), integer(44)]
	//opcode: 'jmp', args: [integer(1)]

	mut jmp_to_end_ids := []int{}  //прыжки в конец условия
	mut jmp_to_next_ids := []int{} //прыжки к следующей ветке

	mut i := 0
	for i < s.branches.len {
		mut b := s.branches[i]
		
		//если это не последний else то добавляем jmpf
		if !s.has_else || i < s.branches.len - 1 {
			//условие
			var_data := g.get_operand_from_expr(mut &b.cond)
			g.free_temp(var_data)
			//добавляем индекс jmpf в массив(для добавления относительной позиции)
			jmp_to_next_ids << g.cur_fn.info.instructions.len
			//добавляем прыжок к следующему блоку (jmpf)
			g.cur_fn.info.instructions << pex.Instruction{
				op: pex.OpCode.jmpf
				args: [ var_data ]
			}
		}
		//выполняем блок
		for mut stmt in b.stmts {
			g.stmt(mut stmt)
		}
		//если элемент не последний
		if i != s.branches.len - 1 {
			//добавляем индекс прыжка в массив
			jmp_to_end_ids << g.cur_fn.info.instructions.len
			//добавляем прыжок в конец
			g.cur_fn.info.instructions << pex.Instruction{
				op: pex.OpCode.jmp
				args: [ ]
			}
		}

		//если это не последний else, то добавляем относительный индекс к последнему jmpf
		if !s.has_else || i < s.branches.len - 1 {
			//добавляем относительный индекс
			index := jmp_to_next_ids[jmp_to_next_ids.len - 1]
			g.cur_fn.info.instructions[index].args << pex.VariableData{ typ: 3, integer: g.cur_fn.info.instructions.len - index }
		}

		i++
	}

	//добавляем относительный индекс у прыжков в конец условия
	for index in jmp_to_end_ids {
		g.cur_fn.info.instructions[index].args << pex.VariableData{ typ: 3, integer: g.cur_fn.info.instructions.len - index }
	}
}

[inline]
fn (mut g Gen) gen_fn(mut node &ast.FnDecl) &pex.Function {
	mut f := pex.Function{
		name: g.gen_string_ref(node.name)
		info: pex.FunctionInfo{
			return_type: g.gen_string_ref(g.table.type_to_str(node.return_type))
			docstring: g.gen_string_ref("")
			user_flags: 0 //u32	
			flags: 0
			
			params: []pex.VariableType{}
			locals: []pex.VariableType{}
			instructions: []pex.Instruction{}
		}
	}

	g.cur_fn = &f

	g.pex.functions << pex.DebugFunction{
		object_name: g.cur_obj.name
		state_name: g.cur_state.name
		function_name: f.name
		function_type: 0 // TODO выяснить что это
		instruction_line_numbers: []u16{}
	}

	g.temp_locals = []TempVariable{}

	for flag in node.flags {
		if flag == .key_global {
			f.info.flags |= 0b0001
		}
		else if flag == .key_native {
			f.info.flags |= 0b0010
		}
		else {
			panic("invalid flag: `${flag.str()}`")
		}
	}

	for param in node.params {
		f.info.params << pex.VariableType{
			name: g.gen_string_ref(param.name)
			typ: g.gen_string_ref(g.table.type_to_str(param.typ))
		}
	}

	for mut stmt in node.stmts {
		g.stmt(mut stmt)
	}
	
	g.cur_fn = unsafe { voidptr(0) } // лучше пусть упадет с ошибкой, чем просто добавит инструкции туда куда не должен был

	return &f
}

[inline]
fn (mut g Gen) fn_decl(mut node &ast.FnDecl) {
	g.cur_state.functions << g.gen_fn(mut node)
}

[inline]
fn (mut g Gen) assign(mut stmt &ast.AssignStmt) {
	if stmt.right is ast.EmptyExpr {
		return
	}

	if mut stmt.left is ast.Ident {
		mut name := stmt.left.name

		sym := g.table.get_type_symbol(g.cur_obj_type)
		if prop := sym.find_property(name) {
			if prop.is_auto {
				name = prop.auto_var_name
			}
			else {
				//значение
				right_data := g.get_operand_from_expr(mut &stmt.right)
				g.free_temp(right_data)

				//добавляем инструкцию в функцию
				g.cur_fn.info.instructions << pex.Instruction{
					op: pex.OpCode.propset
					args: [
						pex.VariableData{ typ: 1, string_id: g.gen_string_ref(name) },
						pex.VariableData{ typ: 1, string_id: g.gen_string_ref("self") },
						right_data
					]
				}

				return
			}
		}

		//opcode: 'assign', args: [ident(::temp1), integer(111)]
		var_data := g.get_operand_from_expr(mut &stmt.right)
		g.free_temp(var_data)

		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.assign
			args: [
				pex.VariableData{
					typ: 1
					string_id: g.gen_string_ref(name)
				}, 
				var_data 
			]
		}
	}
	else if mut stmt.left is ast.IndexExpr {
		//opcode: 'array_setelement', args: [ident(arr), integer(0), ident(::temp1)]
		left_data := g.get_operand_from_expr(mut &stmt.left.left)
		index_data := g.get_operand_from_expr(mut &stmt.left.index)
		right_data := g.get_operand_from_expr(mut &stmt.right)
		g.free_temp(index_data)
		g.free_temp(right_data)

		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.array_setelement
			args: [ left_data, index_data, right_data ]
		}
	}
	else if mut stmt.left is ast.SelectorExpr {
		//opcode: 'propset', args: [ident(myProperty), ident(arg), ident(::temp0)]

		expr_data := g.get_operand_from_expr(mut &stmt.left.expr)
		g.free_temp(expr_data)

		//значение
		right_data := g.get_operand_from_expr(mut &stmt.right)
		g.free_temp(right_data)

		//добавляем инструкцию в функцию
		g.cur_fn.info.instructions << pex.Instruction{
			op: pex.OpCode.propset
			args: [
				pex.VariableData{ typ: 1, string_id: g.gen_string_ref(stmt.left.field_name) },
				expr_data,
				right_data
			]
		}
	}
	else {
		panic("Gen assign stmt TODO")
	}
}

[inline]
fn (mut g Gen) var_decl(mut stmt &ast.VarDecl) {
	if stmt.is_object_var {
		mut user_flags := u32(0)

		if token.Kind.key_conditional in stmt.flags {
			user_flags |= 0b0010
		}
		
		g.cur_obj.variables << &pex.Variable{
			name: g.gen_string_ref(stmt.name)
			type_name: g.gen_string_ref(g.table.type_to_str(stmt.typ))
			user_flags: user_flags
			data: g.get_operand_from_expr(mut &stmt.assign.right)
		}
	}
	else {
		g.cur_fn.info.locals << pex.VariableType{
			name: g.gen_string_ref(stmt.name)
			typ: g.gen_string_ref(g.table.type_to_str(stmt.typ))
		}

		g.assign(mut stmt.assign)
	}
}
 
[inline]
fn (mut g Gen) prop_decl(mut stmt &ast.PropertyDecl) {
	mut prop := pex.Property{
		name: g.gen_string_ref(stmt.name)
		typ: g.gen_string_ref(g.table.type_to_str(stmt.typ))
		docstring: g.gen_string_ref("")
		user_flags: 0
		flags: 0
		auto_var_name: 0
	}

	if stmt.is_hidden {
		prop.user_flags = 1
	}

	if stmt.is_auto {
		prop.flags |= 0b0111

		prop.auto_var_name = g.gen_string_ref(stmt.auto_var_name)
		
		var_data := if stmt.expr is ast.EmptyExpr {
			pex.VariableData{ typ: 0 }
		} else {
			g.get_operand_from_expr(mut &stmt.expr)
		}
		
		g.cur_obj.variables << &pex.Variable{
			name: g.gen_string_ref(stmt.auto_var_name)
			type_name: g.gen_string_ref(g.table.type_to_str(stmt.typ))
			user_flags: u32(0)
			data: var_data
		}
	}
	else if stmt.is_autoread {
		prop.flags |= 0b0001
		prop.read_handler = pex.FunctionInfo{
			return_type: g.gen_string_ref(g.table.type_to_str(stmt.typ))
			docstring: g.gen_string_ref("")
			user_flags: 0
			flags: 0
			
			instructions: [
				pex.Instruction{
					op: pex.OpCode.ret
					args: [g.get_operand_from_expr(mut &stmt.expr)]
				}
			]
		}
	}
	else {
		if mut stmt.read is ast.FnDecl {
			prop.flags |= 0b0001
			prop.read_handler = g.gen_fn(mut stmt.read).info
		}

		if mut stmt.write is ast.FnDecl {
			prop.flags |= 0b0010
			prop.write_handler = g.gen_fn(mut stmt.write).info
		}
	}
	
	g.cur_obj.properties << &prop
}

[inline]
fn (mut g Gen) while_stmt(mut s &ast.While) {
	//original
	//opcode: 'assign', args: [ident(ff), integer(0)]
	//opcode: 'assign', args: [ident(i), integer(0)]
	//opcode: 'cmp_lt', args: [ident(::temp0), ident(i), integer(5)]
	//opcode: 'jmpf', args: [ident(::temp0), integer(6)]
	//opcode: 'iadd', args: [ident(::temp1), ident(ff), integer(5)]
	//opcode: 'assign', args: [ident(ff), ident(::temp1)]
	//opcode: 'iadd', args: [ident(::temp1), ident(i), integer(1)]
	//opcode: 'assign', args: [ident(i), ident(::temp1)]
	//opcode: 'jmp', args: [integer(-6)]
	
	start_index := g.cur_fn.info.instructions.len

	var_data := g.get_operand_from_expr(mut &s.cond)

	jmpf_index := g.cur_fn.info.instructions.len

	g.cur_fn.info.instructions << pex.Instruction{
		op: pex.OpCode.jmpf
		args: [ var_data ]
	}

	g.free_temp(var_data)

	for mut stmt in s.stmts {
		g.stmt(mut stmt)
	}

	g.cur_fn.info.instructions << pex.Instruction{
		op: pex.OpCode.jmp
		args: [ pex.VariableData{ typ: 3, integer: start_index - g.cur_fn.info.instructions.len } ]
	}

	g.cur_fn.info.instructions[jmpf_index].args << pex.VariableData{ typ: 3, integer: g.cur_fn.info.instructions.len - jmpf_index }
}