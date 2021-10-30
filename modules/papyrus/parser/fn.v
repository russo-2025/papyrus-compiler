module parser

import papyrus.ast
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
		return_type: ast.none_type
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

	mut return_type := ast.none_type

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
	
	if !p.is_state() && !p.inside_property {
		if is_static {
			if _ := p.table.find_fn(p.cur_obj_name, name) {}
			else {
				p.table.register_fn(ast.Fn{
					pos: pos
					params: params
					return_type: return_type
					state_name: p.cur_state_name
					obj_name: p.cur_obj_name
					name: name
					sname: name.to_lower()
					is_static: true
				})
			}
		}
		else {
			mut sym := p.table.get_type_symbol(p.cur_object)
			
			if !sym.has_method(name) {
				sym.register_method(ast.Fn{
					pos: pos
					params: params
					return_type: return_type
					state_name: p.cur_state_name
					obj_name: p.cur_obj_name
					name: name
					sname: name.to_lower()
					is_static: false
				})
			}
		}
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

fn (mut p Parser) fn_args() []ast.Param {
	p.check(.lpar)

	mut args := []ast.Param{}

	if p.tok.kind != .rpar {
		for {
			mut param := ast.Param{}

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

pub fn (mut p Parser) call_args() ([]ast.CallArg, map[string]ast.RedefinedOptionalArg) {

	mut args := []ast.CallArg{}
	mut redefined_args := map[string]ast.RedefinedOptionalArg{}

	start_pos := p.tok.position()
	
	mut args_is_ended := false

	for p.tok.kind != .rpar {
		if p.tok.kind == .eof {
			p.error_with_pos('unexpected eof reached, while parsing call argument', start_pos)
		}

		arg_start_pos := p.tok.position()

		if p.tok.kind == .name && p.peek_tok.kind == .assign {
			args_is_ended = true

			name := p.check_name()
			p.check(.assign)
			expr := p.expr(0)
			pos := arg_start_pos.extend(p.prev_tok.position())
			
			if name in redefined_args {
				p.error('a parameter named `$name` has already been set') // уже присутствует
			}

			redefined_args[name.to_lower()] = ast.RedefinedOptionalArg{
				name: name
				expr: expr
				pos: pos
			}
		}
		else {
			if args_is_ended {
				p.error("parameter is expected in the format 'name = value`") // ожидается параметр в формате `name = value`
			}

			e := p.expr(0)
			pos := arg_start_pos.extend(p.prev_tok.position())
			args << ast.CallArg{
				expr: e
				pos: pos
			}
		}

		if p.tok.kind == .rpar {
			break
		}

		p.check(.comma)

		if p.tok.kind == .rpar {
			p.error('unexpected end of arguments `$p.tok.lit`')
		}
	}

	return args, redefined_args
}