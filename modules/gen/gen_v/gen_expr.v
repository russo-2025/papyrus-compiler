module gen_v

import papyrus.ast

fn (mut g Gen) gen_expr(expr &ast.Expr) {
	match expr {
		ast.InfixExpr {
			g.gen_expr(expr.left)
			g.write(" ")
			g.write(expr.op.str())
			g.write(" ")
			g.gen_expr(expr.right)
		}
		ast.ParExpr {
			g.write("(")
			g.gen_expr(expr.expr)
			g.write(")")
		}
		ast.CallExpr {
			if expr.is_array_find {
				g.write("/* <TODO CallExpr array find> */")
			}
			else if expr.is_global {
				g.write("${g.get_global_fn_name(expr.obj_name, expr.name)}")
				g.write("(")

				for i := 0; i < expr.args.len; i++ {
					arg := expr.args[i]
					g.gen_expr(arg.expr)

					if i != expr.args.len - 1 {
						g.write(", ")
					}
				}

				g.write(")")
			}
			else {
				if expr.left is ast.EmptyExpr {
					g.write("self")
				}
				else {
					g.gen_expr(expr.left)
				}
				g.write(".")
				g.write("${g.get_method_name(expr.name)}")
				g.write("(")

				for i := 0; i < expr.args.len; i++ {
					arg := expr.args[i]
					g.gen_expr(arg.expr)

					if i != expr.args.len - 1 {
						g.write(", ")
					}
				}

				g.write(")")
			}
		}
		ast.PrefixExpr {
			g.write(expr.op.str())
			g.gen_expr(expr.right)
		}
		ast.Ident {
			if expr.is_object_property || expr.is_object_var {
				g.write("self.")
				g.write(g.get_object_var_prop_name(expr.name))
				return
			}

			g.write(expr.name)
		}
		ast.NoneLiteral {
			g.write("voidptr(0)")
		}
		ast.IntegerLiteral {
			g.write(expr.val)
		}
		ast.FloatLiteral {
			g.write(expr.val)
		}
		ast.BoolLiteral {
			g.write(expr.val.to_lower())
		}
		ast.StringLiteral {
			g.write("\"${expr.val}\"")
		}
		ast.ArrayInit {
			g.write("[]")
			g.write(g.get_type_name(expr.elem_type))
			g.write("{ len: ")
			g.gen_expr(expr.len)
			g.write("}")
		}
		ast.SelectorExpr {
			g.gen_expr(expr.expr)
			g.write(".")
			g.write(g.get_object_var_prop_name(expr.field_name))
		}
		ast.IndexExpr {
			g.gen_expr(expr.left)
			g.write("[")
			g.gen_expr(expr.index)
			g.write("]")
		}
		ast.CastExpr {
			to_sym := g.table.get_type_symbol(expr.typ)
			to_type_name := g.get_type_name(expr.typ)
			from_type_name := g.get_type_name(expr.expr_typ)
			
			match to_sym.kind {
				.placeholder { panic("wtf") }
				.none_ { panic("wtf") }
				.int,
				.float,
				.bool {
					g.write(to_type_name)
					g.write("(")
					g.gen_expr(expr.expr)
					g.write(")")
				}
				.string {
					g.write("/* <TODO CastExpr (to string)> */")
				}
				.array { panic("wtf") }
				.script {
					if expr.expr_typ == ast.none_type {
						g.gen_expr(expr.expr)
						return
					}

					g.write("cast_object[${from_type_name}, ${to_type_name}](")
					g.gen_expr(expr.expr)
					g.write(")")
				}
			}
		}
		ast.EmptyExpr {
			panic("wtf")
		}
	}
}