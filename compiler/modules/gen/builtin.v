module gen

import papyrus.ast
import papyrus.table
import os


struct BuiltinGen {
pub mut:
	file	os.File

	table	&table.Table
	cur_mod_name			string
	cur_mod_parent_name		string
	cur_type				table.Type
	cur_parent_type			table.Type

	types_text		string
	methods_text	string
}


pub fn gen_builtin_module(path string, table &table.Table, parser_files []ast.File) {
	mut file := os.create(path + "\\builtin_fns.v") or { panic(err) }

	mut b := BuiltinGen{
		file: file
		table: table
	}
	
	mut i := 11
	for i < b.table.types.len {
		b.write_builtin_type(i, b.table.types[i])
		i++
	}

	for pfile in parser_files {
		for stmt in pfile.stmts {
			match stmt {
				ast.FnDecl {
					b.write_builtin_fn(stmt)
				}
				ast.ScriptDecl {
					b.cur_mod_name = stmt.name
					b.cur_mod_parent_name = stmt.parent_name

					b.cur_type = 0
					b.cur_parent_type = 0
					
					b.cur_type = b.table.find_type_idx(stmt.name)
					b.cur_parent_type = b.table.find_type_idx(stmt.parent_name)
				}
				ast.Comment {}
			}
		}
	}
	
	b.writeln("module table")
	b.writeln("")

	b.writeln("pub fn (mut t Table) register_builtin_papyrus_types() {")
	b.writeln(b.types_text)
	b.writeln("}")

	b.writeln("")
	b.writeln("pub fn (mut t Table) register_builtin_papyrus_functions() {")
	b.writeln(b.methods_text)
	b.writeln("}")

	file.close()
}

fn get_table_kind_str(kind table.Kind) string {
	return match kind {
		.placeholder { '.placeholder' }
		.none_ { '.none_' }
		.int { '.int' }
		.float { '.float' }
		.string { '.string.' }
		.bool { '.bool' }
		.array { '.array' }
		.script { '.script' }
	}
}

fn (mut b BuiltinGen) write_builtin_type(index int, t &table.TypeSymbol) {
	b.t_writeln("	t.register_module('$t.mod')")
	b.t_writeln("	t.register_type_symbol({ //$index")
	b.t_writeln("		parent_idx: ${t.parent_idx.str()}")
	b.t_writeln("		kind: ${get_table_kind_str(t.kind)}")
	match t.info {
		table.Array {
			b.t_writeln("		info: Array{ elem_type: $t.info.elem_type }")
		}
		table.EmptyInfo {}
	}
	b.t_writeln("		name: '$t.name'")
	b.t_writeln("		mod: '$t.mod'")
	b.t_writeln("	})")
}

//нужен для генератора builtin файла
fn type_to_str(typ table.Type) string{
	return match typ {
		table.none_type_idx { "none_type" }
		table.int_type_idx { "int_type" }
		table.float_type_idx { "float_type" }
		table.string_type_idx { "string_type" }
		table.bool_type_idx { "bool_type" }
		table.array_type_idx { "array_type" }
		else { typ.str() }
	}
}

fn (mut b BuiltinGen) write_builtin_fn(n &ast.FnDecl) {
	
	if n.is_static {
		b.m_writeln("	t.register_fn(Fn{")
	}
	else {
		b.m_writeln("	t.types[${type_to_str(b.cur_type)}].register_method(Fn{")
	}

	b.m_writeln("		params: [")
	mut i := 0
	for i < n.params.len {
		param :=  n.params[i]
		
		b.m_writeln("			Param{")
		b.m_writeln("				name: '$param.name'")
		b.m_writeln("				typ: ${type_to_str(param.typ)}")
		if param.is_optional { b.m_writeln("				is_optional: true") }
		else { b.m_writeln("				is_optional: false") }
		b.m_writeln("				default_value: '$param.default_value'")

		if i < n.params.len - 1 {
			b.m_writeln("			},")
		}
		else {
			b.m_writeln("			}")
		}

		i++
	}

	b.m_writeln("		]")
	b.m_writeln("		return_type: ${type_to_str(n.return_type)}")

	b.m_writeln("		mod: '$b.cur_mod_name'")
	b.m_writeln("		name: '$n.name'")
	b.m_writeln("		sname: '${n.name.to_lower()}'")

	if n.is_static { b.m_writeln("		is_static: true") }
	else { b.m_writeln("		is_static: false") }

	b.m_writeln("	})")
}

fn (mut b BuiltinGen) m_writeln(str string) {
	b.methods_text += "\n" + str 
}

fn (mut b BuiltinGen) t_writeln(str string) {
	b.types_text += "\n" + str 
}

fn (mut b BuiltinGen) writeln(str string) {
	b.file.writeln(str) or { panic(err) }
}
