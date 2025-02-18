module vm

import pex

@[heap]
pub struct Object {
pub:
	info		&Script = unsafe { voidptr(0) }
	cur_state	&State = unsafe { voidptr(0) }
}

@[heap]
pub struct Script {
pub:
	name			string @[required]
	parent			?&Script
pub mut:
	auto_state		&State = unsafe { voidptr(0) }
	states			[]State @[required]
	variables		[]Variable @[required]
	properties		[]Property @[required]
}

pub struct Variable {}

pub struct Property {}

pub struct State {
pub:
	name	string
	is_auto	bool
pub mut:
	funcs	[]Function
}

pub struct NativeFunction {
pub:
	object_name	string @[required]
	name		string @[required]
	is_global	bool
	cb			fn(ctx ExecutionContext, self Value, args []Value)!Value @[required]
}

@[heap]
pub struct Function {
pub:
	name			string @[required]
	is_global		bool
	is_native		bool
pub mut:
	params			[]Param @[required]
	commands		[]Command @[required]
	stack_data		[]Value @[required]
}

pub struct Param {
pub:
	name	string
	typ		ValueType
}

pub struct Operand {
pub:
	typ				OperandType = .stack
	stack_offset	int
}

pub enum OperandType {
	reg_self
	reg_state

	regb1
	regb2

	regi1
	regi2
	regi3

	regf1
	regf2
	regf3
	registers_count

	none_value
	
	stack
}

pub type Command = Jump | PrefixExpr | Call | InfixExpr | CastExpr | Return | Assign
	| ArrayCreate | GetArrayLength | GetArrayElement | SetArrayElement | FindArrayElement

pub struct Jump {
pub:
	offset			i32
	value			Operand
	with_condition	bool
	true_condition	bool
}

pub struct PrefixExpr {
pub:
	op		pex.OpCode
	result	Operand
	value	Operand
}

pub struct InfixExpr {
pub:
	op		pex.OpCode
	result	Operand
	value1	Operand
	value2	Operand
}

pub struct Return {
pub:
	value	Operand
}

pub struct CastExpr {
pub:
	result	Operand
	value	Operand
}

pub struct Assign {
pub:
	result	Operand
	value	Operand
}

pub struct Call {
pub:
	name				string
	object				string // for global
	self				Operand // for method
	result				Operand
	args				[]Operand
	is_global			bool
	is_parent_call		bool
pub mut:
	is_native			bool 
	cache_func			?&Function
	native_cache_func	?&NativeFunction
}

pub struct ArrayCreate {
pub:
	result	Operand
	size	Operand
}

pub struct GetArrayLength {
pub:
	result	Operand
	array	Operand
}

pub struct GetArrayElement {
pub:
	result	Operand
	array	Operand
	index	Operand
}

pub struct SetArrayElement {
pub:
	array	Operand
	index	Operand
	value	Operand
}

pub struct FindArrayElement {
pub:
	result		Operand
	array		Operand
	value		Operand
	start_index	Operand
	is_reverse	bool
}