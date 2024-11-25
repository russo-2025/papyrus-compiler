module eval

enum ValueType {
	none
	bool
	integer
	float
	string
	object
	array
}

union ValueData {
mut:
	string	string
	integer	i32
	float	f32
	bool	bool
	object	voidptr
	array	voidptr
}

pub struct Value {
pub mut:
	typ			ValueType = .string
	data		ValueData
	is_temp		bool
	is_used		bool
}

@[inline]
pub fn create_none_value() Value {
	return Value{
		typ: .none,
		data: ValueData{ bool: false }
		}
}

@[inline]
pub fn create_value[T](v T) Value {
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
	$else  {
		$compile_error("invalid T type in fn create_value")
	}
}

fn (mut v Value) clear() {
	match v.typ {
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
			v.data.bool = false
		}
		.none {
			v.data.bool = false
		}
		else { panic("err") }
	}
}

fn get_type_from_type_name(name string) ValueType {
	lname := name.to_lower()
	return match lname {
		"string" { .string }
		"int" { .integer }
		"float" { .float }
		"bool" { .bool }
		else { .object }
	}
}

pub fn (mut v Value) set[T](value T) {
	$if T is bool {
		assert v.typ == .bool
		unsafe { v.data.bool = value }
	}
	$else $if T is i32 {
		assert v.typ == .integer
		unsafe { v.data.integer = value }
	}
	$else $if T is f32 {
		assert v.typ == .float
		unsafe { v.data.float = value }
	}
	$else $if T is string {
		assert v.typ == .string
		unsafe { v.data.string = value }
	}
	//object
	//array
	$else $if T is &Value {
		//assert v.typ != value.typ

		match v.typ {
			.none { panic("TODO") }
			.integer {
				unsafe { v.data.integer = value.data.integer } // error: expected struct or union but not 'struct papyrus__eval__Value *'
			}
			.float {
				unsafe { v.data.float = value.data.float }
			}
			.bool {
				unsafe { v.data.bool = value.data.bool }
			}
			.string {
				unsafe { v.data.string = value.data.string }
			}
			.object { panic("TODO") }
			.array { panic("TODO") }
		}
	}
	$else {
		$compile_error("invalid cast")
	}
}

fn (v Value) get[T]() T {
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
	//object
	//array
	$else {
		$compile_error("invalid cast")
	}
}

fn (mut v Value) cast[T]() {
	$if T is bool {
		match v.typ {
			.bool { panic("invalid cast bool -> bool") }
			.integer { v.set[bool](v.get[i32]() != 0) }
			.float { v.set[bool](v.get[f32]() != 0.0) }
			.string { v.set[bool](v.get[string]().len > 0) }
			//.object {}
			//.array {}
			else { panic("TODO ${v.typ} -> bool") }
		}

		v.typ = .bool
	}
	$else $if T is i32 {
		match v.typ {
			.bool { v.set[i32](if v.get[bool]() { i32(1) } else { i32(0) }) }
			.integer { panic("invalid cast i32 -> i32") }
			.float { v.set[i32](i32(v.get[f32]())) } // TODO f32 to i32
			.string { v.set[i32](v.get[string]().i32()) }
			else { panic("invalid cast ${v.typ} -> i32") }
		}

		v.typ = .integer
	}
	$else $if T is f32 {
		match v.typ {
			.bool { v.set[f32](if v.get[bool]() { f32(1.0) } else { f32(0.0) }) }
			.integer { v.set[f32](f32(v.get[i32]())) } // TODO f32 to i32
			.float { panic("invalid cast f32 -> f32") }
			.string { v.set[f32](v.get[string]().f32()) }
			else { panic("invalid cast ${v.typ} -> f32") }
		}

		v.typ = .float
	}
	$else $if T is string {
		match v.typ {
			.bool { v.set[string](if v.get[bool]() { "True" } else { "False" }) }
			.integer { v.set[string](v.get[i32]().str()) }
			.float { v.set[string](v.get[f32]().str()) }
			.string { panic("invalid cast string -> string") }
			//.object {}
			//.array {}
			else { panic("TODO ${v.typ} -> bool") }
		}

		v.typ = .string
	}
	//object
	//array
	$else {
		$compile_error("invalid cast")
	}

/*
	val := if operand is Value { operand } else if operand is Ident { e.get_var(operand.var_id) }

	return match operand.typ {
		.bool { cast_value[bool, T](operand.data.bool) }
		.integer { cast_value[i32, T](operand.data.integer) }
		.float { cast_value[f32, T](operand.data.f32) }
		.string { cast_value[string, T](operand.data.string) }
		//.object {}
		//.array {}
		else { panic("invalid cast") }
	}*/
}

fn cast_value[T, Y](v T) {
	$if Y is f32 {
		$if T is i32 {
			return Y(v)
		}
		$else $if T is bool {
			return if v { 1.0 } else { 0.0 } 
		}
		$else $if T is string {
			// TODO
			return v.f32()
		}
		$else {
			$compile_error("invalid cast")
		}
	}
	$else $if Y is i32 {
		$if T is f32 {
			return Y(v)
		}
		$else $if T is bool {
			return if v { 1 } else { 0 }
		}
		$else $if T is string {
			// TODO
			return v.i32()
		}
		$else {
			$compile_error("invalid cast")
		}
	}
	$else $if Y is bool {
		$if T is i32 {
			return v != 0
		}
		$else $if T is f32 {
			return v != 0
		}
		$else $if T is string {
			return v.len > 0
		}
		//$else $if T is object {} // True if the object isn't None
		//$else $if T is array {} // True if the array is 1 element or longer in size
		$else {
			$compile_error("invalid cast")
		}
	}
	$else $if Y is string {
		$if T is i32 {
			return v.str()
		}
		$else $if T is f32 {
			return v.str()
		}
		$else $if T is bool {
			return if v { "True" } else { "False" }
		}
		//$else $if T is object {} // A string representing the object in the format: "[ScriptName <EditorID (FormID)>]"
		//$else $if T is array {} // A list of elements in the array separated by commas, formatted as above, and possibly truncated with a "..." if too long for the internal string buffer.
		$else {
			$compile_error("invalid cast")
		}
	}
	/*$else $if Y is object { // TODO
		$if T is object {}
		$else {
			$compile_error("invalid cast") 
		}
	}
	$else $if Y is array {
		$compile_error("invalid cast")
	}*/
}