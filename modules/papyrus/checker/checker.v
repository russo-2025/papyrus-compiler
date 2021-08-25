module checker

import papyrus.ast
import pref
import papyrus.token
import papyrus.errors
import papyrus.util

[heap]
pub struct Checker {
	pref				&pref.Preferences
pub mut:
	table				&ast.Table
	file				&ast.File = 0
	errors				[]errors.Error
	warnings			[]errors.Warning

	inside_fn			bool
	inside_property		bool
	cur_fn				&ast.FnDecl = 0
	cur_scope			&ast.Scope = voidptr(0)
	cur_obj_name		string
	cur_parent_obj_name	string
	cur_obj				ast.Type
	cur_state_name		string

	temp_state_fns		map[string]bool
}

pub fn new_checker(table &ast.Table, pref &pref.Preferences) Checker {
	return Checker{
		table: table
		pref: pref
		cur_fn: 0
	}
}

pub fn (mut c Checker) check_files(ast_files []ast.File) {
	for i in 0 .. ast_files.len {
		file := unsafe { &ast_files[i] }
		c.check(file)
	}
}

pub fn (mut c Checker) check(ast_file &ast.File) {
	c.file = ast_file
	c.cur_scope = c.file.scope

	for stmt in ast_file.stmts {
		c.top_stmt(stmt)
	}
}

fn (mut c Checker) type_is_valid(typ ast.Type) bool {
	if typ == 0 {
		return false
	}

	if c.table.types[typ.idx()].kind == .placeholder {
		return false
	}

	return true
}

fn (mut c Checker) get_type_name(typ ast.Type) string {
	assert typ != 0

	return c.table.types[typ.idx()].name
}

//может ли тип t2 иметь значение с типом t1
pub fn (mut c Checker) valid_type(t1 ast.Type, t2 ast.Type) bool {
	if t1 == t2 {
		return true
	}

	s1 := c.table.get_type_symbol(t1)
	s2 := c.table.get_type_symbol(t2)

	if s1 == 0 || s2 == 0 {
		return false
	}
	
	match s2.kind {
		.script {
			if s1.kind == .none_ {
				return true
			}
		}
		else{}
	}

	return false
}

//можно ли кастануть тип t1 к типу t2
pub fn (mut c Checker) can_cast(t1 ast.Type, t2 ast.Type) bool {
	s1 := c.table.get_type_symbol(t1)
	s2 := c.table.get_type_symbol(t2)

	if s1 == 0 || s2 == 0 {
		return false
	}

	match s1.kind {
		.placeholder { panic("wtf") }
		.none_ {
			match s2.kind {
				.array,
				.script,
				.string,
				.bool { return true }
				else { return false }
			}
			return false
		}
		.int {
			match s2.kind {
				.float,
				.string,
				.bool { return true }
				else { return false}
			}
		}
		.float {
			match s2.kind {
				.int,
				.string,
				.bool { return true }
				else { return false}
			}
		}
		.string {
			match s2.kind {
				.int,
				.float,
				.bool { return true }
				else { return false}
			}
		}
		.bool {
			return true
		}
		.array {
			match s2.kind {
				.string,
				.bool { return true }
				else { return false}
			}
		}
		.script {
			match s2.kind {
				.string,
				.bool,
				.script { return true }
				else { return false}
			}
		}
	}

	return false
}

pub fn (mut c Checker) cast_to_type(node ast.Expr, from_type ast.Type, to_type ast.Type) &ast.Expr {
	if !c.can_cast(from_type, to_type) {
		type_name := c.get_type_name(from_type)
		to_type_name := c.get_type_name(to_type)
		c.error("cannot convert type `$type_name` to type `$to_type_name`",  node.pos)
	}

	new_node := ast.CastExpr {
		expr: node
		pos: node.pos
		type_name: c.get_type_name(to_type)
		typ: to_type
	}

	return &new_node
}

pub fn (mut c Checker) valid_infix_op_type(op token.Kind, typ ast.Type) bool {
	match op {
		.plus {
			match typ {
			 ast.string_type,
			 ast.float_type,
			 ast.int_type {
					return true
				}
				else {
					return false
				}
			}
		}
		.minus, .mul, .div, .gt, .lt, .ge, .le {
			match typ {
			 ast.float_type,
			 ast.int_type {
					return true
				}
				else {
					return false
				}
			}
		}
		.mod {
			if typ == ast.int_type {
				return true
			}
			else {
				return false
			}
		}
		.and, .logical_or, .eq, .ne {
			return true
		}
		else { panic("wtf") }
	}

	return false
}

pub fn (mut c Checker) find_fn(typ ast.Type, obj_name string, name string) ?ast.Fn {
	if typ > 0 {
		mut sym := c.table.get_type_symbol(typ)

		if sym.kind == .array {
			//int Function Find(;/element type/; akElement, int aiStartIndex = 0) native
			//int Function RFind(;/element type/; akElement, int aiStartIndex = -1) native
			
			lname := name.to_lower()
			if lname == "find" || lname == "rfind" {
				elem_type := (sym.info as ast.Array).elem_type
				
				return ast.Fn{
					params: [
						ast.Param{
							name: "value"
							typ: elem_type
							is_optional: false
							default_value: ""
						},
						ast.Param{
							name: "startIndex"
							typ: ast.int_type
							is_optional: true
							default_value: if lname == "find" { "0" } else { "-1" }
						}
					]
					return_type: ast.int_type
					obj_name: 'builtin'
					name: name
					sname: name.to_lower()
					is_static: false
				}
			}
		}

		for sym != 0 {
			if func := sym.find_method(name) {
				return func
			}
			
			if sym.parent_idx == 0 {
				break
			}

			sym = c.table.get_type_symbol(sym.parent_idx)
		}
	}

	if sym := c.table.find_type(obj_name) {
		if func := c.table.find_fn(obj_name, name) {
			return func
		}

		if func := sym.find_method(name) {
			return func
		}

		if name.to_lower() == 'getstate' {
			return ast.Fn{
				return_type: ast.string_type
				obj_name: c.cur_obj_name
				name: 'GetState'
				sname: 'getstate'
				is_static: false
			}
		}
		else if name.to_lower() == 'gotostate' {
			return ast.Fn{
				params: [
					ast.Param{
						name: "name"
						typ: ast.string_type
					}
				]
				return_type: ast.none_type
				obj_name: c.cur_obj_name
				name: 'GoToState'
				sname: 'gotostate'
				is_static: false
			}
		}
	}

	return none
}

[inline]
pub fn (c Checker) is_state() bool {
	return c.cur_state_name != token.default_state_name
}

pub fn (c Checker) warn(message string, pos token.Position) {
	eprintln("Checker warning: " + message)
}

pub fn (mut c Checker) error(message string, pos token.Position) {
	ferror := util.formatted_error('Checker error:', message, c.file.path, pos)
	eprintln(ferror)
	c.errors << errors.Error {
		message: message
		details: message
		file_path: c.file.path
		pos: pos
		backtrace: ""
		reporter:  errors.Reporter.checker
	}	
}