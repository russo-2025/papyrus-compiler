module token

pub struct Token {
pub:
	kind		Kind // the token number/enum; for quick comparisons
	lit			string // literal representation of the token
	line_nr		int // the line number in the source where the token occured
	pos			int // the position of the token in scanner text
	len			int // length of the literal
	tidx		int // the index of the token
	lt_escaped	bool
}

pub enum Kind {
	unknown
	eof

	comment

	name // user
	number // 123
	string // 'foo'

	// + - * / %
	plus
	minus
	mul
	div
	mod

	logical_and // &&
	logical_or // ||
	not // !

	comma // ,
	dot //.

	//= += -= /= *= %=
	assign
	plus_assign
	minus_assign
	div_assign
	mult_assign
	mod_assign

	//()
	lpar
	rpar
	//[]
	lsbr
	rsbr
	//{}
	lcbr 
	rcbr
	
	// == != > < >= <=
	eq
	ne
	gt
	lt
	ge
	le

	//keywords
	keyword_beg

	key_bool
	key_int
	key_string
	key_float

	key_if
	key_elseif
	key_else
	key_endif
	key_while
	key_endwhile
	key_new
	key_return

	key_event
	key_endevent
	key_function
	key_endfunction
	key_property
	key_endproperty
	key_state
	key_endstate

	key_false
	key_true

	key_global
	key_auto
	key_readonly
	key_hidden
	key_conditional
	key_native

	key_as
	key_import
	key_none
	key_parent
	key_scriptname
	key_scriptplus
	key_extends
	key_self

	keyword_end

	_end_
}

const (
	token_str = build_token_str()
	keywords  = build_keys()
)

// build_keys genereates a map with keywords' string values:
// Keywords['return'] == .key_return
fn build_keys() map[string]Kind {
	//assert token_str.len > 0 // call build_keys before calling build_token_str
	
	mut res := map[string]Kind{}
	for t in int(Kind.keyword_beg) + 1 .. int(Kind.keyword_end) {
		tk := unsafe { Kind(t) }
		key := token.token_str[tk]
		res[key] = tk
	}
	return res
}

fn build_token_str() []string {
	mut s := []string{len: int(Kind._end_)}
	
	s[Kind.unknown] = 'unknown'
	s[Kind.eof] = 'eof'

	s[Kind.comment] = 'comment'

	s[Kind.name] = 'name'
	s[Kind.number] = 'number'
	s[Kind.string] = 'string'
	
	s[Kind.plus] = '+'
	s[Kind.minus] = '-'
	s[Kind.mul] = '*'
	s[Kind.div] = '/'
	s[Kind.mod] = '%'

	s[Kind.logical_and] = '&&'
	s[Kind.logical_or] = '||'
	s[Kind.not] = '!'

	s[Kind.comma] = ','
	s[Kind.dot] = '.'

	s[Kind.assign] = '='
	s[Kind.plus_assign] = '+='
	s[Kind.minus_assign] = '-='
	s[Kind.div_assign] = '/='
	s[Kind.mult_assign] = '*='
	s[Kind.mod_assign] = '%='

	s[Kind.lpar] = '('
	s[Kind.rpar] = ')'
	s[Kind.lsbr] = '['
	s[Kind.rsbr] = ']'
	s[Kind.lcbr] = '{'
	s[Kind.rcbr] = '}'
	
	s[Kind.eq] = '=='
	s[Kind.ne] = '!='
	s[Kind.gt] = '>'
	s[Kind.lt] = '<'
	s[Kind.ge] = '>='
	s[Kind.le] = '<='

	s[Kind.key_as] = 'as'
	s[Kind.key_auto] = 'auto'
	s[Kind.key_readonly] = 'autoreadonly'
	s[Kind.key_bool] = 'bool'
	s[Kind.key_else] = 'else'
	s[Kind.key_elseif] = 'elseif'
	s[Kind.key_endevent] = 'endevent'
	s[Kind.key_endfunction] = 'endfunction'
	s[Kind.key_endif] = 'endif'
	s[Kind.key_endproperty] = 'endproperty'
	s[Kind.key_endstate] = 'endstate'
	s[Kind.key_endwhile] = 'endwhile'
	s[Kind.key_event] = 'event'
	s[Kind.key_extends] = 'extends'
	s[Kind.key_false] = 'false'
	s[Kind.key_float] = 'float'
	s[Kind.key_function] = 'function'
	s[Kind.key_global] = 'global'
	s[Kind.key_if] = 'if'
	s[Kind.key_import] = 'import'
	s[Kind.key_int] = 'int'
	s[Kind.key_native] = 'native'
	s[Kind.key_new] = 'new'
	s[Kind.key_none] = 'none'
	s[Kind.key_parent] = 'parent'
	s[Kind.key_property] = 'property'
	s[Kind.key_return] = 'return'
	s[Kind.key_scriptname] = 'scriptname'
	s[Kind.key_scriptplus] = 'scriptplus'
	s[Kind.key_self] = 'self'
	s[Kind.key_state] = 'state'
	s[Kind.key_string] = 'string'
	s[Kind.key_true] = 'true'
	s[Kind.key_while] = 'while'
	s[Kind.key_hidden] = 'hidden'
	s[Kind.key_conditional] = 'conditional'
	
	return s
}

pub fn key_to_token(key string) Kind {
	return Kind(keywords[key])
}

pub fn is_key(key string) bool {
	return int(key_to_token(key)) > 0
}

pub fn (t Kind) str() string {
	return token_str[t]
}

@[inline]
pub fn (tok &Token) position() Position {
	return Position{
		len: tok.len
		line_nr: tok.line_nr - 1
		pos: tok.pos
	}
}
	
pub fn (kind Kind) is_type() bool {
	return kind in [.key_bool, .key_int, .key_string, .key_float]
}
	
pub fn (kind Kind) is_flag() bool {
	return kind in [.key_global, .key_auto, .key_readonly, .key_hidden, .key_conditional, .key_native]
}

pub fn (kind Kind) is_infix() bool {
	return kind in
		[.plus, .minus, .mul, .div, .mod, .logical_and, .logical_or, .eq, .ne, .gt, .lt, .ge, .le]
}

pub fn (kind Kind) is_prefix() bool {
	return kind in
		[.minus, .not]
}

pub fn (kind Kind) is_assign() bool {
	return kind in
		[.assign, .plus_assign, .minus_assign, .div_assign, .mult_assign, .mod_assign]
}


pub enum Precedence {
	lowest
	assign // =
	logical_or // ||
	logical_and // &&
	eq // == !=
	sum // + -
	product // * /
	prefix // -X or !X
	cast
	call // func(X)
	index // array[index]
}

pub fn build_precedences() []Precedence {
	mut p := []Precedence{len: int(Kind._end_)}
	
	p[Kind.lsbr] = .index
	
	// + - * / %
	p[Kind.plus] = 	.sum
	p[Kind.minus] = .sum
	p[Kind.mul] = 	.product
	p[Kind.div] = 	.product
	p[Kind.mod] = 	.product

	// ||  &&
	p[Kind.logical_or]	=	.logical_or
	p[Kind.logical_and]	=	.logical_and

	// !
	p[Kind.not]	=	.prefix

	//.
	p[Kind.dot]			=	 .call

	//keyword as
	p[Kind.key_as]		=	 .cast

	//= += -= /= *= %=
	p[Kind.assign]		=	.assign
	p[Kind.plus_assign]	=	.assign
	p[Kind.minus_assign]	=	.assign
	p[Kind.div_assign]	=	.assign
	p[Kind.mult_assign]	=	.assign
	p[Kind.mod_assign]	=	.assign
	
	// == != > < >= <=
	p[Kind.eq]	=	.eq
	p[Kind.ne]	=	.eq
	p[Kind.gt]	=	.eq
	p[Kind.lt]	=	.eq
	p[Kind.ge]	=	.eq
	p[Kind.le]	=	.eq

	return p
}
const (
	precedences = build_precedences()
)

// precedence returns a tokens precedence if defined, otherwise lowest_prec
pub fn (tok Token) precedence() int {
	return int(precedences[tok.kind])
}