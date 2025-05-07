module ts_binding_client

import papyrus.ast
import strings
import gen.ts_binding_client.server_util as s_util

fn (mut g Gen) gen_server_main_ts_h_file() {
	g.server_ts_h.writeln(server_main_ts_h_file_start)

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		if sym.parent_idx == 0 {
			g.server_ts_h.writeln("\tclass ${sym.obj_name} {")
		}
		else {
			parent_obj_name := g.table.get_type_symbol(sym.parent_idx).name
			g.server_ts_h.writeln("\tclass ${sym.obj_name} extends ${parent_obj_name} {")
		}
		
		g.server_ts_h.writeln("\t\tstatic From(formId: number): ${sym.obj_name} | null")
		g.server_ts_h.writeln("")

		g.each_all_this_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl) {
			g.gen_server_ts_h_fn(sym, func)
		})

		g.server_ts_h.writeln("\t}")
		g.server_ts_h.writeln("")
	})

	g.server_ts_h.writeln(server_main_ts_h_file_end)
}

fn (mut g Gen) gen_server_ts_h_fn(sym &ast.TypeSymbol, func &ast.FnDecl) {
	mut temp_args := strings.new_builder(200)

	for i in 0..func.params.len {
		param := func.params[i]
		temp_args.write_string(param.name)
		if param.is_optional {
			temp_args.write_string("?: ")
		}
		else {
			temp_args.write_string(": ")
		}
		temp_args.write_string(s_util.get_ts_type_name(g.table, param.typ))

		if param.is_optional {
			// если есть комментарий с пояснением например `/*int*/`
			// то удаляем */ и продолжаем комментарий
			if temp_args.last_n(2) == "*/" {
				temp_args.go_back("*/".len) // remove last `*/`
			}
			else {
				temp_args.write_string("/*")
			}

			match param.default_value {
				ast.NoneLiteral {
					temp_args.write_string(" = null*/")
				}
				ast.IntegerLiteral {
					temp_args.write_string(" = ${param.default_value.val}*/")
				}
				ast.FloatLiteral {
					temp_args.write_string(" = ${param.default_value.val}*/")
				}
				ast.BoolLiteral {
					temp_args.write_string(" = ${param.default_value.val}*/")
				}
				ast.StringLiteral {
					temp_args.write_string(" = ${param.default_value.val}*/")
				}
				else {
					panic("invalid expr in param ${param}")
				}
			}
		}

		if i != func.params.len - 1 {
			temp_args.write_string(", ")
		}
	}

	if func.is_global {
		g.server_ts_h.writeln("\t\tstatic ${func.name}(${temp_args.str()}): ${s_util.get_ts_type_name(g.table, func.return_type)}")
	}
	else {
		g.server_ts_h.writeln("\t\t${func.name}(${temp_args.str()}): ${s_util.get_ts_type_name(g.table, func.return_type)}")
	}
}

const server_main_ts_h_file_start = 
"// !!! Generated automatically. Do not edit. !!!

declare global {
"

const server_main_ts_h_file_end = 
"}

export {};"