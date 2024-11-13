module gen_v

import papyrus.ast

fn (mut g Gen) stmts(stmts []ast.Stmt) {
	for i in 0..stmts.len {
		stmt := stmts[i]
		g.stmt(&stmt)

		if i < stmts.len - 1 {
			g.writeln("")
		}
	}
}

fn (mut g Gen) gen_global_fn(func &ast.FnDecl) {
	fn_name := g.get_global_fn_name(g.cur_obj_name, func.name)
	return_type := if func.return_type == ast.none_type { "" } else { g.get_type_name(func.return_type) }

	g.write("pub fn ${fn_name}(")
	g.gen_fn_args(func)
	g.write(") ${return_type} {")
	g.writeln("")
	g.indent_size++

	g.stmts(func.stmts)

	g.indent_size--
	g.writeln("")
	g.writeln("}")
}

fn (mut g Gen) gen_method(func &ast.FnDecl) {
	return_type := if func.return_type == ast.none_type { "" } else { g.get_type_name(func.return_type) }
	fn_name := g.get_method_name(func.name)

	g.write("pub fn (mut self ${g.cur_obj_name}) ${fn_name}(")
	g.gen_fn_args(func)
	g.write(") ${return_type} {")
	g.writeln("")
	g.indent_size++

	g.stmts(func.stmts)

	g.indent_size--
	g.writeln("")
	g.writeln("}")
}

fn (mut g Gen) gen_fn_args(func &ast.FnDecl) {
	for i := 0; i < func.params.len ; i++ {
		param := func.params[i]
		
		g.write("${param.name} ${g.get_type_name(param.typ)}")
		
		if param.is_optional {
			assert param.default_value.is_literal()
			
			val := match param.default_value {
				ast.NoneLiteral,
				ast.FloatLiteral,
				ast.IntegerLiteral,
				ast.BoolLiteral {
					param.default_value.val
				}
				ast.StringLiteral { "\"${param.default_value.val}\"" }
				else { "" }
			}
			g.write("/* = ${val} */")
		}

		if i < func.params.len - 1 {
			g.write(", ")
		}
	}
}

fn (mut g Gen) stmt(stmt &ast.Stmt) {
	match stmt {
		ast.Return {
			if g.cur_fn.return_type == ast.none_type {
				g.write_tab("return")
				g.writeln("")
				return 
			}

			g.write_tab("return ")
			g.gen_expr(stmt.expr)
		}
		ast.If {
			for i := 0; i < stmt.branches.len; i++ {
				branch := stmt.branches[i]

				if i == stmt.branches.len - 1 && stmt.has_else {
					g.write_tab("else ")
				}
				else {
					if i == 0 {
						g.write_tab("if ")
					}
					else {
						g.write_tab("else if ")
					}
					g.gen_expr(branch.cond)
				}
				g.write(" {")
				g.writeln("")
				g.indent_size++
				for t_stmt in branch.stmts {
					g.stmt(&t_stmt)
				}
				g.indent_size--
				g.writeln("")
				g.write_tab("}")
			}
		}
		ast.While {
			g.write_tab("for ")
			g.gen_expr(stmt.cond)
			g.write(" {")
			g.writeln("")
			g.indent_size++
			for t_stmt in stmt.stmts {
				g.stmt(&t_stmt)
			}
			g.indent_size--
			g.writeln("")
			g.write_tab("}")
		}
		ast.ExprStmt {
			g.write_tab("")
			g.gen_expr(stmt.expr)
		}
		ast.AssignStmt {
			g.write_tab("")
			g.gen_expr(stmt.left)
			g.write(" ")
			g.write(stmt.op.str())
			g.write(" ")
			g.gen_expr(stmt.right)
		}
		ast.VarDecl {
			g.write_tab("mut ")
			g.gen_expr(stmt.assign.left)
			g.write(" := ")
			g.gen_expr(stmt.assign.right)
		}
		ast.Comment {
			g.write_tab("/* ${stmt.text} */")
		}
	}
}