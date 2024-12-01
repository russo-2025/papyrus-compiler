module checker

import papyrus.ast
import pref
import papyrus.token
import papyrus.errors
import papyrus.util
import pex

@[heap]
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
	cur_scope			&ast.Scope = unsafe { voidptr(0) }
	cur_obj_name		string
	cur_parent_obj_name	string
	cur_obj				ast.Type
	cur_state_name		string
}

pub fn new_checker(table &ast.Table, prefs &pref.Preferences) Checker {
	return Checker{
		table: table
		pref: prefs
	}
}

pub fn (mut c Checker) check_files(mut ast_files []&ast.File) {
	for i in 0 .. ast_files.len {
		mut file := ast_files[i]
		c.check(mut file)
	}
}

pub fn (mut c Checker) check(mut ast_file ast.File) {
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
	
	sym := c.table.get_type_symbol(typ)
	assert sym.kind != .placeholder, sym.name
	if sym.kind == .placeholder {
		return false
	}

	return true
}

@[inline]
fn (c &Checker) get_type_name(typ ast.Type) string {
	return c.table.get_type_symbol(typ).name
}

//может ли тип var_typ иметь значение с типом value_typ
pub fn (mut c Checker) valid_type(var_typ ast.Type, value_typ ast.Type) bool {
	assert var_typ != 0
	assert value_typ != 0

	if var_typ == value_typ {
		return true
	}

	return false
}

pub fn (mut c Checker) valid_prop_type(var_typ ast.Type, value_typ ast.Type) bool {
	if c.valid_type(var_typ, value_typ) {
		return true
	}

	var_sym := c.table.get_type_symbol(var_typ)
	if var_sym.kind == .script || var_sym.kind == .array {
		if value_typ == ast.none_type {
			return true
		}
	}

	return false
}

//можно ли кастануть тип from_type к типу to_type
pub fn (mut c Checker) can_autocast(from_type ast.Type, to_type ast.Type) bool {
	assert from_type != 0
	assert to_type != 0
	assert from_type != to_type
	from_sym := c.table.get_type_symbol(from_type)
	to_sym := c.table.get_type_symbol(to_type)
	assert from_sym.kind != .placeholder, from_sym.name
	assert to_sym.kind != .placeholder, to_sym.name

	match to_sym.kind {
		.placeholder { panic("wtf") }
		.none_ {
			return false
		}
		.int {
			return false
		}
		.float {
			match from_sym.kind {
				.int { return true }
				else { return false }
			}

			return false
		}
		.string {
			return true
		}
		.bool {
			return true
		}
		.array {
			match from_sym.kind {
				.none_ { return true }
				else { return false }
			}

			return false
		}
		.script {
			match from_sym.kind {
				.none_ { return true }
				.script { return c.table.typ_is_parent(from_type, to_type) }
				else { return false }
			}

			return false
		}
	}

	return false
}

//можно ли кастануть тип from_type к типу to_type
pub fn (mut c Checker) can_cast(from_type ast.Type, to_type ast.Type) bool {
	assert from_type != 0
	assert to_type != 0
	assert from_type != to_type
	
	from_sym := c.table.get_type_symbol(from_type)
	to_sym := c.table.get_type_symbol(to_type)
	assert from_sym.kind != .placeholder, from_sym.name
	assert to_sym.kind != .placeholder, to_sym.name

	match from_sym.kind {
		.placeholder { panic("wtf") }
		.none_ {
			match to_sym.kind {
				.string,
				.bool { return true }
				else {}
			}
		}
		.int {
			match to_sym.kind {
				.float,
				.string,
				.bool { return true }
				else {}
			}
		}
		.float {
			match to_sym.kind {
				.int,
				.string,
				.bool { return true }
				else {}
			}
		}
		.string {
			match to_sym.kind {
				.int,
				.float,
				.bool { return true }
				else {}
			}
		}
		.bool {
			match to_sym.kind {
				.int,
				.float,
				.string { return true }
				else { }
			}
			
		}
		.array {
			match to_sym.kind {
				.string,
				.bool { return true }
				else {}
			}
		}
		.script {
			match to_sym.kind {
				.string,
				.bool { return true }
				.script {
					if c.table.typ_is_parent(from_type, to_type) || c.table.typ_is_parent(to_type, from_type) {
						return true
					}
				}
				else {}
			}
		}
	}

	return false
}

pub fn (mut c Checker) cast_to_type(node ast.Expr, from_type ast.Type, to_type ast.Type) &ast.Expr {
	assert c.can_cast(from_type, to_type) || c.can_autocast(from_type, to_type)

	new_node := ast.CastExpr {
		expr: node
		pos: node.pos
		type_name: c.get_type_name(to_type)
		typ: to_type
	}

	return &new_node
}

pub fn (mut c Checker) find_method(typ ast.Type, name string) ?ast.Fn {
	mut sym := c.table.get_type_symbol(typ)

	mut tsym := sym
	for {
		assert tsym.kind != .placeholder, tsym.name

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
						default_value: ast.EmptyExpr{}
					},
					ast.Param{
						name: "startIndex"
						typ: ast.int_type
						is_optional: true
						default_value: ast.IntegerLiteral{ val: if lname == "find" { "0" } else { "-1" } }
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

pub fn (mut c Checker) find_fn(a_typ ast.Type, obj_name string, name string) ?&ast.Fn {
	mut typ := a_typ

	if typ == 0 {
		typ = c.table.find_type_idx(obj_name)
	}

	if func := c.table.find_fn(obj_name, name) {
		return &func
	}

	if typ == 0 {
		return none
	}
	
	mut sym := c.table.get_type_symbol(typ)

	mut tsym := sym
	for {
		if func := tsym.find_method(name) {
			return &func
		}

		if tsym.parent_idx > 0 {
			tsym = c.table.get_type_symbol(tsym.parent_idx)
			continue
		}

		break
	}
	
	if name.to_lower() == 'getstate' {
		return &ast.Fn{
			return_type: ast.string_type
			obj_name: c.cur_obj_name
			name: 'GetState'
			lname: 'getstate'
			is_global: false
		}
	}
	else if name.to_lower() == 'gotostate' {
		return &ast.Fn{
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

@[inline]
pub fn (mut c Checker) get_default_value(typ ast.Type) ast.Expr {
	match c.table.get_type_symbol(typ).kind {
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

fn (c &Checker) find_var_or_property_type(typ ast.Type, name string) ?ast.Type {
	mut sym := c.table.get_type_symbol(typ)

	for {
		if prop := sym.find_property(name) {
			return prop.typ
		}

		if var := sym.find_var(name) {
			return var.typ
		}

		if sym.parent_idx > 0 {
			sym = c.table.get_type_symbol(sym.parent_idx)
			continue
		}

		break
	}

	return none
}

@[inline]
pub fn (c &Checker) is_empty_state() bool {
	return c.cur_state_name == pex.empty_state_name
}

pub fn (mut c Checker) warn(message string, pos token.Position) {
	c.warnings << errors.Warning {
		message: message
		file_path: c.file.path
		pos: pos
		reporter:  errors.Reporter.checker
	}

	if c.pref.output_mode == .stdout {
		util.show_compiler_message("Checker warning:", pos: pos, file_path: c.file.path, message: message)
	}
}

pub fn (mut c Checker) error(message string, pos token.Position) {
	if c.pref.is_verbose {
		print_backtrace()
	}

	c.errors << errors.Error {
		message: message
		file_path: c.file.path
		pos: pos
		backtrace: ""
		reporter:  errors.Reporter.checker
	}
	
	if c.pref.output_mode == .stdout {
		util.show_compiler_message("Checker error:", pos: pos, file_path: c.file.path, message: message)
	}
}