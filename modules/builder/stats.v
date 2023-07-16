module builder

import os
import strings
import papyrus.ast

struct FnInfo {
pub mut:
	name		string
	obj_name	string
	count		u32
}

struct Stats {
pub mut:
	count_objects				u32

	count_all_methods			u32
	count_native_methods		u32

	count_all_static_fns		u32
	count_native_static_fns		u32

	call_info					map[string]FnInfo
}

fn (mut s Stats) from_table(table &ast.Table) {
	for sym in table.types {
		if sym.kind == .script {
			s.count_objects++
		}

		for method in sym.methods {
			if method.is_native {
				s.count_native_methods++
			}

			s.count_all_methods++
		}
	}

	for _, func in table.fns {
		if func.is_native {
			s.count_native_static_fns++
		}
	}	

	s.count_all_static_fns = u32(table.fns.len)
}

fn (mut s Stats) from_files(parsed_files []ast.File) {
	for file in parsed_files {
		for stmt in file.stmts {
			s.from_top_stmt(stmt)
		}
	}
}

fn (mut s Stats) from_top_stmt(stmt ast.TopStmt) {
	match stmt {
		ast.ScriptDecl {}
		ast.FnDecl {
			for fstmt in stmt.stmts {
				s.from_stmt(fstmt)
			}
		}
		ast.Comment {}
		ast.PropertyDecl {}
		ast.VarDecl {}
		ast.StateDecl {
			for func in stmt.fns {
				s.from_top_stmt(func)
			}
		}
	}
}

fn (mut s Stats) from_stmt(stmt ast.Stmt) {
	match stmt {
		ast.Return { s.from_expr(stmt.expr) }
		ast.If {
			for branch in stmt.branches {
				s.from_expr(branch.cond)

				for bstmt in branch.stmts {
					s.from_stmt(bstmt)
				}
			}
		}
		ast.While {
			s.from_expr(stmt.cond)

			for wstmt in stmt.stmts {
				s.from_stmt(wstmt)
			}
		}
		ast.ExprStmt { s.from_expr(stmt.expr) }
		ast.AssignStmt { s.from_expr(stmt.right) }
		ast.VarDecl { s.from_expr(stmt.assign.right) }
		ast.Comment {}
	}
}

fn (mut s Stats) from_expr(expr ast.Expr) {
	match expr {
		ast.InfixExpr {
			s.from_expr(expr.left)
			s.from_expr(expr.right)
		}
		ast.IntegerLiteral {}
		ast.FloatLiteral {}
		ast.BoolLiteral {}
		ast.StringLiteral {}
		ast.Ident {}
		ast.CallExpr {
			key := expr.obj_name.to_lower() + "." + expr.name.to_lower()

			if key in s.call_info {
				mut fn_call_info := s.call_info[key]
				fn_call_info.count++
				s.call_info[key] = fn_call_info
			}
			else {
				s.call_info[key] = FnInfo{
					obj_name: expr.obj_name
					name: expr.name
					count: 1
				}
			}
		}
		ast.SelectorExpr { s.from_expr(expr.expr) }
		ast.IndexExpr { 
			s.from_expr(expr.left)
			s.from_expr(expr.index)
		}
		ast.ParExpr { s.from_expr(expr.expr) }
		ast.PrefixExpr { s.from_expr(expr.right) }
		ast.EmptyExpr {}
		ast.ArrayInit { s.from_expr(expr.len) }
		ast.NoneLiteral {}
		ast.CastExpr { s.from_expr(expr.expr) }
	}
}

fn (s Stats) save() {
	mut b := strings.new_builder(100)
	b.writeln("count objects: ${s.count_objects}")
	b.writeln("count all static fns: ${s.count_all_static_fns}")
	b.writeln("count native static fns: ${s.count_native_static_fns}")
	b.writeln("count all methods: ${s.count_all_methods}")
	b.writeln("count native methods: ${s.count_native_methods}")
	os.write_file("stats.md", b.str()) or { panic(err) }

	b = strings.new_builder(100)
	b.writeln("| name | count |")
	b.writeln("|---|------|")

	for key, value in s.call_info {
		b.writeln("| ${key} | ${value.count} | ")
	}
	
	os.write_file("stats_call.md", b.str()) or { panic(err) }
}