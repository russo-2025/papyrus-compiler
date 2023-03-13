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

	if p.is_empty_state() {
		mut sym := p.table.get_type_symbol(p.cur_object)
		
		if !sym.has_method(name) {
			sym.register_method(ast.Fn{
				pos: pos
				params: params
				return_type: ast.none_type
				state_name: p.cur_state_name
				obj_name: p.cur_obj_name
				name: name
				lname: name.to_lower()
				is_global: false
			})
		}
	}

	return ast.FnDecl{
		name: name
		pos: pos
		params: params
		stmts: stmts
		return_type: ast.none_type
		flags: []token.Kind{}
		scope: scope
		is_native: false
		is_global: false
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
	flags := p.parse_flags(p.tok.line_nr + 1)
	is_native := token.Kind.key_native in flags
	is_global := token.Kind.key_global in flags

	mut stmts := []ast.Stmt{}

	if !is_native {
		stmts = p.stmts()
		p.check(.key_endfunction)
	}
	
	scope := p.scope
	p.close_scope()
	
	table_func := ast.Fn{
		pos: pos
		params: params
		return_type: return_type
		state_name: p.cur_state_name
		obj_name: p.cur_obj_name
		name: name
		lname: name.to_lower()
		is_global: is_global
		is_native: is_native
	}

	if p.is_empty_state() {
		if !p.inside_property {
			if is_global {
				if !p.table.has_fn(p.cur_obj_name, name) {
					p.table.register_fn(table_func)
				}
			}
			else {
				mut sym := p.table.get_type_symbol(p.cur_object)
				
				if !sym.has_method(name) {
					sym.register_method(table_func)
				}
			}
		}
	}
	else {
		if is_global {
			eprintln("Parser TODO: global fn in state. wtf?")
		}
		else {
			mut sym := p.table.get_type_symbol(p.cur_object)
			
			if !sym.has_method_in_state(p.cur_state_name, name) {
				sym.register_method_in_state(p.cur_state_name, table_func)
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
		is_native: is_native
		is_global: is_global
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

				default_value := p.expr(0) or { ast.EmptyExpr{} }

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
	
	mut optional_args_is_started := false

	for p.tok.kind != .rpar {
		if p.tok.kind == .eof {
			p.error_with_pos('unexpected eof reached, while parsing call argument', start_pos)
		}

		arg_start_pos := p.tok.position()

		if p.tok.kind == .name && p.peek_tok.kind == .assign {
			optional_args_is_started = true

			name := p.check_name()
			p.check(.assign)
			expr := p.expr(0) or { p.error("invalid expression") }
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
			if optional_args_is_started {
				p.error("parameter is expected in the format 'name = value`") // ожидается параметр в формате `name = value`
			}

			e := p.expr(0) or { p.error("invalid expression") }
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