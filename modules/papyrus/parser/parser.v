module parser

import papyrus.scanner
import papyrus.token
import os
import pref
import papyrus.ast
import papyrus.util
import pex

pub struct Parser {
	pref				&pref.Preferences
mut:
	path				string // "/home/user/hello.v"
	last_mod_time		i64
	table				&ast.Table
	scanner				&scanner.Scanner

	prev_tok			token.Token
	tok					token.Token
	peek_tok			token.Token
	peek_tok2			token.Token
	peek_tok3			token.Token

	imports				[]string
	
	scope				&ast.Scope
	global_scope		&ast.Scope
	
	used_indents		[]string
	
	inside_property		bool

	cur_obj_name		string 
	cur_state_name		string = pex.default_state_name
	cur_object			ast.Type //current object type

	parsed_type			ast.Type //спаршеный тип
	is_extended_lang	bool
}

pub fn parse_files(paths []string, table &ast.Table, pref &pref.Preferences, global_scope &ast.Scope) []ast.File {
	mut files := []ast.File{}

	for path in paths {
		files << parse_file(path, table, pref, global_scope)
	}

	return files
}

pub fn parse_file(path string, table &ast.Table, pref &pref.Preferences, global_scope &ast.Scope) &ast.File {
	mut p := Parser{
		scanner: scanner.new_scanner_file(path, pref)
		pref: pref
		scope: &ast.Scope{
			start_pos: 0
			parent: global_scope
		}
		global_scope: global_scope
		table: table
	}

	p.set_path(path)

	return p.parse()
}

pub fn parse_text(text string, table &ast.Table, pref &pref.Preferences, global_scope &ast.Scope) &ast.File {
	mut p := Parser{
		scanner: scanner.new_scanner(text, pref)
		pref: pref
		scope: &ast.Scope{
			start_pos: 0
			parent: global_scope
		}
		global_scope: global_scope
		table: table
	}

	p.set_path('::in-memory::')

	return p.parse()
}

pub fn (mut p Parser) parse() &ast.File {
	p.read_first_token()

	mut stmts := []ast.TopStmt{}

	stmts << p.script_decl()

	for {
		if p.tok.kind == .eof {
			break
		}

		if stmt := p.top_stmt() {
			stmts << stmt
		}
		else {
			panic("wtf")
		}
	}

	return &ast.File{
		path: p.path
		path_base: os.base(p.path)
		file_name: os.base(p.path).all_before_last(".")
		obj_name: p.cur_obj_name
		stmts: stmts
		imports: p.imports
		scope: p.scope
		last_mod_time: os.file_last_mod_unix(p.path)
		used_indents: p.used_indents
	}
}

pub fn (mut p Parser) set_path(path string) {
	p.path = path
}

[inline]
pub fn (mut p Parser) comment() ast.Comment {
	node := ast.Comment{
		text: p.tok.lit,
		pos: p.tok.position()
	}
	p.next()
	return node
}

pub fn (mut p Parser) top_stmt() ?ast.TopStmt {
	mut last_token_pos := 0

	for {
		if last_token_pos == p.tok.pos {
			p.error("compiler bug(top stmt): " + p.tok.kind.str() + ", " + "$p.tok.lit")
		}
		else {
			last_token_pos = p.tok.pos
		}

		match p.tok.kind {
			.key_import {
				p.next()
				name := p.check_name()
				p.imports << name
			}
			.comment {
				return p.comment()
			}
			.name {
				if p.next_is_type() {
					p.parse_type()
					continue
				}
				else if p.parsed_type != 0 {
					return p.var_decl(true)
				}
			}
			.key_bool,
			.key_int,
			.key_string,
			.key_float {
				p.parse_type()
			}
			.key_event {
				return p.event_decl()
			}
			.key_function {
				return p.fn_decl()
			}
			.key_property {
				return p.property_decl()
			}
			.key_state {
				return p.state_decl()
			}
			else {
				p.error("(top statement) invalid token: " + p.tok.kind.str() + ", " + "p.tok.lit")
			}
		}
	}

	return none
}

[inline]
pub fn (mut p Parser) parse_flags() []token.Kind {
	mut flags := []token.Kind{}
	for p.tok.kind.is_flag() {
		if p.tok.kind !in flags {
			flags << p.tok.kind
		}
		
		p.next()
	}

	return flags
}

pub fn (mut p Parser) state_decl() ast.StateDecl {
	pos := p.tok.position()
	p.check(.key_state)

	name := p.check_name()

	p.cur_state_name = name
	
	mut fns := []ast.FnDecl{}
	
	mut last_token_pos := 0

	for {
		if p.tok.kind == .key_endstate {
			break
		}

		if last_token_pos == p.tok.pos {
			p.error("compiler bug(state): " + p.tok.kind.str() + ", " + "$p.tok.lit")
		}
		else {
			last_token_pos = p.tok.pos
		}

		match p.tok.kind {
			.name {
				if !p.next_is_type() {
					p.error("(state) invalid token: " + p.tok.kind.str() + ", " + "p.tok.lit")
				}
				
				p.parse_type()
			}
			.key_bool,
			.key_int,
			.key_string,
			.key_float {
				p.parse_type()
			}
			.key_function {
				fns << p.fn_decl()
			}
			.key_event {
				fns << p.event_decl()
			}
			else {
				p.error("(state) invalid token: " + p.tok.kind.str() + ", " + "p.tok.lit")
			}
		}
	}

	p.check(.key_endstate)
	
	p.cur_state_name = pex.default_state_name
	
	return ast.StateDecl {
		pos: pos
		name: name
		fns: fns
	}
}

pub fn (mut p Parser) property_decl() ast.PropertyDecl {
	p.inside_property = true

	mut typ := ast.none_type

	if p.parsed_type != 0 {
		typ = p.get_parsed_type()
	}
	
	pos := p.tok.position()
	p.check(.key_property)
	name := p.check_name()
	mut expr := ast.Expr(ast.EmptyExpr{})

	if p.tok.kind == .assign {
		p.next()
		expr = p.expr(0)
	}

	flags := p.parse_flags()

	mut node := ast.PropertyDecl {
		typ: typ
		pos: pos
		name: name
		expr: expr
		read: &ast.Empty{}
		write: &ast.Empty{}
	}

	for flag in flags {
		if flag == token.Kind.key_auto {
			node.is_auto = true
		}
		else if flag == token.Kind.key_readonly {
			node.is_autoread = true
		}
		else if flag == token.Kind.key_hidden {
			node.is_hidden = true
		}
		else if flag == token.Kind.key_conditional {
			node.is_conditional = true
		}
		else {
			p.error("you cannot use flag ${flag} with property")
		}
	}

	if node.is_conditional && node.is_autoread {
		p.error("`Conditional` flag cannot be used with `AutoReadOnly` flag")
	}

	if node.is_auto && node.is_autoread {
		p.error("`Auto` flag cannot be used with `AutoReadOnly` flag")
	}

	if !node.is_auto && !node.is_autoread {
		mut i := 0

		for i < 2 {
			if p.tok.kind == .comment {
				p.next()
			}

			if p.tok.kind == .key_endproperty {
				break
			}

			if p.next_is_type() {
				p.parse_type()
			}

			handler := p.fn_decl()
			handler_name := handler.name.to_lower()

			if handler_name == "set" {
				node.write = &handler
			}
			else if handler_name == "get" {
				node.read = &handler
			}
			else {
				p.error_with_pos("invalid function name: $handler_name, expected `get` or `set`", handler.pos)
			}
		}
		
		p.check(.key_endproperty)
	}

	p.inside_property = false
	
	default_var_name := "::" + node.name + "_var"
	
	node.default_var_name = default_var_name

	p.table.register_property(ast.Prop{
		name: node.name
		obj_name: p.cur_obj_name
		default_var_name: default_var_name
		typ: node.typ

		is_auto: node.is_auto
	})

	return node
}

pub fn (mut p Parser) script_decl() ast.ScriptDecl {
	
	pos := p.tok.position()

	if p.tok.kind == .key_scriptname {
		p.next()
	}
	else if p.tok.kind == .key_scriptplus {
		p.next()
		p.is_extended_lang = true
	}
	else {
		p.error('unexpected `$p.tok.lit`, expecting `scriptname` or `scriptplus`')
	}

	name := p.check_name()

	p.cur_obj_name = name
	p.table.register_object(name)

	mut node := ast.ScriptDecl{
		pos: pos
		name: name
		name_pos: p.tok.position()
	}

	mut parent_idx := 0

	if p.tok.kind == .key_extends {
		
		p.next()

		node.parent_pos = p.tok.position()
		node.parent_name = p.check_name()

		parent_idx = p.table.find_type_idx(node.parent_name)
		
		if parent_idx == 0 {
			parent_idx = p.table.add_placeholder_type(node.parent_name)
		}
	}
	
	node.flags = p.parse_flags()
	
	p.cur_object = p.table.register_type_symbol(
		parent_idx: parent_idx
		kind: .script
		name: name
		obj_name: name
		methods: []ast.Fn{}
	)

	return node
}

pub fn (mut p Parser) read_first_token() {
	// need to call next() 4 times to get peek token 1,2,3 and current token
	p.next()
	p.next()
	p.next()
	p.next()
}

[inline]
fn (mut p Parser) next() {
	p.prev_tok = p.tok
	p.tok = p.peek_tok
	p.peek_tok = p.peek_tok2
	p.peek_tok2 = p.peek_tok3
	p.peek_tok3 = p.scanner.scan()
}

[inline]
pub fn (mut p Parser) check_name() string {
	name := p.tok.lit
	p.check(.name)
	return name
}

[inline]
pub fn (mut p Parser) check(expected token.Kind) {
	if p.tok.kind == expected {
		p.next()
	} else if p.tok.kind == .name {
		p.error('unexpected name `$p.tok.lit`, expecting `$expected.str()`')
	} else {
		p.error('unexpected `$p.tok.kind.str()`, expecting `$expected.str()`')
	}
}

[inline]
pub fn (mut p Parser) parse_expr_stmt() ast.Stmt {
	pos := p.tok.position()
	expr := p.expr(0)

	if p.tok.kind.is_assign() {
		op := p.tok.kind
		p.next()
		right := p.expr(0)

		mut a := ast.AssignStmt {
			op: op
			pos: pos
			right: right
			left: expr
		}
		return a
	}

	return ast.ExprStmt{
		expr: expr
		pos: pos
	}
}

[inline]
pub fn (mut p Parser) var_decl(is_object_var bool) ast.VarDecl {
	
	mut pos := p.tok.position()

	typ := p.get_parsed_type()

	name := p.check_name()
	mut expr := ast.Expr(ast.EmptyExpr{})

	if p.tok.kind == .assign {
		p.next()
		expr = p.expr(0)
	}

	flags := p.parse_flags()
	pos = pos.extend(p.prev_tok.position())

	return  ast.VarDecl{
		typ: typ
		obj_name: p.cur_obj_name
		name: name
		assign: ast.AssignStmt{
			op: token.Kind.assign
			pos: pos
			left: ast.Ident{
				name: name
				pos: pos
				typ: typ
			}
			right: expr
			typ: typ
		}
		flags: flags
		pos: pos
		is_object_var: is_object_var
	}
}

pub fn (mut p Parser) stmts() []ast.Stmt {
	mut last_token_pos := 0

	mut s := []ast.Stmt{}

	for {
		if last_token_pos == p.tok.pos {
			p.error("compiler bug(stmt): " + p.tok.kind.str() + ", " + "$p.tok.lit")
		}
		else {
			last_token_pos = p.tok.pos
		}

		match p.tok.kind {
			.comment {
				s << p.comment()
			}
			.key_return {
				pos := p.tok.position()
				p.next()

				s << ast.Return {
					pos: pos
					expr: p.expr(0)
				}
			}
			.key_if {
				mut branches := []ast.IfBranch{}

				mut pos := p.tok.position()
				p.next()
				
				
				mut cond := p.expr(0)



				
				p.open_scope()
				mut stmts := p.stmts()
				mut scope := p.scope
				p.close_scope()

				branches << ast.IfBranch{
					pos: pos
					cond: cond
					stmts: stmts
					scope: scope
				}

				for p.tok.kind != .key_endif && p.tok.kind != .key_else {
					pos = p.tok.position()
					p.check(.key_elseif)
					
					
					cond = p.expr(0)
					
					

					p.open_scope()
					stmts = p.stmts()
					scope = p.scope
					p.close_scope()

					branches << ast.IfBranch{
						pos: pos
						cond: cond
						stmts: stmts
						scope: scope
					}
				}

				mut has_else := false
				
				if p.tok.kind == .key_else {
					has_else = true
					pos = p.tok.position()
					p.next()

					p.open_scope()
					stmts = p.stmts()
					scope = p.scope
					p.close_scope()

					branches << ast.IfBranch{
						pos: pos
						cond: ast.BoolLiteral { val: "true" }
						stmts: stmts
						scope: scope
					}
				}

				p.check(.key_endif)

				s << ast.If {
					pos: pos
					branches: branches
					has_else: has_else
				}
			}
			.key_while {
				mut pos := p.tok.position()
				p.next()
				//p.check(.lpar)
				
				mut cond := p.expr(0)
				//p.check(.rpar)
				
				
				p.open_scope()
				mut stmts := p.stmts()
				scope := p.scope
				p.close_scope()

				p.check(.key_endwhile)
				
				s << ast.While {
					pos: pos
					cond: cond
					stmts: stmts
					scope: scope
				}
			}
			.name {
				if p.next_is_type() {
					p.parse_type()
					continue
				}
				else if p.parsed_type != 0 {
					s << p.var_decl(false)
				}
				else {
					s << p.parse_expr_stmt()
				}
			}
			.number,
			.string,
			.key_new,
			.key_self,
			.key_parent,
			.key_none,
			.key_true,
			.key_false,
			.plus,
			.minus,
			.not,
			.lpar {
				s << p.parse_expr_stmt()
			}
			//типы перед переменными
			.key_bool,
			.key_int,
			.key_string,
			.key_float {
				p.parse_type()
			}
			.key_endfunction,
			.key_endwhile,
			.key_endif,
			.key_else,
			.key_elseif,
			.key_endevent {
				break
			}
			.eof {
				p.error("unexpected end of file")
			}
			else {
				p.error("(block statement) invalid token: " + p.tok.kind.str() + ", " + "p.tok.lit")
			}
		}
	}

	return s
}

[inline]
pub fn (mut p Parser) check_extended_lang() {
	if !p.is_extended_lang {
		p.error("This feature is only available in p++")
	}
}

[inline]
pub fn (p Parser) is_state() bool {
	return p.cur_state_name != pex.default_state_name
}

[inline]
pub fn (mut p Parser) open_scope() {
	p.scope = &ast.Scope{
		parent: p.scope
		start_pos: p.tok.pos
	}
}

[inline]
pub fn (mut p Parser) close_scope() {
	// p.scope.end_pos = p.tok.pos
	// NOTE: since this is usually called after `p.parse_block()`
	// ie. when `prev_tok` is rcbr `}` we most likely want `prev_tok`
	// we could do the following, but probably not needed in 99% of cases:
	// `end_pos = if p.prev_tok.kind == .rcbr { p.prev_tok.pos } else { p.tok.pos }`
	p.scope.end_pos = p.prev_tok.pos
	p.scope.parent.children << p.scope
	p.scope = p.scope.parent
}

pub fn (mut p Parser) error(s string) {
	p.error_with_pos(s, p.tok.position())
}

pub fn (mut p Parser) error_with_pos(s string, pos token.Position) {
	ferror := util.formatted_error('parser error:', s, p.path, pos)
	eprintln(ferror)
	exit(1)
}