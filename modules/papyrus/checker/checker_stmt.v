module checker

import papyrus.ast
import papyrus.token

fn (mut c Checker) top_stmt(node ast.TopStmt) {
	match mut node {
		ast.ScriptDecl {
			c.cur_obj_name = node.name

			if node.parent_name != "" {
				if !c.table.known_type(node.parent_name) {
					c.error("invalid parent `$node.parent_name`", node.pos)
				}
			}
		}
		ast.StateDecl {
			mut i := 0
			
			c.cur_state_name = node.name

			for i < node.fns.len {
				c.fn_decl(mut node.fns[i])
				i++
			}

			c.cur_state_name = token.default_state_name
		}
		ast.FnDecl {
			c.fn_decl(mut node)
		}
		ast.VarDecl {
			c.var_decl(mut node)
		}
		ast.PropertyDecl {
			if c.type_is_valid(node.typ) {
				c.table.register_field(ast.Prop{
					name: node.name
					obj_name: c.cur_obj_name
					typ: node.typ
				})

				if token.Kind.key_auto in node.flags {
					c.file.stmts << ast.VarDecl {
						typ: node.typ
						obj_name: c.cur_obj_name
						name: "::" + node.name + "_var"
						assign: {
							op: token.Kind.assign
							pos: node.pos
							left: ast.Ident{
								name: node.name
								pos: node.pos
								typ: node.typ
							}
							right: node.expr
							typ: node.typ
						}
						pos: node.pos
						flags: []
						is_obj_var: true
					}
				}
			}
			else {
				c.error("invalid type in property declaration", node.pos)
			}
		}
		ast.Comment {}
	}
}

fn (mut c Checker) stmts(stmts []ast.Stmt) {

	for stmt in stmts {
		c.stmt(stmt)
	}
}
fn (mut c Checker) stmt(node ast.Stmt) {
	match mut node {
		ast.Return {
			typ := c.expr(node.expr)
			
			if c.valid_type(typ, c.cur_fn.return_type) {

			}
			else if c.can_cast(typ, c.cur_fn.return_type) {
				new_expr := ast.CastExpr {
					expr: node.expr
					pos: node.expr.pos
					type_name: c.get_type_name(c.cur_fn.return_type)
					typ: c.cur_fn.return_type
				}
				
				node.expr = new_expr
			}
			else {
				type_name := c.get_type_name(typ)
				fn_type_name := c.get_type_name(c.cur_fn.return_type)
				c.error("expected to return a value with type `$fn_type_name` not `$type_name`", node.pos)
			}
		}
		ast.If {
			for branch in node.branches {
				c.expr(branch.cond)
			
				if branch.cond is ast.EmptyExpr {
					c.error("invalid condition in if statement",  node.pos)
				}
				
				for b_stmt in branch.stmts {
					c.stmt(b_stmt)
				}
			}
		}
		ast.While {
			c.expr(node.cond)

			if node.cond is ast.EmptyExpr {
				c.error("invalid condition in while statement",  node.pos)
			}

			for w_stmt in node.stmts {
				c.stmt(w_stmt)
			}
		}
		ast.ExprStmt {
			c.expr(node.expr)
		}
		ast.AssignStmt {
			if !node.op.is_assign() {
				c.error("invalid assign operator: `$node.op`",  node.pos)
			}

			if node.left is ast.Ident || node.left is ast.IndexExpr || node.left is ast.SelectorExpr {
				left_type := c.expr(node.left)
				mut right_type := c.expr(node.right)
				if node.right is ast.EmptyExpr {
					c.error("invalid right exression in assignment",  node.pos)
				}

				node.typ = left_type

				if left_type == right_type {}
				else if c.can_cast(right_type, left_type) {
					node.right = c.cast_to_type(node.right, right_type, left_type)
					right_type = left_type
				}
				else {
					ltype_name := c.get_type_name(left_type)
					rtype_name := c.get_type_name(right_type)
					c.error("value with type `$rtype_name` cannot be assigned to a variable with type `$ltype_name`",  node.pos)
				}

				if node.op != .assign {
					new_node := ast.InfixExpr{
						left: node.left
						left_type: left_type
						
						right: node.right
						right_type: left_type
						
						result_type: left_type
						pos: node.pos
						op: match node.op {
							.plus_assign { token.Kind.plus }
							.minus_assign { token.Kind.minus }
							.div_assign { token.Kind.div }
							.mult_assign { token.Kind.mul }
							.mod_assign { token.Kind.mod }
							else { token.Kind.plus }
						}
					}
					
					node.op = token.Kind.assign
					node.right = new_node
				}
			}
			else {
				c.error('invalid left-side expression in assignment', node.pos)
			}
		}
		ast.VarDecl {
			c.var_decl(mut node)
		}
		ast.Comment {}
	}
}

fn (mut c Checker) fn_decl(mut node ast.FnDecl) {
	unsafe {
		c.cur_fn = node
	}

	self_typ := c.table.find_type_idx(c.cur_obj_name)
	assert self_typ != 0

	c.cur_scope = node.scope

	for param in node.params {
		if c.type_is_valid(param.typ) {
			c.cur_scope.register(ast.ScopeVar{
				name: param.name
				typ: param.typ
				is_used: false
			})
		}
		else {
			type_name := c.get_type_name(param.typ)
			c.error("invalid param type `$type_name`", node.pos)
		}
	}
	
	if token.Kind.key_global !in node.flags {

		c.cur_scope.register(ast.ScopeVar{
			name: "self"
			typ: self_typ
		})
	}

	c.stmts(node.stmts)

	if c.is_state() {
		if func := c.find_fn(self_typ, c.cur_obj_name, node.name) {
			//проверка функции на эквивалентность оригиналу

			//а может быть лучше сделать проверку при регистрации функции?
		}
		else {
			//error
		}
	}

	c.cur_scope = c.file.scope
}

pub fn (mut c Checker) var_decl(mut node ast.VarDecl) {
	if c.type_is_valid(node.typ) {
		c.cur_scope.register(ast.ScopeVar{
			name: node.name
			typ: node.typ
			pos: node.pos
			is_used: false
		})
		
		if node.assign.right is ast.EmptyExpr {
			match node.typ {
				ast.int_type { node.assign.right = ast.IntegerLiteral{val:"0"} }
				ast.float_type { node.assign.right = ast.FloatLiteral{val:"0"} }
				ast.string_type { node.assign.right = ast.StringLiteral{val:""} }
				ast.bool_type { node.assign.right = ast.BoolLiteral{val:"False"}}
				else {
					sym := c.table.get_type_symbol(node.typ)
					if sym.kind == .script {
						node.assign.right = ast.NoneLiteral{val:"None"}
					}
				}
			}
		}

		if node.assign.right !is ast.EmptyExpr {
			c.stmt(node.assign)
		}
	}
	else {
		c.error("invalid type in variable declaration", node.pos)
	}
}