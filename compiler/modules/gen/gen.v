module gen

import papyrus.ast
import papyrus.table
import pex

struct TempVariable {
pub mut:
	typ		table.Type
	data	pex.VariableData
	free	bool
}

struct Gen {
pub mut:
	file	&ast.File = 0
	pex		&pex.PexFile = 0
	
	string_table	map[string]u16
	
	//текущая генерируемая функция
	cur_fn			&pex.Function = 0

	//массив временных переменных
	temp_locals		[]TempVariable

	table			&table.Table
	mod				string
}

pub fn gen(table &table.Table, file &ast.File) &pex.PexFile {
	mut g := Gen{
		file: file
		pex: &pex.PexFile{
			magic_number: 0xFA57C0DE
			major_version: 3
			minor_version: 2
			game_id: 1
			compilation_time: 1616248665
			
			src_file_name: file.path_base
			user_name: "Yurnero"
			machine_name: "DESKTOP-7NV0EKV"

			string_table: []string{}

			has_debug_info: 0

			user_flags: []pex.UserFlag{}
			objects: []pex.Object{}
		}

		table: table
		cur_fn: &pex.Function{}
	}
	
	g.gen_objects()
	return g.pex
}

fn (mut g Gen) gen_objects() {
	
	for stmt in g.file.stmts {
		match stmt {
			ast.ScriptDecl {
				g.script_decl(ast.ScriptDecl{...stmt})
			}
			ast.FnDecl {
				g.fn_decl(ast.FnDecl{...stmt})
			}
			ast.Comment {
				//skip
			}
		}
	}
	
	g.add_default_functions_to_state(mut &g.pex.objects[0].data.states[0])
}

fn (mut g Gen) stmt(stmt ast.Stmt) {
	match stmt {
		ast.Return {
			var_data := g.get_operand_from_expr(&stmt.expr)
			
			g.free_temp(var_data)

			g.cur_fn.info.instructions << pex.Instruction{
				op: byte(pex.OpCode.ret)
				args: [ var_data ]
			}
		}
		ast.If {
			g.if_stmt(stmt)
		}
		ast.While {
			g.while_stmt(stmt)
		}
		ast.ExprStmt {
			var_data := g.get_operand_from_expr(&stmt.expr)
			g.free_temp(var_data)
		}
		ast.AssignStmt {
			g.assign(stmt)
		}
		ast.VarDecl {
			g.var_decl(stmt)
		}
		ast.Comment {}
	}
}

[inline]
fn (mut g Gen) gen_string_ref(str string) u16 {
	
	mut index := u16(0)

	if str in g.string_table {
		return g.string_table[str]
	}
	else {
		index = g.pex.string_table_count

		g.pex.string_table_count++

		g.pex.string_table << str

		g.string_table[str] = index

		return index
	}
}

fn (mut g Gen) gen_default_state() pex.State {
	mut state := pex.State {
		name: g.gen_string_ref("")
		num_functions: 0
		functions: []pex.Function{}
	}

	return state
}

fn (mut g Gen) add_default_functions_to_state(mut state &pex.State) {

	//GetState
	state.functions << pex.Function{
		name: g.gen_string_ref("GetState")
		info: pex.FunctionInfo{
			return_type: g.gen_string_ref("String")
			docstring: g.gen_string_ref("Function that returns the current state")
			user_flags: 0
			flags: 0
			
			num_params: 0
			params: []pex.VariableType{}
			
			num_locals: 0
			locals: []pex.VariableType{}
			
			num_instructions: 1
			instructions: [
				pex.Instruction{
					op: byte(pex.OpCode.ret)			
					args: [
						pex.VariableData{
							typ: 1
							string_id: g.gen_string_ref("::State")
						}
					]
				}
			]
		}
	}

	//GotoState
	state.functions << pex.Function{
		name: g.gen_string_ref("GotoState")
		info: pex.FunctionInfo{
			return_type: g.gen_string_ref("None")
			docstring: g.gen_string_ref("Function that switches this object to the specified state")
			user_flags: 0
			flags: 0
			
			num_params: 1
			params: [
				pex.VariableType{
					typ: g.gen_string_ref("String")
					name: g.gen_string_ref("newState")
				}
			]
			
			num_locals: 1
			locals: [
				pex.VariableType{
					typ: g.gen_string_ref("None")
					name: g.gen_string_ref("::NoneVar")
				}
			]
			
			num_instructions: 3
			instructions: [
				pex.Instruction{
					op: byte(pex.OpCode.callmethod)			
					args: [
						pex.VariableData{
							typ: 1
							string_id: g.gen_string_ref("onEndState")
						},
						pex.VariableData{
							typ: 1
							string_id: g.gen_string_ref("self")
						},
						pex.VariableData{
							typ: 1
							string_id: g.gen_string_ref("::NoneVar")
						},
						pex.VariableData{
							typ: 3
							integer: 0
						}
					]
				},
				pex.Instruction{
					op: byte(pex.OpCode.assign)			
					args: [
						pex.VariableData{
							typ: 1
							string_id: g.gen_string_ref("::State")
						},
						pex.VariableData{
							typ: 1
							string_id: g.gen_string_ref("newState")
						}
					]
				},
				pex.Instruction{
					op: byte(pex.OpCode.callmethod)			
					args: [
						pex.VariableData{
							typ: 1
							string_id: g.gen_string_ref("onBeginState")
						},
						pex.VariableData{
							typ: 1
							string_id: g.gen_string_ref("self")
						},
						pex.VariableData{
							typ: 1
							string_id: g.gen_string_ref("::NoneVar")
						},
						pex.VariableData{
							typ: 3
							integer: 0
						}
					]
				},
			]
		}
	}

	//onEndState
	state.functions << pex.Function{
		name: g.gen_string_ref("onEndState")
		info: pex.FunctionInfo{
			return_type: g.gen_string_ref("None")
			docstring: g.gen_string_ref("Event received when this state is switched away from")
			user_flags: 0
			flags: 0
			
			num_params: 0
			params: []pex.VariableType{}
			
			num_locals: 0
			locals: []pex.VariableType{}
			
			num_instructions: 0
			instructions: []pex.Instruction{}
		}
	}

	//onBeginState
	state.functions << pex.Function{
		name: g.gen_string_ref("onBeginState")
		info: pex.FunctionInfo{
			return_type: g.gen_string_ref("None")
			docstring: g.gen_string_ref("Event received when this state is switched to")
			user_flags: 0
			flags: 0
			
			num_params: 0
			params: []pex.VariableType{}
			
			num_locals: 0
			locals: []pex.VariableType{}
			
			num_instructions: 0
			instructions: []pex.Instruction{}
		}
	}
	
	state.num_functions += 4
}