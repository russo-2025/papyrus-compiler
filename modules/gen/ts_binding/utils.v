module ts_binding

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

fn (mut g Gen) each_files_fns(cb fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File, func &ast.FnDecl)) {
	for key, file in g.file_by_name {
		sym := g.table.find_type(key) or { panic("TypeSymbol not found `${key}`") }
		
		for stmt in file.stmts {
			match stmt {
				ast.Comment {}
				ast.ScriptDecl {}
				ast.FnDecl {
					cb(mut g, sym, file, stmt)
				}
				else { panic("invalid top stmt ${stmt}") }
			}
		}
	}
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

fn (mut g Gen) each_all_types(cb fn(mut g Gen, idx ast.Type, sym &ast.TypeSymbol)) {
	for idx, sym in g.table.types {
		cb(mut g, idx, sym)
	}
}

fn (mut g Gen) each_all_child(idx ast.Type, cb fn(mut g Gen, idx ast.Type, sym &ast.TypeSymbol)) {
	for parent_idx in g.parents_of_objects[idx].keys() {
		cb(mut g, parent_idx, g.table.get_type_symbol(parent_idx))
	}
}

fn (mut g Gen) each_all_parent(sym &ast.TypeSymbol, cb fn(mut g Gen, file &ast.File, idx ast.Type, sym &ast.TypeSymbol)) {
	mut cur_idx := sym.parent_idx
	for {
		if cur_idx == 0 {
			break
		}

		t_sym := g.table.get_type_symbol(cur_idx)
		t_name := t_sym.name
		t_file := g.file_by_name[t_name.to_lower()] or { panic("file not found `${t_name}`") }

		cb(mut g, t_file, cur_idx, t_sym)
		
		cur_idx = t_sym.parent_idx
	}
}

fn (mut g Gen) each_all_parent_fns(sym &ast.TypeSymbol, cb fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl)) {
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