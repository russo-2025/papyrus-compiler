module parser

import papyrus.ast
import papyrus.token
import papyrus.table

pub fn (mut p Parser) expr(precedence int) ast.Expr {
	mut node := ast.Expr{}
	node = ast.EmptyExpr{}
	
	match p.tok.kind {
		.key_new {
			node = p.new_expr()
		}
		.key_self {
			pos := p.tok.position()
			name := p.tok.lit
			
			p.next()
			
			node = ast.Ident{
				name: name
				pos: pos
			}
		}
		.name {
			node = p.name_expr()
		}
		.string {
			node = p.string_expr()
		}
		.number {
			node = p.parse_number_literal()
		}
		.key_none {
			mut pos := p.tok.position()
			p.next()
			node = ast.NoneLiteral{
				pos: pos
				val: "None"
			}
		}
		.key_true, 
		.key_false {
			node = p.parse_bool_literal()
		}

		.plus,
		.minus, 
		.not  { // -1, -a, !x
			if p.tok.kind == .minus && p.peek_tok.kind == .number {
				node = p.parse_number_literal()
			}
			else {
				node = p.prefix_expr()
			}
		}

		.lpar {
			mut pos := p.tok.position()
			p.check(.lpar)
			node = p.expr(0)
			p.check(.rpar)
			
			node = ast.ParExpr{
				expr: node
				pos: pos.extend(p.prev_tok.position())
			}
		}

		else {
			return ast.EmptyExpr{}
		}
	}

	return p.expr_with_left(node, precedence)
}

pub fn (mut p Parser) expr_with_left(left ast.Expr, precedence int) ast.Expr {
	mut node := left

	for precedence < p.tok.precedence() {
		if p.tok.kind == .dot {
			node = p.dot_expr(node)
		}
		else if p.tok.kind == .lsbr {
			node = p.index_expr(node)

			//функция в массиве
			/*
			if p.tok.kind == .lpar && p.tok.line_nr == p.prev_tok.line_nr && node is ast.IndexExpr {
				p.next() // (
				pos := p.tok.position()
				args := p.call_args()
				p.check(.rpar) // )
				node = ast.CallExpr{
					pos: pos
					left: node
					args: args
				}
			}*/
		}
		else if p.tok.kind == .key_as {
			node = p.cast_expr(node)
		}
		else if p.tok.kind.is_infix() {
			node = p.infix_expr(node)
		}
		else {
			return node
		}
	}
	return node
}

[inline]
pub fn (mut p Parser) new_expr() ast.Expr {
	pos := p.tok.position()
	p.check(.key_new)

	elem_type := p.parse_type()

	p.check(.lsbr)

	expr_len := p.expr(0)
	p.check(.rsbr)

	typ := table.new_type(p.table.find_or_register_array(elem_type))

	return ast.ArrayInit {
		elem_type: elem_type
		typ: typ
		len: expr_len
		pos: pos
	}
}

[inline]
fn (mut p Parser) cast_expr(expr ast.Expr) ast.CastExpr {
	pos := p.tok.position()
	p.check(.key_as)

	type_name := p.tok.lit

	p.next()

	return ast.CastExpr{
		pos: pos
		expr: expr
		type_name: type_name
	}
}

[inline]
pub fn (mut p Parser) parse_bool_literal() ast.Expr {
	lit := p.tok.lit
	pos := p.tok.position()

	p.next()

	return ast.BoolLiteral{
		val: lit
		pos: pos
	}
}

[inline]
pub fn (mut p Parser) parse_number_literal() ast.Expr {
	mut is_neg := false
	mut is_float := false
	mut is_hex := false


	if p.tok.kind == .minus {
		is_neg = true
		p.next()
	}

	mut lit := p.tok.lit
	pos := p.tok.position()
	
	if lit.index_any('.') >= 0 {
		is_float = true
	}
	if lit.len >= 3 && lit[..2] in ['0x', '0X'] {
		is_hex = true
	}

	if is_hex && is_neg {
		panic("negative hex wtf")
	}

	if is_neg {
		lit = "-" + lit
	}

	mut node := ast.Expr{}
	if is_float {
		node = ast.FloatLiteral{ val: lit, pos:pos }
	}
	else {
		node = ast.IntegerLiteral{ val: lit, pos:pos }
	}

	p.next()

	return node
}

[inline]
pub fn (mut p Parser) string_expr() ast.StringLiteral {
	node := ast.StringLiteral{ 
		val: p.tok.lit
		pos: p.tok.position()
	}
	
	p.next()

	return node
}

[inline]
pub fn (mut p Parser) dot_expr(left ast.Expr) ast.Expr {
	p.check(.dot)

	name_pos := p.tok.position()
	field_name := p.check_name()

	if p.tok.kind == .lpar {
		p.next()
		args := p.call_args()
		p.check(.rpar)

		end_pos := p.prev_tok.position()
		pos := name_pos.extend(end_pos)

		return ast.CallExpr{
			left: left
			name: field_name
			args: args
			pos: pos
		}
	}

	pos := name_pos

	return ast.SelectorExpr{
		expr: left
		field_name: field_name
		pos: pos
	}
}

[inline]
pub fn (mut p Parser) index_expr(left ast.Expr) ast.IndexExpr {
	start_pos := p.tok.position()
	
	p.check(.lsbr)
	expr := p.expr(0)
	// [expr]
	pos := start_pos.extend(p.tok.position())
	p.check(.rsbr)

	node := ast.IndexExpr{
		left: left
		index: expr
		pos: pos
	}

	return node
}

[inline]
fn (mut p Parser) infix_expr(left ast.Expr) ast.InfixExpr {
	op := p.tok.kind
	precedence := p.tok.precedence()

	mut pos := p.tok.position()
	
	if left.position().line_nr < pos.line_nr {
		pos = token.Position{
			...pos
			line_nr: left.position().line_nr
		}
	}

	p.next()
	mut right := p.expr(precedence)

	pos.update_last_line(p.prev_tok.line_nr)

	return ast.InfixExpr{
		left: left
		right: right
		op: op
		pos: pos
	}
}

[inline]
pub fn (mut p Parser) prefix_expr() ast.PrefixExpr {
	mut pos := p.tok.position()
	op := p.tok.kind
	p.next()

	mut right := p.expr( int(token.Precedence.prefix) )

	pos.update_last_line(p.prev_tok.line_nr)

	return ast.PrefixExpr{
		op: op
		right: right
		pos: pos
	}
}

[inline]
pub fn (mut p Parser) name_expr() ast.Expr {
	if p.tok.kind == .name && p.peek_tok.kind == .lpar {
		name_pos := p.tok.position()
		name := p.tok.lit
		p.next()
		//left := p.parse_ident()
		p.check(.lpar)
		args := p.call_args()
		p.check(.rpar)

		end_pos := p.prev_tok.position()
		pos := name_pos.extend(end_pos)
		
		return ast.CallExpr{
			left: ast.EmptyExpr{}
			name: name
			args: args
			pos: pos
		}
	}

	return p.parse_ident()
}

[inline]
pub fn (mut p Parser) parse_ident() ast.Ident {
	pos := p.tok.position()
	name := p.check_name()
	return ast.Ident{
		name: name
		pos: pos
	}
}