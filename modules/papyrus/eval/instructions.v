module eval

import pex

struct State {

}

struct Object {
mut:
	state	State
}

@[heap]
struct Function {
	name			string
	is_global		bool
mut:
	instructions	[]Instruction
}
/*
struct Instruction {
	op			pex.OpCode
mut: 
	operands	[]&Value
}*/

type Instruction = CallMethod | InfixExpr | CastExpr | Return | Assign

struct InfixExpr {
mut:
	op		pex.OpCode
	result	&Value
	value1		&Value
	value2		&Value
}

struct Return {
mut:
	value	&Value
}

struct CastExpr {
mut:
	result	&Value
	value	&Value
}

struct Assign {
mut:
	result	&Value
	value	&Value
}

struct CallMethod {
mut:
	name	string
	self	&Value
	result	&Value
	args	[]&Value
}