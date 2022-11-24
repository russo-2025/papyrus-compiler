module checker

import papyrus.ast
import pref
import papyrus.token
import papyrus.errors
import papyrus.util
import pex

[heap]
pub struct Checker {
	pref				&pref.Preferences
pub mut:
	table				&ast.Table
	file				&ast.File = unsafe { voidptr(0) }
	errors				[]errors.Error
	warnings			[]errors.Warning

	inside_fn			bool
	inside_property		bool
	auto_state_is_exist	bool
	cur_fn				&ast.FnDecl = unsafe { voidptr(0) }
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

pub fn (mut c Checker) check_files(mut ast_files []ast.File) {
	for i in 0 .. ast_files.len {
		mut file := unsafe { &ast_files[i] }
		c.check(mut file)
	}
}

pub fn (mut c Checker) check(mut ast_file &ast.File) {
	c.file = ast_file
	c.cur_scope = c.file.scope

	for mut stmt in ast_file.stmts {
		c.top_stmt(mut stmt)
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

[inline]
fn (c Checker) get_type_kind(typ ast.Type) ast.Kind {
	return c.table.get_type_symbol(typ).kind
}

[inline]
fn (c Checker) get_type_name(typ ast.Type) string {
	return c.table.get_type_symbol(typ).name
}

//может ли тип t2 иметь значение с типом t1
pub fn (mut c Checker) valid_type(t1 ast.Type, t2 ast.Type) bool {
	if t1 == t2 {
		return true
	}

	s1 := c.table.get_type_symbol(t1)
	s2 := c.table.get_type_symbol(t2)

	if isnil(s1) || isnil(s2) {
		return false
	}
	
	match s1.kind {
		.array,
		.script {
			if s2.kind == .none_ {
				return true
			}
		}
		else{}
	}

	return false
}

//можно ли кастануть тип from_type к типу to_type
pub fn (mut c Checker) can_cast(from_type ast.Type, to_type ast.Type) bool {
	assert !c.valid_type(to_type, from_type)

	from_sym := c.table.get_type_symbol(from_type)
	to_sym := c.table.get_type_symbol(to_type)

	if isnil(from_sym) || isnil(to_sym) {
		return false
	}

	match from_sym.kind {
		.placeholder { panic("wtf") }
		.none_ {
			match to_sym.kind {
				.array,
				.script,
				.string,
				.bool { return true }
				else { return false }
			}
			return false
		}
		.int {
			match to_sym.kind {
				.float,
				.string,
				.bool { return true }
				else { return false}
			}
		}
		.float {
			match to_sym.kind {
				.int,
				.string,
				.bool { return true }
				else { return false}
			}
		}
		.string {
			match to_sym.kind {
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
			match to_sym.kind {
				.string,
				.bool { return true }
				else { return false}
			}
		}
		.script {
			match to_sym.kind {
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
		c.error("cannot cast type `$type_name` to type `$to_type_name`", node.pos)
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

pub fn (mut c Checker) find_fn(a_typ ast.Type, obj_name string, name string) ?ast.Fn {
	mut typ := a_typ

	if typ == 0 {
		typ = c.table.find_type_idx(obj_name)
	}

	if func := c.table.find_fn(obj_name, name) {
		return func
	}

	if typ == 0 {
		return none
	}
	
	mut sym := c.table.get_type_symbol(typ)

	mut tsym := sym
	for {
		if func := tsym.find_method(name) {
			return func
		}

		if tsym.parent_idx > 0 {
			tsym = c.table.get_type_symbol(tsym.parent_idx)
			continue
		}

		break
	}

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
				lname: name.to_lower()
				is_global: false
			}
		}
	}
	
	if name.to_lower() == 'getstate' {
		return ast.Fn{
			return_type: ast.string_type
			obj_name: c.cur_obj_name
			name: 'GetState'
			lname: 'getstate'
			is_global: false
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
			lname: 'gotostate'
			is_global: false
		}
	}
	
	return none
}

[inline]
pub fn (mut c Checker) get_default_value(typ ast.Type) ast.Expr {
	match c.get_type_kind(typ) {
		.int {
			return ast.IntegerLiteral{ val: "0" }
		}
		.float {
			return ast.FloatLiteral{ val: "0.0" }
		}
		.string {
			return ast.StringLiteral{ val: "" }
		}
		.bool {
			return ast.BoolLiteral{ val: "False" }
		}
		.array,
		.script {
			return ast.NoneLiteral{ val: "None" }
		}
		.none_,
		.placeholder {
			panic("invalid typ")
		}
	}
}

[inline]
pub fn (c Checker) is_empty_state() bool {
	return c.cur_state_name == pex.empty_state_name
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