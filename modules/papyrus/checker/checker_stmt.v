module checker

import papyrus.ast
import papyrus.token
import pex

fn (mut c Checker) top_stmt(mut node ast.TopStmt) {
	match mut node {
		ast.ScriptDecl {
			c.cur_obj_name = node.name
			c.cur_parent_obj_name = node.parent_name
			c.cur_obj = c.table.find_type_idx(node.name)

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

			c.temp_state_fns = map[string]bool{}
			c.cur_state_name = pex.empty_state_name

			if node.is_auto {
				if !c.auto_state_is_exist {
					c.auto_state_is_exist = true
				}
				else {
					c.error("state with `Auto` flag already exists", node.pos)
				}
			}

			sym := c.table.get_type_symbol(c.cur_obj)
			if t_state := sym.find_state(node.name) {
				if t_state.pos.pos != node.pos.pos {
					c.error("state with this name already exists", node.pos)
				}
			}
		}
		ast.FnDecl {
			c.fn_decl(mut node)
		}
		ast.VarDecl {
			c.var_decl(mut node)
		}
		ast.PropertyDecl {
			if c.type_is_valid(node.typ) {
				c.inside_property = true

				if mut node.read is ast.FnDecl {
					c.top_stmt(mut &node.read)
				}

				if mut node.write is ast.FnDecl {
					c.top_stmt(mut &node.write)
				}

				sym := c.table.get_type_symbol(c.cur_obj)
				if t_prop := sym.find_property(node.name) {
					if t_prop.pos.pos != node.pos.pos {
						c.error("property with this name already exists", node.pos)
					}
				}
				
				c.inside_property = false
			}
			else {
				c.error("invalid type in property declaration", node.pos)
			}
		}
		ast.Comment {}
	}
}

fn (mut c Checker) stmts(mut stmts []ast.Stmt) {
	for mut stmt in stmts {
		c.stmt(mut stmt)
	}
}
fn (mut c Checker) stmt(mut node ast.Stmt) {
	match mut node {
		ast.Return {
			typ := c.expr(mut node.expr)
			
			if c.valid_type(typ, c.cur_fn.return_type) {}
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
			for mut branch in node.branches {
				c.expr(mut branch.cond)
			
				if branch.cond is ast.EmptyExpr {
					c.error("invalid condition in if statement",  node.pos)
				}
				
				c.cur_scope = branch.scope
				for mut b_stmt in branch.stmts {
					c.stmt(mut b_stmt)
				}
				c.cur_scope = c.cur_scope.parent
			}
		}
		ast.While {
			c.expr(mut node.cond)

			if node.cond is ast.EmptyExpr {
				c.error("invalid condition in while statement",  node.pos)
			}

			c.cur_scope = node.scope
			
			for mut w_stmt in node.stmts {
				c.stmt(mut w_stmt)
			}

			c.cur_scope = c.cur_scope.parent
		}
		ast.ExprStmt {
			c.expr(mut node.expr)
		}
		ast.AssignStmt {
			if !node.op.is_assign() {
				c.error("invalid assign operator: `$node.op`",  node.pos)
			}

			if node.left is ast.Ident || node.left is ast.IndexExpr || node.left is ast.SelectorExpr {
				left_type := c.expr(mut node.left)
				mut right_type := c.expr(mut node.right)
				if node.right is ast.EmptyExpr {
					c.error("invalid right exression in assignment",  node.pos)
				}

				node.typ = left_type

				if c.valid_type(left_type, right_type) {}
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

	c.cur_scope = node.scope
	c.inside_fn = true

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
			typ: c.cur_obj
		})

		if c.cur_parent_obj_name != "" {
			c.cur_scope.register(ast.ScopeVar{
				name: "parent"
				typ: c.table.find_type_idx(c.cur_parent_obj_name)
			})
		}
	}

	c.stmts(mut node.stmts)

	if !c.is_empty_state() {
		if !c.temp_state_fns[node.name] {
			if !c.inside_property {
				c.temp_state_fns[node.name] = true
			}
		}
		else {
			c.error("function with this name already exists: ${c.cur_obj_name}.${node.name}", node.pos)
		}

		if func := c.find_fn(c.cur_obj, c.cur_obj_name, node.name) {
			if node.is_global != func.is_global {
				c.error('declaration of the $node.name function in the $c.cur_state_name state is different from the declaration in the empty state', node.pos)
			}

			if node.return_type != func.return_type {
				c.error('declaration of the $node.name function in the $c.cur_state_name state is different from the declaration in the empty state', node.pos)
			}

			if node.params.len == func.params.len {
				mut i := 0
				for i < node.params.len {
					node_param := node.params[i]
					func_param := func.params[i]

					if node_param.typ != func_param.typ {
						c.error('declaration of the $node.name function in the $c.cur_state_name state is different from the declaration in the empty state', node.pos)
					}

					if node_param.is_optional != func_param.is_optional {
						c.error('declaration of the $node.name function in the $c.cur_state_name state is different from the declaration in the empty state', node.pos)
					}

					if node_param.default_value != func_param.default_value {
						c.error('declaration of the $node.name function in the $c.cur_state_name state is different from the declaration in the empty state', node.pos)
					}

					i++
				}
			}
			else {
				c.error('declaration of the $node.name function in the $c.cur_state_name state is different from the declaration in the empty state', node.pos)
			}
		}
		else {
			if !node.is_event {
				c.error('function $node.name cannot be defined in state $c.cur_state_name without also being defined in the empty state', node.pos)
			}
		}
	}
	else {
		if node.is_global {
			if func := c.table.find_fn(c.cur_obj_name, node.name) {
				if node.pos != func.pos {
					c.error("function with this name already exists: ${c.cur_obj_name}.${node.name}", node.pos)
				} 
			}
		}
		else {
			if func := c.table.get_type_symbol(c.cur_obj).find_method(node.name) {
				if node.pos != func.pos {
					c.error("function with this name already exists: ${c.cur_obj_name}.${node.name}", node.pos)
				} 
			}
		}
	}
	
	c.inside_fn = false
	c.cur_scope = c.cur_scope.parent
}

pub fn (mut c Checker) var_decl(mut node ast.VarDecl) {
	if node.assign.right is ast.EmptyExpr {
		node.assign.right = c.get_default_value(node.typ)
	}

	left_type := node.typ
	mut right_type := c.expr(mut node.assign.right)

	if c.valid_type(left_type, right_type) {}
	else if c.can_cast(right_type, left_type) {
		node.assign.right = c.cast_to_type(node.assign.right, right_type, left_type)
	}
	else {
		ltype_name := c.get_type_name(left_type)
		rtype_name := c.get_type_name(right_type)
		c.error("value with type `$rtype_name` cannot be assigned to a variable with type `$ltype_name`",  node.pos)
	}

	if !c.type_is_valid(node.typ) {
		c.error("invalid type in variable declaration", node.pos)
		return
	}

	if obj := c.cur_scope.find_var(node.name) {
		if node.pos.pos >= obj.pos.pos {
			c.error("variable with name `$node.name` already exists", node.pos)
			return
		}
	}

	c.cur_scope.register(ast.ScopeVar{
		name: node.name
		typ: node.typ
		pos: node.pos
		is_used: false
	})
	
	c.stmt(mut node.assign)
}