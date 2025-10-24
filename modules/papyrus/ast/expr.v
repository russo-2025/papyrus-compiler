module ast

import papyrus.token

pub type Expr = InfixExpr | IntegerLiteral | FloatLiteral | BoolLiteral | StringLiteral | Ident | CallExpr | SelectorExpr | IndexExpr |
	ParExpr | PrefixExpr | EmptyExpr | ArrayInit | NoneLiteral | CastExpr



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
	type_name	string
pub mut:
	expr		Expr
	typ			Type
}

@[heap]
pub struct InfixExpr {
pub mut:
	op			token.Kind
	left        Expr
	right       Expr
	pos         token.Position
	left_type	Type
	right_type	Type
	result_type Type
}

pub struct IntegerLiteral {
pub:
	pos		token.Position
	val		string
}

pub fn (lit IntegerLiteral) string() string {
	return lit.val
}

pub fn (lit IntegerLiteral) f32() f32 {
	return f32(lit.int())
}

pub fn (lit IntegerLiteral) int() int {
	return lit.val.int()
}

pub fn (lit IntegerLiteral) bool() bool {
	return if lit.int() > 0 { true } else { false }
}

pub struct NoneLiteral {
pub:
	pos		token.Position
	val		string
}

pub fn (lit NoneLiteral) bool() bool {
	return false
}

pub struct FloatLiteral {
pub:
	pos		token.Position
	val		string
}

pub fn (lit FloatLiteral) string() string {
	return lit.val
}

pub fn (lit FloatLiteral) f32() f32 {
	return lit.val.f32()
}

pub fn (lit FloatLiteral) int() int {
	return int(lit.f32())
}

pub fn (lit FloatLiteral) bool() bool {
	return if lit.f32() > 0 { true } else { false }
}

pub struct StringLiteral {
pub:
	pos      token.Position
	val      string
}

pub fn (lit StringLiteral) string() string {
	return lit.val
}

pub fn (lit StringLiteral) f32() f32 {
	return lit.val.f32()
}

pub fn (lit StringLiteral) int() int {
	return lit.val.int()
}

pub fn (lit StringLiteral) bool() bool {
	return lit.val.len != 0
}

pub struct BoolLiteral {
pub:
	pos      token.Position
	val      string
}

pub fn (lit BoolLiteral) bool() bool {
	return lit.val.to_lower() == 'true'
}

pub fn (lit BoolLiteral) f32() f32 {
	return if lit.val.to_lower() == 'true' { f32(1.0) } else { f32(0.0) }
}

pub fn (lit BoolLiteral) int() int {
	return if lit.val.to_lower() == 'true' { 1 } else { 0 }
}

pub fn (lit BoolLiteral) string() string {
	return if lit.val.to_lower() == 'true' { "true" } else { "false" }
}

pub struct Ident {
pub:
	name				string
	pos					token.Position
pub mut:
	typ					Type
	is_object_property	bool
	is_object_var		bool
}

pub struct RedefinedOptionalArg {
pub:
	name	string
	pos		token.Position
pub mut:
	expr	Expr
	is_used	bool // used to search for unused redefined optional arguments
}

pub struct CallArg {
pub:
	pos		token.Position
pub mut:
	expr	Expr
	typ		Type
}

pub struct CallExpr {
pub mut:
	pos				token.Position
	left			Expr	// `user` in `user.register()`
	obj_name		string	// `Foo` in Foo.name()
	name			string	// `name` in bar.name()
	args			[]CallArg
	redefined_args	map[string]RedefinedOptionalArg // `d = 2.0` in `Foo(5.0, 2.4, d = 2.0)`
	return_type		Type
	is_global		bool
	is_native		bool
	is_array_find	bool
}

// `foo.bar`
pub struct SelectorExpr {
pub mut:
	pos			token.Position
	expr		Expr	// `expr` in expr.field_name
	field_name	string
	typ			Type
}

//arr[1]
pub struct IndexExpr {
pub:
	pos		token.Position
pub mut:
	left	Expr
	index	Expr
	typ		Type
}

pub struct ParExpr {
pub:
	pos  token.Position
pub mut:
	expr Expr
}

// See: token.Kind.is_prefix
pub struct PrefixExpr {
pub:
	op			token.Kind
	pos			token.Position
pub mut:
	right		Expr
	//checker
	right_type	Type
}

pub struct ArrayInit {
pub:
	typ			Type
	elem_type	Type
	pos			token.Position
pub mut:
	len			Expr
}

pub fn (expr Expr) is_literal() bool {
	match expr {
		FloatLiteral, 
		IntegerLiteral, 
		BoolLiteral,
		StringLiteral,
		NoneLiteral {
			return true
		}
		else {
			return false 
		}
	}
} 

pub fn (expr Expr) position() token.Position {
	// all uncommented have to be implemented
	match expr {
		CallExpr, FloatLiteral, Ident, IndexExpr, IntegerLiteral, BoolLiteral,
		SelectorExpr, StringLiteral, ParExpr, PrefixExpr, ArrayInit, NoneLiteral, CastExpr {
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