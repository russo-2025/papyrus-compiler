module ast

import papyrus.token
import papyrus.table

pub type Expr = InfixExpr | IntegerLiteral | FloatLiteral | BoolLiteral | StringLiteral | Ident | CallExpr | SelectorExpr | IndexExpr |
	ParExpr | PrefixExpr | EmptyExpr | DefaultValue | ArrayInit | NoneLiteral | CastExpr



pub struct EmptyExpr {
pub:
	pos		token.Position
}

pub fn (e EmptyExpr) str() string {
	return "EmptyExpr{}"
}

pub struct CastExpr {
pub:
	pos			token.Position
	expr		Expr
	type_name	string
pub mut:
	typ			table.Type
}

//задает значение вместо дефолтного при вызове функции
pub struct DefaultValue {
pub:
	name	string
	expr	Expr
	pos		token.Position
}

pub struct InfixExpr {
pub mut:
	op			token.Kind
	left        Expr
	right       Expr
	pos         token.Position
	left_type	table.Type
	right_type	table.Type
	result_type	table.Type
}

pub struct IntegerLiteral {
pub:
	pos  token.Position
	val string
}

pub struct NoneLiteral {
pub:
	pos		token.Position
	val		string
}

pub struct FloatLiteral {
pub:
	pos  token.Position
	val string
}

pub struct StringLiteral {
pub:
	pos      token.Position
	val      string
}

pub struct BoolLiteral {
pub:
	pos      token.Position
	val      string
}

pub struct Ident {
pub:
	name	string
	pos		token.Position
pub mut:
	typ		table.Type
}

pub struct CallArg {
pub:
	pos		token.Position
pub mut:
	expr	Expr
	typ		table.Type
}

pub struct CallExpr {
pub mut:
	pos				token.Position
	left			Expr // `user` in `user.register()`
	mod				string // mod.name()
	name			string // left.name()
	args			[]CallArg
	def_args		map[string]DefaultValue
	return_type		table.Type
	is_static		bool
}

// `foo.bar`
pub struct SelectorExpr {
pub mut:
	pos			token.Position
	expr		Expr // expr.field_name
	field_name	string
	typ			table.Type
}

//arr[1]
pub struct IndexExpr {
pub:
	left	Expr
	index	Expr
	pos		token.Position
pub mut:
	typ		table.Type
}

pub struct ParExpr {
pub:
	expr Expr
	pos  token.Position
}

// See: token.Kind.is_prefix
pub struct PrefixExpr {
pub:
	op			token.Kind
	pos			token.Position
pub mut:
	right		Expr
	//checker
	right_type	table.Type
}

pub struct ArrayInit {
pub:
	typ			table.Type
	elem_type	table.Type
	len			Expr
	pos			token.Position
}

pub fn (expr Expr) position() token.Position {
	// all uncommented have to be implemented
	match expr {
		CallExpr, FloatLiteral, Ident, IndexExpr, IntegerLiteral, BoolLiteral,
		SelectorExpr, StringLiteral, ParExpr, PrefixExpr, DefaultValue, ArrayInit, NoneLiteral, CastExpr {
			return expr.pos
		}
		InfixExpr {
			left_pos := expr.left.position()
			right_pos := expr.right.position()
			return token.Position{
				line_nr: expr.pos.line_nr
				pos: left_pos.pos
				len: right_pos.pos - left_pos.pos + right_pos.len
				last_line: right_pos.last_line
			}
		}
		EmptyExpr { return token.Position{} }
		// Please, do NOT use else{} here.
		// This match is exhaustive *on purpose*, to help force
		// maintaining/implementing proper .pos fields.
	}
}