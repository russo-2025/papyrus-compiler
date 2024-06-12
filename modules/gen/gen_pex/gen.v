module gen_pex

import papyrus.ast
import pex
import pref

import os
import time

struct TempVariable {
pub mut:
	typ		ast.Type
	value	pex.VariableValue
	free	bool
}

struct Gen {
	pref			&pref.Preferences
pub mut:
	file			&ast.File = unsafe{ voidptr(0) }
	pex				&pex.PexFile = unsafe{ voidptr(0) }
	
	string_table	map[string]u16
	
	temp_locals		[]TempVariable //массив временных переменных

	table			&ast.Table
	
	cur_obj			&pex.Object = unsafe{ voidptr(0) }
	cur_state		&pex.State = unsafe{ voidptr(0) }
	cur_fn			&pex.Function = unsafe{ voidptr(0) }

	states			map[string]&pex.State
	empty_state		&pex.State = unsafe{ voidptr(0) }

	cur_obj_type	ast.Type
	cur_obj_name	string
}

pub fn gen_pex_file(mut file &ast.File, mut table &ast.Table, prefs &pref.Preferences) &pex.PexFile {
	mut g := Gen{
		file: file
		pex: &pex.PexFile{
			magic_number: pex.le_magic_number //0xFA57C0DE
			major_version: 3
			minor_version: 2
			game_id: .skyrim
			compilation_time: time.utc().unix()
			src_file_name: file.path_base
			user_name: os.loginname() or { "::USERNAME::" }
			machine_name: os.hostname() or { "::MACHINENAME::" }

			has_debug_info: u8(1) //debug info обязательна?!
			modification_time: i64(1616261626) //TODO
		}

		table: table
		pref: prefs
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

fn (mut g Gen) stmt(mut stmt &ast.Stmt) {
	match mut stmt {
		ast.Return {
			value := g.get_operand_from_expr(mut &stmt.expr)
			
			g.free_temp(value)

			g.cur_fn.info.instructions << pex.Instruction{
				op: pex.OpCode.ret
				args: [ value ]
			}
		}
		ast.If {
			g.if_stmt(mut stmt)
		}
		ast.While {
			g.while_stmt(mut stmt)
		}
		ast.ExprStmt {
			value := g.get_operand_from_expr(mut &stmt.expr)
			g.free_temp(value)
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

@[inline]
fn (mut g Gen) gen_string_ref(str string) u16 {
	if str in g.string_table {
		return g.string_table[str]
	}
	else {
		index := pex.cast_int_to_u16(g.pex.string_table.len)

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
		auto_state_name: g.gen_string_ref(pex.empty_state_name)
		
		variables: []&pex.Variable{}
		properties: []&pex.Property{}
		states: []&pex.State{}
	}
}

fn (mut g Gen) create_state(name string) &pex.State {
	return &pex.State {
		name: g.gen_string_ref(name)
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
			
			params: []pex.VariableType{}
			locals: []pex.VariableType{}
			instructions: [
				pex.Instruction{
					op: pex.OpCode.ret			
					args: [
						pex.value_ident(g.gen_string_ref("::State"))
					]
				}
			]
		}
	}

	g.pex.functions << pex.DebugFunction{
		object_name: g.cur_obj.name
		state_name: g.cur_state.name
		function_name: g.gen_string_ref("GetState")
		function_type: 0 // TODO выяснить что это
		instruction_line_numbers: []u16{}
	}
	
	//GotoState
	state.functions << &pex.Function{
		name: g.gen_string_ref("GotoState")
		info: pex.FunctionInfo{
			return_type: g.gen_string_ref("None")
			docstring: g.gen_string_ref("Function that switches this object to the specified state")
			user_flags: 0
			flags: 0
			
			params: [
				pex.VariableType{
					typ: g.gen_string_ref("String")
					name: g.gen_string_ref("newState")
				}
			]
			
			locals: [
				pex.VariableType{
					typ: g.gen_string_ref("None")
					name: g.gen_string_ref("::NoneVar")
				}
			]
			
			instructions: [
				pex.Instruction{
					op: pex.OpCode.callmethod
					args: [
						pex.value_ident(g.gen_string_ref("onEndState")),
						pex.value_ident(g.gen_string_ref("self")),
						pex.value_ident(g.gen_string_ref("::NoneVar")),
						pex.value_integer(0)
					]
				},
				pex.Instruction{
					op: pex.OpCode.assign	
					args: [
						pex.value_ident(g.gen_string_ref("::State")),
						pex.value_ident(g.gen_string_ref("newState"))
					]
				},
				pex.Instruction{
					op: pex.OpCode.callmethod	
					args: [
						pex.value_ident(g.gen_string_ref("onBeginState")),
						pex.value_ident(g.gen_string_ref("self")),
						pex.value_ident(g.gen_string_ref("::NoneVar")),
						pex.value_integer(0)
					]
				},
			]
		}
	}

	g.pex.functions << pex.DebugFunction{
		object_name: g.cur_obj.name
		state_name: g.cur_state.name
		function_name: g.gen_string_ref("GotoState")
		function_type: 0 // TODO выяснить что это
		instruction_line_numbers: []u16{}
	}
	
	sym := g.table.get_type_symbol(g.cur_obj_type)
	if sym.parent_idx == 0 {
	
	//onEndState
		state.functions << &pex.Function{
			name: g.gen_string_ref("onEndState")
			info: pex.FunctionInfo{
				return_type: g.gen_string_ref("None")
				docstring: g.gen_string_ref("Event received when this state is switched away from")
				user_flags: 0
				flags: 0
				
				params: []pex.VariableType{}
				locals: []pex.VariableType{}
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
				
				params: []pex.VariableType{}
				locals: []pex.VariableType{}
				instructions: []pex.Instruction{}
			}
		}
	}
}