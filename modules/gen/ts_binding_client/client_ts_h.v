module ts_binding_client

import papyrus.ast
import gen.ts_binding_client.client_util as c_util
import strings

fn (mut g Gen) gen_client_ts_h_file() {
	g.b_main_client_ts.writeln(client_ts_start_file)

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		obj_type := g.table.find_type_idx(sym.name)

		if sym.parent_idx == 0 {
			g.b_main_client_ts.writeln("\tclass ${sym.name} {")
		}
		else {
			parent_obj_name := g.table.get_type_symbol(sym.parent_idx).name
			g.b_main_client_ts.writeln("\tclass ${sym.name} extends ${parent_obj_name} {")
		}
		
		if !c_util.is_no_instance_class(g.no_instance_class, obj_type){
			g.b_main_client_ts.writeln("\t\tstatic From(formId: number): ${sym.name} | null")
			g.b_main_client_ts.writeln("\t\tAs<T>(object: any): T | null")
			g.b_main_client_ts.writeln("")
		}

		g.each_all_this_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl) {
			g.gen_ts_h_fn(sym, sym, func)
		})

		g.b_main_client_ts.writeln("\t}")
		g.b_main_client_ts.writeln("")
	})

	g.b_main_client_ts.writeln(client_ts_end_file)
}

fn (mut g Gen) gen_ts_h_fn(sym &ast.TypeSymbol, parent_sym &ast.TypeSymbol, func &ast.FnDecl) {
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
		temp_args.write_string(c_util.get_ts_type_name(g.table, param.typ))

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
					panic("invalid expr in param")
				}
			}
		}
		
		if i != func.params.len - 1 {
			temp_args.write_string(", ")
		}
	}

	if func.is_global {
		g.b_main_client_ts.writeln("\t\tstatic ${func.name}(${temp_args.str()}): ${c_util.get_ts_type_name(g.table, func.return_type)}")
	}
	else {
		g.b_main_client_ts.writeln("\t\t${func.name}(${temp_args.str()}): ${c_util.get_ts_type_name(g.table, func.return_type)}")
	}
}

const client_ts_start_file = 
"// !!! Generated automatically. Do not edit. !!!

declare global {
"

const client_ts_end_file = "}

export {};"