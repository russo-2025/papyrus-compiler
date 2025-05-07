module ts_binding_server

import papyrus.ast

fn (mut g Gen) each_all_files(cb fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File)) {
	for key, file in g.file_by_name {
		sym := g.table.find_type(key) or { panic("TypeSymbol not found `${key}`") }
		
		cb(mut g, sym, file)
	}
}

// this and parents
fn (mut g Gen) each_all_fns(sym &ast.TypeSymbol, cb fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl)) {
	g.each_all_this_fns(sym, cb)
	g.each_all_parent_fns(sym, cb)
}

fn (mut g Gen) each_all_this_fns(sym &ast.TypeSymbol, cb fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl)) {
	obj_name := sym.obj_name
	file := g.file_by_name[obj_name.to_lower()] or { panic("file not found `${obj_name}`") }
	
	for stmt in file.stmts {
		match stmt {
			ast.Comment {}
			ast.ScriptDecl {}
			ast.FnDecl {
				cb(mut g, sym, stmt)
			}
			else { panic("invalid top stmt ${stmt}") }
		}
	}
}

fn (mut g Gen) each_all_parent_fns(sym &ast.TypeSymbol, cb fn(mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl)) {
	mut cur_idx := sym.parent_idx
	for {
		if cur_idx == 0 {
			break
		}

		t_sym := g.table.get_type_symbol(cur_idx)
		t_name := t_sym.name
		t_file := g.file_by_name[t_name.to_lower()] or { panic("file not found `${t_name}`") }

		for stmt in t_file.stmts {
			match stmt {
				ast.Comment {}
				ast.ScriptDecl {}
				ast.FnDecl {
					cb(mut g, t_sym, stmt)
				}
				else { panic("invalid top stmt ${stmt}") }
			}
		}
		
		cur_idx = t_sym.parent_idx
	}
}