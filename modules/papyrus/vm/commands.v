module vm

import pex

@[heap]
struct Function {
	name			string @[required]
	is_global		bool
mut:
	commands		[]Command @[required]
	params			[]Value
	stack_data	[]Value
}

type Command = /*InitFnStack | */CallMethod | CallStatic | InfixExpr | CastExpr | Return | Assign

struct Operand {
	stack_offset	int
}
/*
struct InitFnStack {
mut:
	data	[]Value
}*/

struct InfixExpr {
mut:
	op		pex.OpCode
	result	Operand
	value1	Operand
	value2	Operand
}

struct Return {
mut:
	value	Operand
}

struct CastExpr {
mut:
	result	Operand
	value	Operand
}

struct Assign {
mut:
	result	Operand
	value	Operand
}

struct CallStatic {
mut:
	name	string
	object	string
	result	Operand
	args	[]Operand
}

struct CallMethod {
mut:
	name	string
	self	Operand
	result	Operand
	args	[]Operand
}