module parser

import papyrus.scanner
import papyrus.token
import os
import pref
import papyrus.ast
import papyrus.util
import papyrus.table

pub struct Parser {
	pref				&pref.Preferences
mut:
	path				string // "/home/user/hello.v"
	table				&table.Table
	scanner				&scanner.Scanner

	prev_tok			token.Token
	tok					token.Token
	peek_tok			token.Token
	peek_tok2			token.Token
	peek_tok3			token.Token

	scope				&ast.Scope
	global_scope		&ast.Scope
	
	mod					string // имя текущего скрипта
	cur_type			table.Type //спаршеный тип TODO: почему их 2
	parsed_type			table.Type //спаршеный тип

	last_mod_time		int
}

pub fn (mut p Parser) set_path(path string) {
	p.path = path
}

pub fn parse_files(paths []string, table &table.Table, pref &pref.Preferences, global_scope &ast.Scope) []ast.File {
	mut files := []ast.File{}

	for path in paths {
		files << parse_file(path, table, pref, global_scope)
	}

	return files
}

pub fn parse_file(path string, table &table.Table, pref &pref.Preferences, global_scope &ast.Scope) ast.File {
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

pub fn (mut p Parser) parse() ast.File {
	p.read_first_token()

	mut stmts := []ast.TopStmt{}

	stmts << p.script_decl()

	for {
		if p.tok.kind == .eof {
			break
		}

		stmts << p.top_stmt()
	}

	return ast.File{
		path: p.path
		path_base: os.base(p.path)
		file_name: os.base(p.path).all_before_last(".")
		stmts: stmts
		scope: p.scope
		last_mod_time: os.file_last_mod_unix(p.path)
	}
}

[inline]
pub fn (mut p Parser) comment() ast.Comment {
	node := ast.Comment{ text: p.tok.lit }
	p.next()
	return node
}

pub fn (mut p Parser) top_stmt() ast.TopStmt {
	for {
		//println("top_stmt for: " + p.tok.kind.str() + ", " + p.tok.lit)

		match p.tok.kind {
			.comment {
				return p.comment()
			}
			.name {
				if p.next_is_type() {
					p.parsed_type = p.parse_type()
					continue
				}
			}
			.key_bool,
			.key_int,
			.key_string,
			.key_float {
				p.parsed_type = p.parse_type()
			}
			.key_hidden,
			.key_conditional,
			.key_auto,
			.key_readonly,
			.key_native,
			.key_global {
				p.error("(top statement) invalid token: " + p.tok.kind.str() + ", " + "p.tok.lit")
			}
			.key_event {
				return p.event_decl()
			}
			.key_function {
				return p.fn_decl()
			}
			.key_state {
				p.error("(top statement) invalid token: " + p.tok.kind.str() + ", " + "p.tok.lit")
			}
			.key_property {
				p.error("(top statement) invalid token: " + p.tok.kind.str() + ", " + "p.tok.lit")
			}
			else {
				p.error("(top statement) invalid token: " + p.tok.kind.str() + ", " + "p.tok.lit")
			}
		}
	}

	return ast.TopStmt{}
}

pub fn (mut p Parser) script_decl() ast.ScriptDecl {
	
	pos := p.tok.position()

	p.check(.key_scriptname)

	name := p.check_name()

	p.mod = name
	p.table.register_module(name)

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

	for p.tok.kind.is_flag() {
		if p.tok.kind !in node.flags {
			node.flags << p.tok.kind
		}
		
		p.next()
	}
	
	p.cur_type = p.table.register_type_symbol({
		parent_idx: parent_idx
		kind: .script
		name: name
		mod: name
		methods: []table.Fn{}
	})

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
pub fn (mut p Parser) var_decl() ast.VarDecl {
	
	mut pos := p.tok.position()
	
	typ := p.parse_type()

	name := p.check_name()
	mut expr := ast.Expr{}
	expr = ast.NoneLiteral{val: "None"}

	if p.tok.kind == .assign {
		p.next()
		expr = p.expr(0)
	}

	pos = pos.extend(p.prev_tok.position())

	return  ast.VarDecl{
		typ: typ
		name: name
		assign: {
			op: token.Kind.assign
			pos: pos
			left: ast.Ident{
				name: name
				pos: pos
				typ: typ
			}
			right: expr
		}
		pos: pos
	}
}

pub fn (mut p Parser) stmts() []ast.Stmt {
	mut s := []ast.Stmt{}

	for {
		//println("stmt for: " + p.tok.kind.str() + ", " + p.tok.lit)
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
				
				if p.tok.kind == .lpar {
					p.next()
				}
				mut cond := p.expr(0)
				
				if p.tok.kind == .rpar {
					p.next()
				}

				mut stmts := p.stmts()

				branches << ast.IfBranch{
					pos: pos
					cond: cond
					stmts: stmts
				}

				for p.tok.kind != .key_endif && p.tok.kind != .key_else {
					pos = p.tok.position()
					p.check(.key_elseif)
					
					if p.tok.kind == .lpar {
						p.next()
					}
					cond = p.expr(0)
					
					if p.tok.kind == .rpar {
						p.next()
					}
					stmts = p.stmts()

					branches << ast.IfBranch{
						pos: pos
						cond: cond
						stmts: stmts
					}
				}

				mut has_else := false
				
				if p.tok.kind == .key_else {
					has_else = true
					pos = p.tok.position()
					p.next()
					stmts = p.stmts()

					branches << ast.IfBranch{
						pos: pos
						cond: ast.BoolLiteral { val: "true" }
						stmts: stmts
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
				if p.tok.kind == .lpar {
					p.next()
				}
				mut cond := p.expr(0)
				//p.check(.rpar)
				if p.tok.kind == .rpar {
					p.next()
				}
				mut stmts := p.stmts()

				p.check(.key_endwhile)
				
				s << ast.While {
					pos: pos
					cond: cond
					stmts: stmts
				}
			}
			.key_self {
				s << p.parse_expr_stmt()
			}
			.key_parent {
				p.error("(block statement) invalid token: " + p.tok.kind.str() + ", " + "p.tok.lit")
			}
			.name {
				if p.peek_tok.kind == .name {
					s << p.var_decl()
				}
				else if p.peek_tok.kind == .lsbr && p.peek_tok2.kind == .rsbr && p.peek_tok3.kind == .name {
					s << p.var_decl()
				}
				else {
					s << p.parse_expr_stmt()
				}
			}
			//типы перед переменными
			.key_bool,
			.key_int,
			.key_string,
			.key_float {
				s << p.var_decl()
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