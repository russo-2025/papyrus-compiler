module vm

import pex

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
	//native_cache_func	?&NativeFunction 
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