module vm

import pex

@[heap]
struct Function {
	name			string @[required]
	is_global		bool
mut:
	params			[]Param @[required]
	commands		[]Command @[required]
	stack_data		[]Value @[required]
}

struct Param {
	name	string
	typ		ValueType
}

struct Operand {
	typ				OperandType = .stack
	stack_offset	int
}

enum OperandType {
	reg_self
	reg_state

	regb1
	regb2

	regi1
	regi2
	regi3
	//regi4
	//regi5
	//regi6

	regf1
	regf2
	regf3
	//regf4
	//regf5
	//regf6

	stack
}

type Command = AddExprReg | Jump | JumpTrue | JumpFalse | PrefixExpr | CallMethod | CallStatic | InfixExpr | CastExpr | Return | Assign

struct Jump {
	offset	i32
}
struct JumpTrue {
	value	Operand
	offset	i32
}
struct JumpFalse {
	value	Operand
	offset	i32
}

struct PrefixExpr {
	op		pex.OpCode
	result	Operand
	value	Operand
}

struct AddExprReg {
	result	OperandType
	value1	OperandType
	value2	OperandType
}

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
	name		string
	object		string
	result		Operand
	args		[]Operand
	cache_func	?&Function
}

struct CallMethod {
mut:
	name	string
	self	Operand
	result	Operand
	args	[]Operand
}