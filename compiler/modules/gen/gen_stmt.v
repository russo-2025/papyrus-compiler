module gen

import papyrus.ast
import papyrus.token
import pex

[inline]
fn (mut g Gen) if_stmt(s &ast.If) {
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
		b := s.branches[i]
		
		//если это не последний else то добавляем jmpf
		if !s.has_else || i < s.branches.len - 1 {
			//условие
			var_data := g.get_operand_from_expr(&b.cond)
			g.free_temp(var_data)
			//добавляем индекс jmpf в массив(для добавления относительной позиции)
			jmp_to_next_ids << g.cur_fn.info.instructions.len
			//добавляем прыжок к следующему блоку (jmpf)
			g.cur_fn.info.instructions << pex.Instruction{
				op: byte(pex.OpCode.jmpf)
				args: [ var_data ]
			}
			g.cur_fn.info.num_instructions++
		}
		//выполняем блок
		for stmt in b.stmts {
			g.stmt(stmt)
		}
		//если элемент не последний
		if i != s.branches.len - 1 {
			//добавляем индекс прыжка в массив
			jmp_to_end_ids << g.cur_fn.info.instructions.len
			//добавляем прыжок в конец
			g.cur_fn.info.instructions << pex.Instruction{
				op: byte(pex.OpCode.jmp)
				args: [ ]
			}
			g.cur_fn.info.num_instructions++
		}

		//если это не последний else, то добавляем относительный индекс к последнему jmpf
		if !s.has_else || i < s.branches.len - 1 {
			//добавляем относительный индекс
			index := jmp_to_next_ids[jmp_to_next_ids.len - 1]
			g.cur_fn.info.instructions[index].args << { typ: 3, integer: g.cur_fn.info.instructions.len - index }
		}

		i++
	}

	//добавляем относительный индекс у прыжков в конец условия
	for index in jmp_to_end_ids {
		g.cur_fn.info.instructions[index].args << { typ: 3, integer: g.cur_fn.info.instructions.len - index }
	}
}

[inline]
fn (mut g Gen) gen_fn(node &ast.FnDecl) &pex.Function {
	mut f := pex.Function{
		name: g.gen_string_ref(node.name)
		info: pex.FunctionInfo{
			return_type: g.gen_string_ref(g.table.type_to_str(node.return_type))
			docstring: g.gen_string_ref("")
			user_flags: 0 //u32	
			flags: 0
			
			num_params: 0
			params: []pex.VariableType{}
			
			num_locals: 0
			locals: []pex.VariableType{}	
			
			num_instructions: 0
			instructions: []pex.Instruction{}
		}
	}
	
	g.cur_fn = &f
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

	for stmt in node.stmts {
		g.stmt(stmt)
	}
	
	f.info.num_params = u16(f.info.params.len)
	f.info.num_locals = u16(f.info.locals.len)
	f.info.num_instructions = u16(f.info.instructions.len)

	return &f
}

[inline]
fn (mut g Gen) fn_decl(node &ast.FnDecl) {
	g.pex.objects[0].data.states[0].num_functions++
	g.pex.objects[0].data.states[0].functions << g.gen_fn(node)
}

[inline]
fn (mut g Gen) assign(stmt &ast.AssignStmt) {

	if stmt.left is ast.Ident {
		//opcode: 'assign', args: [ident(::temp1), integer(111)]
		var_data := g.get_operand_from_expr(&stmt.right)
		g.free_temp(var_data)

		g.cur_fn.info.instructions << pex.Instruction{
			op: byte(pex.OpCode.assign)
			args: [
				pex.VariableData{
					typ: 1
					string_id: g.gen_string_ref(stmt.left.name)
				}, 
				var_data 
			]
		}
	}
	else if stmt.left is ast.IndexExpr {
		//opcode: 'array_setelement', args: [ident(arr), integer(0), ident(::temp1)]
		left_data := g.get_operand_from_expr(&stmt.left.left)
		index_data := g.get_operand_from_expr(&stmt.left.index)
		right_data := g.get_operand_from_expr(&stmt.right)
		g.free_temp(index_data)
		g.free_temp(right_data)

		g.cur_fn.info.instructions << pex.Instruction{
			op: byte(pex.OpCode.array_setelement)
			args: [ left_data, index_data, right_data ]
		}
	}
	else if stmt.left is ast.SelectorExpr {
		//opcode: 'propset', args: [ident(myProperty), ident(arg), ident(::temp0)]

		expr_data := g.get_operand_from_expr(&stmt.left.expr)
		g.free_temp(expr_data)

		//значение
		right_data := g.get_operand_from_expr(&stmt.right)
		g.free_temp(right_data)

		//добавляем инструкцию в функцию
		g.cur_fn.info.instructions << pex.Instruction{
			op: byte(pex.OpCode.propset)
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
fn (mut g Gen) var_decl(stmt &ast.VarDecl) {
	assert stmt.assign.right !is ast.EmptyExpr

	if stmt.is_obj_var {
		mut user_flags := u32(0)

		if token.Kind.key_conditional in stmt.flags {
			user_flags |= 0b0010
		}

		g.cur_obj.data.variables << pex.Variable{
			name: g.gen_string_ref(stmt.name)
			type_name: g.gen_string_ref(g.table.type_to_str(stmt.typ))
			user_flags: user_flags
			data: g.get_operand_from_expr(&stmt.assign.right)
		}

		g.cur_obj.data.num_variables++
	}
	else {
		g.cur_fn.info.locals << pex.VariableType{
			name: g.gen_string_ref(stmt.name)
			typ: g.gen_string_ref(g.table.type_to_str(stmt.typ))
		}

		g.assign(stmt.assign)
	}
}
 
[inline]
fn (mut g Gen) prop_decl(stmt &ast.PropertyDecl) {
	
	mut prop := pex.Property{
		name: g.gen_string_ref(stmt.name)
		typ: g.gen_string_ref(g.table.type_to_str(stmt.typ))
		docstring: g.gen_string_ref("")
		user_flags: 0
		flags: 0
		auto_var_name: 0
	}

	mut is_auto := false
	mut is_autoread := false

	for flag in stmt.flags {
		match flag {
			.key_auto {
				is_auto = true
			}
			.key_readonly {
				is_autoread = true
			}
			else{}
		}
	}

	if is_auto {
		prop.flags |= 0b0111

		var_name := "::" + stmt.name + "_var"
		prop.auto_var_name = g.gen_string_ref(var_name)
	}
	else if is_autoread {
		prop.flags |= 0b0001
		prop.read_handler = pex.FunctionInfo{
			return_type: g.gen_string_ref(g.table.type_to_str(stmt.typ))
			docstring: g.gen_string_ref("")
			user_flags: 0
			flags: 0

			num_instructions: 1
			instructions: [
				pex.Instruction{
					op: byte(pex.OpCode.ret)
					args: [g.get_operand_from_expr(&stmt.expr)]
				}
			]
		}
	}
	else {
		if stmt.read is ast.FnDecl {
			prop.flags |= 0b0001
			prop.read_handler = g.gen_fn(stmt.read).info
		}

		if stmt.write is ast.FnDecl {
			prop.flags |= 0b0010
			prop.write_handler = g.gen_fn(stmt.write).info
		}
	}
	
	g.cur_obj.data.properties << prop
	g.cur_obj.data.num_properties++
}

[inline]
fn (mut g Gen) script_decl(s &ast.ScriptDecl) {
	
	g.mod = s.name

	mut obj := pex.Object {
		name_index: g.gen_string_ref(s.name)
		size: 0
		data: pex.ObjectData {
				parent_class_name: g.gen_string_ref(s.parent_name)
				docstring: g.gen_string_ref("")
				user_flags: 0
				auto_state_name: g.gen_string_ref("")
				
				num_variables: 0
				variables: []pex.Variable{}
				
				num_properties: 0
				properties: []pex.Property{}
				
				num_states: 0
				states: []pex.State{}
		}
	}

	for flag in s.flags {
		if flag == .key_hidden {
			obj.data.user_flags |= 0b0001
		}
		else if flag == .key_conditional {
			obj.data.user_flags |= 0b0010
		}
		else {
			panic("invalid flag: `${flag.str()}`")
		}
	}

	obj.data.states << g.gen_default_state()
	obj.data.num_states++

	g.pex.objects << obj
	g.pex.object_count++

	unsafe {
		g.cur_obj = &g.pex.objects[g.pex.objects.len-1]
	}

	g.pex.user_flags << pex.UserFlag{
		name_index: g.gen_string_ref("hidden")
		flag_index: 0
	}
	g.pex.user_flag_count++

	g.pex.user_flags << pex.UserFlag{
		name_index: g.gen_string_ref("conditional")
		flag_index: 1
	}
	g.pex.user_flag_count++
}

[inline]
fn (mut g Gen) while_stmt(s &ast.While) {
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

	var_data := g.get_operand_from_expr(&s.cond)

	jmpf_index := g.cur_fn.info.instructions.len

	g.cur_fn.info.instructions << pex.Instruction{
		op: byte(pex.OpCode.jmpf)
		args: [ var_data ]
	}
	g.cur_fn.info.num_instructions++

	g.free_temp(var_data)

	for stmt in s.stmts {
		g.stmt(stmt)
	}

	g.cur_fn.info.instructions << pex.Instruction{
		op: byte(pex.OpCode.jmp)
		args: [ { typ: 3, integer: start_index - g.cur_fn.info.instructions.len } ]
	}
	g.cur_fn.info.num_instructions++

	g.cur_fn.info.instructions[jmpf_index].args << { typ: 3, integer: g.cur_fn.info.instructions.len - jmpf_index }
}