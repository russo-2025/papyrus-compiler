module vm

pub struct Value {
pub mut:
	typ			ValueType = .none
	data		ValueData = ValueData{ bool: false }
	is_temp		bool
	is_used		bool
}

pub struct Object {
	name string
}

pub enum ValueType {
	none
	bool
	integer
	float
	string
	object // TODO
	array // TODO
}

union ValueData {
mut:
	string	string
	integer	i32
	float	f32
	bool	bool
	object	voidptr // TODO
	array	voidptr // TODO
}

const none_value = Value{
	typ: .none,
	data: ValueData{ bool: false }
}

@[inline]
pub fn create_value_typ(typ ValueType) Value {
	match typ {
		.none { return none_value }
		.bool {
			return Value{
				typ: .bool,
				data: ValueData{ bool: false }
			}
		}
		.integer {
			return Value{
				typ: .integer,
				data: ValueData{ integer: i32(0) }
			}
		}
		.float {
			return Value{
				typ: .float,
				data: ValueData{ float: f32(0) }
			}
		}
		.string {
			return Value{
				typ: .string,
				data: ValueData{ string: "" }
			}
		}
		.object { return none_value } // TODO?
		.array { panic("TODO") }
	}
}

@[inline]
pub fn create_value_data[T](v T) Value {
	// TODO none
	$if T is bool {
		return Value{
			typ: .bool,
			data: ValueData{ bool: v }
		}
	}
	$else $if T is i32 {
		return Value{
			typ: .integer,
			data: ValueData{ integer: v }
		}
	}
	$else $if T is f32 {
		return Value{
			typ: .float,
			data: ValueData{ float: v }
		}
	}
	$else $if T is string {
		return Value{
			typ: .string,
			data: ValueData{ string: v }
		}
	}
	//TODO object
	//TODO array
	$else  {
		$compile_error("invalid T type in fn create_value")
	}
}

fn (mut v Value) clear() {
	match v.typ {
		.none {
			v.data.bool = false
		}
		.integer {
			v.data.integer = 0
		}
		.float {
			v.data.float = 0.0
		}
		.bool {
			v.data.bool = false
		}
		.string {
			v.data.string = ""
		}
		.object {
			panic("TODO")
		}
		.array {
			panic("TODO")
		}
	}
}

pub fn (mut v Value) set[T](value T) {
	$if T is bool {
		assert v.typ == .bool
		v.set_data(value)
	}
	$else $if T is i32 {
		assert v.typ == .integer
		v.set_data(value)
	}
	$else $if T is f32 {
		assert v.typ == .float
		v.set_data(value)
	}
	$else $if T is string {
		assert v.typ == .string
		unsafe { v.data.string = value }
	}
	//TODO object
	//TODO array
	$else {
		$compile_error("invalid Value.set")
	}
}

pub fn (v Value) get[T]() T {
	$if T is bool {
		assert v.typ == .bool
		return unsafe { v.data.bool }
	}
	$else $if T is i32 {
		assert v.typ == .integer
		return unsafe { v.data.integer }
	}
	$else $if T is f32 {
		assert v.typ == .float
		return unsafe { v.data.float }
	}
	$else $if T is string {
		assert v.typ == .string
		return unsafe { v.data.string }
	}
	//TODO object
	//TODO array
	$else {
		$compile_error("invalid Value.get")
	}
}

fn (mut v Value) set_data[T](value T) {
	$if T is bool {
		unsafe { v.data.bool = value }
	}
	$else $if T is i32 {
		unsafe { v.data.integer = value }
	}
	$else $if T is f32 {
		unsafe { v.data.float = value }
	}
	$else $if T is string {
		unsafe { v.data.string = value }
	}
	//TODO object
	//TODO array
	$else {
		$compile_error("invalid Value.set_data")
	}
}

pub fn (mut v Value) cast[T]() {
	$if T is bool {
		match v.typ {
			.none { v.set_data[bool](false) }
			.bool { panic("invalid cast bool -> bool") }
			.integer { v.set_data[bool](v.get[i32]() != 0) }
			.float { v.set_data[bool](v.get[f32]() != 0.0) }
			.string { v.set_data[bool](v.get[string]().len > 0) }
			.object { panic("TODO object -> bool") }
			.array { panic("TODO array -> bool") }
		}

		v.typ = .bool
	}
	$else $if T is i32 {
		match v.typ {
			.bool { v.set_data[i32](if v.get[bool]() { i32(1) } else { i32(0) }) }
			.integer { panic("invalid cast i32 -> i32") }
			.float { v.set_data[i32](i32(v.get[f32]())) } // TODO f32 to i32
			.string { v.set_data[i32](v.get[string]().i32()) }
			else { panic("invalid cast ${v.typ} -> i32") }
		}

		v.typ = .integer
	}
	$else $if T is f32 {
		match v.typ {
			.bool { v.set_data[f32](if v.get[bool]() { f32(1.0) } else { f32(0.0) }) }
			.integer { v.set_data[f32](f32(v.get[i32]())) } // TODO f32 to i32
			.float { panic("invalid cast f32 -> f32") }
			.string { v.set_data[f32](v.get[string]().f32()) }
			else { panic("invalid cast ${v.typ} -> f32") }
		}

		v.typ = .float
	}
	$else $if T is string {
		match v.typ {
			.none { panic("TODO array -> bool") }
			.bool { v.set_data[string](if v.get[bool]() { "True" } else { "False" }) }
			.integer { v.set_data[string](v.get[i32]().str()) }
			.float { v.set_data[string](v.get[f32]().str()) }
			.string { panic("invalid cast string -> string") }
			.object { panic("TODO object -> bool") }
			.array { panic("TODO array -> bool") }
		}

		v.typ = .string
	}
	//object
	//array
	$else {
		$compile_error("invalid Value.cast")
	}
}
