module gen_v_wrapper

import papyrus.ast

fn (mut g Gen) gen_global_fn(func &ast.FnDecl) {
	fn_name := g.get_global_fn_name(g.cur_obj_name, func.name)
	return_type := if func.return_type == ast.none_type { "" } else { g.get_type_name(func.return_type) }

	g.write("pub fn ${fn_name}(")
	g.gen_fn_args(func)
	g.write(") ${return_type} {")
	g.writeln("")
	g.indent_size++

	for i in 0..func.stmts.len {
		stmt := func.stmts[i]
		g.stmt(&stmt)
		if i < func.stmts.len - 1 {
			g.writeln("")
		}
	}

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

	for i in 0..func.stmts.len {
		stmt := func.stmts[i]
		g.stmt(&stmt)
		if i < func.stmts.len - 1 {
			g.writeln("")
		}
	}

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