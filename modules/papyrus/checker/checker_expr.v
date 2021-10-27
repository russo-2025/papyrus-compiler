module checker

import papyrus.ast

pub fn (mut c Checker) expr(node ast.Expr) ast.Type {
	
	match mut node {
		ast.InfixExpr {
			return c.expr_infix(mut node)
		}
		ast.PrefixExpr {
			if !node.op.is_prefix() {
				c.error("invalid prefix operator: `$node.op`",  node.pos)
			}

			node.right_type = c.expr(node.right)

			if node.right is ast.EmptyExpr {
				c.error("invalid right operand in prefix expression(`$node.op`)",  node.pos)
			}

			match node.op {
				.not {
					if node.right_type == ast.bool_type {

					}
					else if c.can_cast(node.right_type, ast.bool_type) {
						new_expr := ast.CastExpr {
							expr: node.right
							pos: node.pos
							type_name: c.get_type_name(ast.bool_type)
							typ: ast.bool_type
						}

						node.right_type = ast.bool_type
						node.right = new_expr
					}
					else {
						type_name := c.get_type_name(node.right_type)
						c.error("prefix operator: `!` not support type: `$type_name`",  node.pos)
					}
				}
				.minus {
					if node.right_type != ast.int_type && node.right_type != ast.float_type {
						type_name := c.get_type_name(node.right_type)
						c.error("prefix operator: `-` not support type: `$type_name`",  node.pos)
					}
				}
				.plus { panic("wtf") }
				else { panic("wtf") }
			}

			return node.right_type
		}
		ast.ParExpr {
			if node.expr is ast.EmptyExpr {
				c.error("invalid expression",  node.pos)
			}

			return c.expr(node.expr)
		}
		ast.NoneLiteral {
			return ast.none_type
		}
		ast.IntegerLiteral { 
			return ast.int_type
		}
		ast.FloatLiteral { 
			return ast.float_type
		}
		ast.BoolLiteral { 
			return ast.bool_type
		}
		ast.StringLiteral {
			return ast.string_type
		}
		ast.Ident {
			if obj := c.cur_scope.find_var(node.name) {
				if node.pos.pos >= obj.pos.pos {
					node.typ = obj.typ
					return obj.typ
				}
			}
			else if obj := c.table.find_field(c.cur_obj_name, node.name){
				node.typ = obj.typ
				node.is_property = true
				return obj.typ
			}
			else {
				c.error("variable declaration not found: `$node.name`",  node.pos)
				return ast.none_type
			}
		}
		ast.CallExpr {
			return c.call_expr(mut node)
		}
		ast.ArrayInit {

			if node.len.type_name() != "papyrus.ast.IntegerLiteral" {
				c.error("size can only be a literal integer: " + node.len.type_name(),  node.pos)
			} else{
				length := (node.len as ast.IntegerLiteral).val.f32()
				if (length < 1) || (length > 128){
					c.error("size out of possible range (1-128), use papyrusutil or something similar for larger arrays",  node.pos)
				}
			}
			return node.typ
		}
		ast.IndexExpr {
			index_type := c.expr(node.index)

			if index_type != ast.int_type {
				c.error("index can only be a number",  node.pos)
			}

			if node.left is ast.Ident {
				if obj := c.cur_scope.find_var(node.left.name) {
					if node.pos.pos > obj.pos.pos + obj.pos.len {
						node.typ = obj.typ

						sym := c.table.get_type_symbol(node.typ)
						
						if sym == 0 || sym.kind != .array || sym.info !is ast.Array {
							c.error("invalid type in index expression",  node.pos)
						}
						else {
							info := c.table.get_type_symbol(node.typ).info as ast.Array
							node.typ = info.elem_type
							return info.elem_type
						}
					}
				}
				else {
					c.error("array declaration not found: `$node.left.name`",  node.pos)
				}
			}
			else {
				c.error("left-side expression in index expression is not indifier",  node.pos)
			}
		}
		ast.SelectorExpr {
			node.typ = c.expr(node.expr)
			mut sym := c.table.get_type_symbol(node.typ)

			if node.field_name.to_lower() == "length" {
				if sym == 0 || sym.kind != .array {
					c.error("`.Length` property is only available for arrays",  node.pos)
				}

				node.typ = ast.int_type
				return ast.int_type
			}
			else {
				if f := c.table.find_field(sym.obj_name, node.field_name) {
					return f.typ
				}
				else {
					for {
						if f := c.table.find_field(sym.obj_name, node.field_name) {
							return f.typ
						}

						if sym.parent_idx > 0 {
							sym = c.table.get_type_symbol(sym.parent_idx)
							continue
						}

						break
					}
					c.error("`${sym.obj_name}.${node.field_name}` property declaration not found", node.pos)
				}
			}
			
			return node.typ
		}
		ast.CastExpr {
			expr_type := c.expr(node.expr)

			idx := c.table.find_type_idx(node.type_name)
			if idx > 0 {
				node.typ = idx
				return idx
			}
			
			if !c.can_cast(expr_type, node.typ) {
				expr_type_name := c.get_type_name(expr_type)
				type_name := c.get_type_name(node.typ)
				c.error("cannot convert type `$expr_type_name` to type `$type_name`",  node.pos)
			}
		}
		ast.EmptyExpr {
			return ast.none_type
		}
		ast.DefaultValue{
			panic("===checker.v WTF expr()===")
		}
	}

	eprintln(node)
	panic("expression not processed in file: `$c.file.path`")
}

pub fn (mut c Checker) expr_infix(mut node &ast.InfixExpr) ast.Type {
	if !node.op.is_infix() {
		c.error("invalid infix operator: `$node.op`",  node.pos)
	}

	node.left_type = c.expr(node.left)
	node.right_type = c.expr(node.right)

	if node.right is ast.EmptyExpr {
		c.error("invalid right operand in infix expression(`$node.op`)",  node.pos)
	}

	match node.op {
		.plus {
			if node.left_type == node.right_type {
				//check int, float, string
				if node.left_type != ast.int_type && node.left_type != ast.float_type && node.left_type != ast.string_type {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
				node.result_type = node.left_type
			}
			else if node.left_type == ast.string_type || node.right_type == ast.string_type {
				node.result_type = ast.string_type

				if node.left_type == ast.string_type {
					node.right = c.cast_to_type(node.right, node.right_type, ast.string_type)
					node.right_type = ast.string_type
				}
				else if node.right_type == ast.string_type {
					node.left = c.cast_to_type(node.left, node.left_type, ast.string_type)
					node.left_type = ast.string_type
				}
			}
			else if node.left_type == ast.float_type || node.right_type == ast.float_type {
				node.result_type = ast.float_type

				if node.left_type == ast.float_type {
					node.right = c.cast_to_type(node.right, node.right_type, ast.float_type)
					node.right_type = ast.float_type
				}
				else if node.right_type == ast.float_type {
					node.left = c.cast_to_type(node.left, node.left_type, ast.float_type)
					node.left_type = ast.float_type
				}
			}
			else {
				node.result_type = ast.int_type

				if node.left_type == ast.int_type {
					node.right = c.cast_to_type(node.right, node.right_type, ast.int_type)
					node.right_type = ast.int_type
				}
				else if node.right_type == ast.int_type {
					node.left = c.cast_to_type(node.left, node.left_type, ast.int_type)
					node.left_type = ast.int_type
				}
				else {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
			}
		}
		.minus, .mul, .div {
			if node.left_type == node.right_type {
				//check left int, float
				if node.left_type != ast.int_type && node.left_type != ast.float_type {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
				node.result_type = node.left_type
			}
			else if node.left_type == ast.float_type || node.right_type == ast.float_type {
				node.result_type = ast.float_type

				if node.left_type == ast.float_type {
					node.right = c.cast_to_type(node.right, node.right_type, ast.float_type)
					node.right_type = ast.float_type
				}
				else if node.right_type == ast.float_type {
					node.left = c.cast_to_type(node.left, node.left_type, ast.float_type)
					node.left_type = ast.float_type
				}
			}
			else {
				node.result_type = ast.int_type

				if node.left_type == ast.int_type {
					node.right = c.cast_to_type(node.right, node.right_type, ast.int_type)
					node.right_type = ast.int_type
				}
				else if node.right_type == ast.int_type {
					node.left = c.cast_to_type(node.left, node.left_type, ast.int_type)
					node.left_type = ast.int_type
				}
				else {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
			}
		}
		.gt, .lt, .ge, .le {
			node.result_type = ast.bool_type

			if node.left_type == node.right_type {
				//check left int, float
				if node.left_type != ast.int_type && node.left_type != ast.float_type {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
			}
			else if node.left_type == ast.float_type || node.right_type == ast.float_type {
				if node.left_type == ast.float_type {
					node.right = c.cast_to_type(node.right, node.right_type, ast.float_type)
					node.right_type = ast.float_type
				}
				else if node.right_type == ast.float_type {
					node.left = c.cast_to_type(node.left, node.left_type, ast.float_type)
					node.left_type = ast.float_type
				}
			}
			else {
				if node.left_type == ast.int_type {
					node.right = c.cast_to_type(node.right, node.right_type, ast.int_type)
					node.right_type = ast.int_type
				}
				else if node.right_type == ast.int_type {
					node.left = c.cast_to_type(node.left, node.left_type, ast.int_type)
					node.left_type = ast.int_type
				}
				else {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
			}
		}
		.mod {
			node.result_type = ast.int_type

			if node.left_type == ast.int_type && node.right_type == ast.int_type  {

			}
			else if node.left_type == ast.int_type {
				node.right = c.cast_to_type(node.right, node.right_type, ast.int_type)
				node.right_type = ast.int_type
			}
			else if node.right_type == ast.int_type {
				node.left = c.cast_to_type(node.left, node.left_type, ast.int_type)
				node.left_type = ast.int_type
			}
			else {
				ltype_name := c.get_type_name(node.left_type)
				rtype_name := c.get_type_name(node.right_type)
				c.error("infix operator `$node.op` not support type `$ltype_name`, `$rtype_name`",  node.pos)
			}
		}
		.eq, .ne {
			node.result_type = ast.bool_type

			if node.left_type == node.right_type {}
			else {
				if c.can_cast(node.right_type, node.left_type) {
					node.right = c.cast_to_type(node.right, node.right_type, node.left_type)
					node.right_type = node.left_type
				}
				else {
					ltype_name := c.get_type_name(node.left_type)
					rtype_name := c.get_type_name(node.right_type)
					c.error("you can't compare type `$ltype_name` with type `$rtype_name`",  node.pos)
				}
			}
		}
		.and, .logical_or {
			if node.left_type != ast.bool_type {
				node.left = c.cast_to_type(node.left, node.left_type, ast.bool_type)
				node.left_type = ast.bool_type
			}
			
			if node.right_type != ast.bool_type {
				node.right = c.cast_to_type(node.right, node.right_type, ast.bool_type)
				node.right_type = ast.bool_type
			}

			node.result_type = ast.bool_type
		}
		else {
			panic("wtf ($node.op)")
		}
	}

	return node.result_type
}

pub fn (mut c Checker) call_expr(mut node &ast.CallExpr) ast.Type {
	mut left := c.cur_obj_name
	mut name := node.name
	mut typ := 0

	if node.left is ast.EmptyExpr {
		left = c.cur_obj_name
	}
	else if node.left is ast.Ident && c.table.has_module((node.left as ast.Ident).name) {
		left = (node.left as ast.Ident).name
		typ = (node.left as ast.Ident).typ
	}
	else {
		if node.left is ast.Ident {
			left = (node.left as ast.Ident).name
		}
		typ = c.expr(node.left)
	}

	if left == "" {
		panic("wtf")
	}

	if func := c.find_fn(typ, left, name) {
		node.obj_name = func.obj_name
		node.return_type = func.return_type
		node.is_static = func.is_static

		if node.args.len > func.params.len {
			c.error("function takes $func.params.len parameters not $node.args.len", node.pos)
			return ast.none_type
		}

		//добавляем параметры по умолчанию
		if node.args.len < func.params.len {
			mut i := node.args.len
			for i < func.params.len {
				if func.params[i].is_optional {
					func_arg_def_value := func.params[i].default_value
					match func.params[i].typ {
					 ast.int_type {
							node.args << ast.CallArg {
								expr: ast.IntegerLiteral{ val: func_arg_def_value }
								typ: ast.int_type 
							}
						}
					 ast.float_type {
							node.args << ast.CallArg {
								expr: ast.FloatLiteral{ val: func_arg_def_value }
								typ: ast.float_type 
							}
						}
					 ast.string_type {
							node.args << ast.CallArg {
								expr: ast.StringLiteral{ val: func_arg_def_value }
								typ: ast.string_type 
							}
						}
					 ast.bool_type {
							node.args << ast.CallArg {
								expr: ast.BoolLiteral{ val: func_arg_def_value }
								typ: ast.bool_type
							}
						}
					 ast.none_type {
							node.args << ast.CallArg {
								expr: ast.NoneLiteral{ val: "None" }
								typ: ast.none_type
							}
						}
						else {
							node.args << ast.CallArg {
								expr: ast.NoneLiteral{ val: "None" }
								typ: func.params[i].typ
							}
						}
					}
				}
				else {
					break
				}

				i++
			}
		}

		if node.args.len != func.params.len {
			c.error("function takes $func.params.len parameters not $node.args.len", node.pos)
			return ast.none_type
		}

		mut i := 0
		for i < node.args.len {
			arg_typ := c.expr(node.args[i].expr)
			node.args[i].typ = arg_typ
			func_arg_type := func.params[i].typ
			
			if arg_typ == func_arg_type || (func.params[i].is_optional && c.valid_type(arg_typ, func_arg_type)) {

			}
			else if c.can_cast(arg_typ, func_arg_type) {
				new_expr := ast.CastExpr {
					expr: node.args[i].expr
					pos: node.args[i].pos
					type_name: c.get_type_name(func_arg_type)
					typ: func_arg_type
				}
				
				node.args[i].expr = new_expr
			}
			else {
				left_type_name := c.get_type_name(func_arg_type)
				right_type_name := c.get_type_name(arg_typ)
				c.error("cannot convert type `$right_type_name` to type `$left_type_name`", node.pos)
			}

			i++
		}

		return node.return_type
	}
	else {
		c.error("undefined function: " + left + "." + name,  node.pos)
	}

	return ast.none_type
}