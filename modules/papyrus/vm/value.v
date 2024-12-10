module vm

pub struct Value {
pub mut:
	typ			ValueType = .none
	data		ValueData = ValueData{ bool: false }
	is_temp		bool
	is_used		bool
}

pub enum ValueType {
	none
	bool
	i32
	//u32
	f32
	string
	object
	array // TODO
}

union ValueData {
mut:
	bool	bool
	i32		i32
	//u32		u32
	f32		f32
	string	string
	//ptr		voidptr
	object	&Object = voidptr(0)
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
		.i32 {
			return Value{
				typ: .i32,
				data: ValueData{ i32: i32(0) }
			}
		}
		.f32 {
			return Value{
				typ: .f32,
				data: ValueData{ f32: f32(0) }
			}
		}
		.string {
			return Value{
				typ: .string,
				data: ValueData{ string: "" }
			}
		}
		.object {
			return Value{
				typ: .object,
				data: ValueData{ object: voidptr(0) }
			}
		}
		.array { panic("TODO") }
	}
}

@[inline]
pub fn create_value_data[T](v T) Value {
	$if T is bool {
		return Value{
			typ: .bool,
			data: ValueData{ bool: v }
		}
	}
	$else $if T is i32 {
		return Value{
			typ: .i32,
			data: ValueData{ i32: v }
		}
	}
	$else $if T is f32 {
		return Value{
			typ: .f32,
			data: ValueData{ f32: v }
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
		.none {
			v.data.bool = false
		}
		.i32 {
			v.data.i32 = 0
		}
		.f32 {
			v.data.f32 = 0.0
		}
		.bool {
			v.data.bool = false
		}
		.string {
			v.data.string = ""
		}
		.object {
			v.data.object = voidptr(0)
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
		assert v.typ == .i32
		v.set_data(value)
	}
	$else $if T is f32 {
		assert v.typ == .f32
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

pub fn (mut v Value) set_object(obj &Object) {
	assert v.typ == .object
	v.data.object = obj
}

pub fn (v Value) get_object() &Object {
	assert v.typ == .object
	assert unsafe { v.data.object } != voidptr(0)
	return unsafe { v.data.object }
}

pub fn (v Value) get[T]() T {
	$if T is bool {
		assert v.typ == .bool
		return unsafe { v.data.bool }
	}
	$else $if T is i32 {
		assert v.typ == .i32
		return unsafe { v.data.i32 }
	}
	$else $if T is f32 {
		assert v.typ == .f32
		return unsafe { v.data.f32 }
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
		unsafe { v.data.i32 = value }
	}
	$else $if T is f32 {
		unsafe { v.data.f32 = value }
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