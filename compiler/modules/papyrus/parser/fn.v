module parser

import papyrus.ast
import papyrus.table
import papyrus.token

pub fn (mut p Parser) event_decl() ast.FnDecl {
	p.open_scope()

	pos := p.tok.position()

	p.check(.key_event)
	name := p.check_name()

	params := p.fn_args()

	stmts := p.stmts()
	p.check(.key_endevent)

	scope := p.scope
	p.close_scope()

	return ast.FnDecl{
		name: name
		pos: pos
		params: params
		stmts: stmts
		return_type: table.none_type
		flags: []token.Kind{}
		scope: scope
		no_body: false
		is_static: false
		is_event: true
	}
}

pub fn (mut p Parser) fn_decl() ast.FnDecl {
	p.open_scope()

	pos := p.tok.position()

	mut return_type := table.none_type

	if p.parsed_type != 0 {
		return_type = p.get_parsed_type()
	}

	p.check(.key_function)
	name := p.check_name()
	
	params := p.fn_args()
	flags := p.parse_flags()
	no_body := token.Kind.key_native in flags
	is_static := token.Kind.key_global in flags

	mut stmts := []ast.Stmt{}

	if !no_body {
		stmts = p.stmts()
		p.check(.key_endfunction)
	}
	
	scope := p.scope
	p.close_scope()
	
	if is_static {
		p.table.register_fn(table.Fn{
			params: params
			return_type: return_type
			mod: p.mod
			name: name
			sname: name.to_lower()
			is_static: true
		})
	}
	else {
		if p.cur_object == 0 {
			panic("Compiler error")
		}
		p.table.types[p.cur_object.idx()].register_method(table.Fn{
			params: params
			return_type: return_type
			mod: p.mod
			name: name
			sname: name.to_lower()
			is_static: false
		})
	}

	return ast.FnDecl{
		name: name
		pos: pos
		params: params
		stmts: stmts
		return_type: return_type
		flags: flags
		scope: scope
		no_body: no_body
		is_static: is_static
	}
}

fn (mut p Parser) fn_args() []table.Param {
	p.check(.lpar)

	mut args := []table.Param{}

	if p.tok.kind != .rpar {
		for {
			mut param := table.Param{}

			p.parse_type()
			param.typ = p.get_parsed_type()
			
			param.name = p.check_name()
			
			if p.tok.kind == .assign {
				p.next()

				default_value := p.expr(0)

				if default_value is ast.StringLiteral { param.default_value = default_value.val }
				else if default_value is ast.BoolLiteral { param.default_value = default_value.val }
				else if default_value is ast.IntegerLiteral { param.default_value = default_value.val }
				else if default_value is ast.FloatLiteral { param.default_value = default_value.val }
				else if default_value is ast.NoneLiteral { param.default_value = "None" }
				else {
						println(default_value)
						p.error("default value is not literal")
				}

				param.is_optional = true
			}

			args << param

			if p.tok.kind == .comma {
				p.next()
				continue
			}

			break
		}
	}

	p.check(.rpar)
	return args
}

pub fn (mut p Parser) call_args() []ast.CallArg {

	mut args := []ast.CallArg{}
	start_pos := p.tok.position()

	for p.tok.kind != .rpar {
		if p.tok.kind == .eof {
			p.error_with_pos('unexpected eof reached, while parsing call argument', start_pos)
			return []
		}

		arg_start_pos := p.tok.position()

		/*if p.tok.kind == .name && p.peek_tok.kind == .assign {
			name := p.check_name()
			p.next()
			expr := p.expr(0)
			pos := arg_start_pos.extend(p.prev_tok.position())
			args << ast.CallArg{
				expr: ast.DefaultValue{
					name: name
					expr: expr
					pos: pos
				}
				pos: pos
			}
		}
		else {*/
			e := p.expr(0)
			pos := arg_start_pos.extend(p.prev_tok.position())
			args << ast.CallArg{
				expr: e
				pos: pos
			}
		//}

		match p.tok.kind {
			.rpar {
				break
			}
			.comma {
				p.next()
			}
			else {
				p.error('unexpected `$p.tok.kind.str()`, expecting `)` or `,`')
			}
		}
	}

	return args
}