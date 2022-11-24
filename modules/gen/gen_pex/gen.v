module gen_pex

import papyrus.ast
import pex
import pref

import os
import time

struct TempVariable {
pub mut:
	typ		ast.Type
	data	pex.VariableData
	free	bool
}

struct Gen {
pub mut:
	file	&ast.File = unsafe{ 0 }
	pex		&pex.PexFile = unsafe{ 0 }
	
	string_table	map[string]u16
	
	temp_locals		[]TempVariable //массив временных переменных

	table			&ast.Table
	pref			&pref.Preferences
	
	cur_obj			&pex.Object = unsafe{ 0 }
	cur_state		&pex.State = unsafe{ 0 }
	cur_fn			&pex.Function = unsafe{ 0 }

	default_state	&pex.State = unsafe{ 0 }

	cur_obj_name	string
}

pub fn gen(file &ast.File, output_file_path string, table &ast.Table, pref &pref.Preferences) {
	mut g := Gen{
		file: file
		pex: &pex.PexFile{
			magic_number: 0xFA57C0DE
			major_version: 3
			minor_version: 2
			game_id: 1
			compilation_time: time.utc().unix_time()
			src_file_name: file.path_base
			user_name: os.loginname()
			machine_name: os.hostname()
		}

		table: table
		pref: pref
	}
	
	g.gen_objects()

	pex.write_to_file(g.pex, output_file_path)
}

pub fn gen_pex_file(file &ast.File, table &ast.Table, pref &pref.Preferences) &pex.PexFile {
	mut g := Gen{
		file: file
		pex: &pex.PexFile{
			magic_number: 0xFA57C0DE
			major_version: 3
			minor_version: 2
			game_id: 1
			compilation_time: time.utc().unix_time()
			src_file_name: file.path_base
			user_name: os.loginname()
			machine_name: os.hostname()

			has_debug_info: byte(1) //debug info обязательна?!
			modification_time: i64(1616261626) //TODO
		}

		table: table
		pref: pref
	}
	
	g.gen_objects()
	return g.pex
}

fn (mut g Gen) gen_objects() {
	for mut stmt in g.file.stmts {
		match mut stmt {
			ast.ScriptDecl {
				g.script_decl(mut stmt)
			}
			ast.StateDecl {
				g.state_decl(mut stmt)
			}
			ast.FnDecl {
				g.fn_decl(mut stmt)
			}
			ast.VarDecl {
				g.var_decl(mut stmt)
			}
			ast.PropertyDecl {
				g.prop_decl(mut stmt)
			}
			ast.Comment {
				//skip
			}
		}
	}
}

fn (mut g Gen) stmt(mut stmt ast.Stmt) {
	match mut stmt {
		ast.Return {
			var_data := g.get_operand_from_expr(mut &stmt.expr)
			
			g.free_temp(var_data)

			g.cur_fn.info.instructions << pex.Instruction{
				op: pex.OpCode.ret
				args: [ var_data ]
			}
		}
		ast.If {
			g.if_stmt(mut stmt)
		}
		ast.While {
			g.while_stmt(mut stmt)
		}
		ast.ExprStmt {
			var_data := g.get_operand_from_expr(mut &stmt.expr)
			g.free_temp(var_data)
		}
		ast.AssignStmt {
			g.assign(mut stmt)
		}
		ast.VarDecl {
			g.var_decl(mut stmt)
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

fn (mut g Gen) create_obj(name string, parent_name string) &pex.Object {
	return &pex.Object {
		name: g.gen_string_ref(name)
		size: 0
		parent_class_name: g.gen_string_ref(parent_name)
		docstring: g.gen_string_ref("")
		user_flags: 0
		default_state_name: g.gen_string_ref(pex.default_state_name)
		
		num_variables: 0
		variables: []&pex.Variable{}
		
		num_properties: 0
		properties: []&pex.Property{}
		
		num_states: 0
		states: []&pex.State{}
	}
}

fn (mut g Gen) create_state(name string) &pex.State {
	return &pex.State {
		name: g.gen_string_ref(name)
		num_functions: 0
		functions: []&pex.Function{}
	}
}

fn (mut g Gen) add_default_functions_to_state(mut state &pex.State) {
	//GetState
	state.functions << &pex.Function{
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
					op: pex.OpCode.ret			
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
	state.functions << &pex.Function{
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
					op: pex.OpCode.callmethod
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
					op: pex.OpCode.assign	
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
					op: pex.OpCode.callmethod	
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
	state.functions << &pex.Function{
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
	state.functions << &pex.Function{
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