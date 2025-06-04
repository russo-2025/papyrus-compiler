module ts_binding

import papyrus.ast
import gen.ts_binding.client_util as c_util

fn (mut g Gen) gen_rpc_server_ts() {
	g.b_rpc_server_ts.writeln(b_rpc_server_ts_start)
	
	// ---------------------------------------------------
	
	g.each_files_fns(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File, func &ast.FnDecl) {
		assert func.is_native

		fn_name := c_util.get_real_impl_fn_name(sym.name, func.name)
		g.b_rpc_server_ts.write_string("\t\tfunction ${fn_name}(")

		g.b_rpc_server_ts.write_string("playerActor: Actor")

		g.b_rpc_server_ts.write_string(", ")
		
		if !func.is_global {
			g.b_rpc_server_ts.write_string("selfFormId: number/*formId*/")
			g.b_rpc_server_ts.write_string(", ")
		}

		//args
		for i in 0..func.params.len {
			param := func.params[i]
			param_sym := g.table.get_type_symbol(param.typ)
			
			g.b_rpc_server_ts.write_string(param.name)

			if param.is_optional {
				g.b_rpc_server_ts.write_string("?")
			}

			match param_sym.kind {
				.placeholder,
				.none_ {
					panic("invalid type in param ${sym.name}.${func.name}")
				}
				.bool {
					g.b_rpc_server_ts.write_string(": boolean")
				}
				.int {
					g.b_rpc_server_ts.write_string(": number/*int*/")
				}
				.float {
					g.b_rpc_server_ts.write_string(": number/*float*/")
				}
				.string {
					g.b_rpc_server_ts.write_string(": string")
				}
				.array {
					panic("TODO array support")
				}
				.script {
					g.b_rpc_server_ts.write_string(": number/*${param_sym.name}*/")
				}
			}

			if param.is_optional {
				// если есть комментарий с пояснением например `/*int*/`
				// то удаляем */ и продолжаем комментарий
				if g.b_rpc_server_ts.last_n(2) == "*/" {
					g.b_rpc_server_ts.go_back("*/".len) // remove last `*/`
				}
				else {
					g.b_rpc_server_ts.write_string("/*")
				}

				match param.default_value {
					ast.NoneLiteral {
						g.b_rpc_server_ts.write_string(" = null*/")
					}
					ast.IntegerLiteral {
						g.b_rpc_server_ts.write_string(" = ${param.default_value.val}*/")
					}
					ast.FloatLiteral {
						g.b_rpc_server_ts.write_string(" = ${param.default_value.val}*/")
					}
					ast.BoolLiteral {
						g.b_rpc_server_ts.write_string(" = ${param.default_value.val}*/")
					}
					ast.StringLiteral {
						g.b_rpc_server_ts.write_string(" = ${param.default_value.val}*/")
					}
					else {
						panic("invalid expr in param ${param}")
					}
				}
			}

			g.b_rpc_server_ts.write_string(", ")
		}

		//remove last ", "
		g.b_rpc_server_ts.go_back(", ".len)

		g.b_rpc_server_ts.writeln(") : void;")
	})
	
	// ---------------------------------------------------
	g.b_rpc_server_ts.writeln(b_rpc_server_ts_end)
}

const b_rpc_server_ts_start = 
"// !!! Generated automatically. Do not edit. !!!
/*
Ограничения:
- Не работают массивы
- Не работают дефолтные(опциональные) значения у объектов(Actor, Keyword...)
- Только локальные id и СВОЙ серверный(свой == playerActor)
- Нету возвращаемых значений
*/

declare global {
	namespace SpSnippet {"
	
const b_rpc_server_ts_end = 
"	}
}

export {};"