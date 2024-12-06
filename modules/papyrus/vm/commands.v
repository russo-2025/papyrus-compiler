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
	//typ				OperandType = .stack
	stack_offset	int
}
/*
enum OperandType as u8 {
	reg_i1
	reg_i2
	reg_i3
	reg_i4

	reg_f1
	reg_f2
	reg_f3
	reg_f4
	
	int_value
	float_value

	stack
}*/

type Command = Jump | JumpTrue | JumpFalse | PrefixExpr | CallMethod | CallStatic | InfixExpr | CastExpr | Return | Assign

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