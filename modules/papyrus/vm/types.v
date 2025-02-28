module vm

@[heap]
pub struct Object {
mut:
	cur_state	&State = unsafe { voidptr(0) }
	auto_state	&State = unsafe { voidptr(0) }
pub:
	info		&Script = unsafe { voidptr(0) }
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

fn (info Script) find_state_by_name(name string) ?&State {
	lname := name.to_lower()

	if info.auto_state.name.to_lower() == name {
		return info.auto_state
	}

	for i in 0..info.states.len {
		if info.states[i].name.to_lower() == lname {
			return &info.states[i]
		}
	}

	return none
}

pub struct Variable {}

pub struct Property {}

pub struct State {
pub:
	name	string @[required]
	is_auto	bool
pub mut:
	funcs	[]Function
}

type NativeFunctionCallBack = fn(ctx ExecutionContext, self Value, args []Value)!Value

pub struct NativeFunction {
pub:
	object_name	string @[required]
	name		string @[required]
	is_global	bool
	cb			NativeFunctionCallBack @[required]
}

struct FunctionBody {
pub mut:
	commands		[]Command @[required]
	stack_data		[]Value @[required]
}

@[heap]
pub struct Function {
pub:
	name			string @[required]
	is_global		bool
	is_native		bool
pub mut:
	params			[]Param @[required]
	states			[]FunctionBody
	cb				NativeFunctionCallBack = voidptr(0)
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