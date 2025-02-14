module vm

import math
import strings

pub struct Value {
pub mut:
	typ			ValueType = ValueType{ raw: "none", typ: .none }
	data		ValueData = ValueData{ bool: false }
	is_temp		bool
	is_used		bool
}

struct ValueType {
pub:
	raw			string
	typ			BasicValueType
	elem_typ	BasicValueType = .none
}

enum BasicValueType {
	none
	bool
	i32
	//u32
	f32
	string
	object
	array
}

union ValueData {
mut:
	bool	bool
	i32		i32
	//u32	u32
	f32		f32
	string	string
	//ptr	voidptr
	object	&Object = unsafe { voidptr(0) }
	array	[]Value = []Value{}
}

type VmArrayIndex = i32

fn (i VmArrayIndex) u32() u32 {
	return u32(i)
}

fn (i VmArrayIndex) int() int {
	return int(i)
}

@[inline]
pub fn (ctx ExecutionContext) create_bool(data bool) Value {
	return Value{
		typ: ValueType{ raw: "bool", typ: .bool },
		data: ValueData{ bool: data }
	}
}

@[inline]
pub fn (ctx ExecutionContext) create_int(data i32) Value {
	return Value{
		typ: ValueType{ raw: "int", typ: .i32 },
		data: ValueData{ i32: data }
	}
}

@[inline]
pub fn (ctx ExecutionContext) create_index(data VmArrayIndex) Value {
	return Value{
		typ: ValueType{ raw: "int", typ: .i32 },
		data: ValueData{ i32: data }
	}
}

@[inline]
pub fn (ctx ExecutionContext) create_float(data f32) Value {
	return Value{
		typ: ValueType{ raw: "float", typ: .f32 },
		data: ValueData{ f32: data }
	}
}

@[inline]
pub fn (ctx ExecutionContext) create_string(data string) Value {
	return Value{
		typ: ValueType{ raw: "string", typ: .string },
		data: ValueData{ string: data }
	}
}

@[inline]
// TODO rename .......
pub fn (ctx ExecutionContext) create_value_none_object_from_info(info &Script) Value {
	assert info.name != ""
	assert info.auto_state != voidptr(0)

	mut obj_value := Value{
		typ: ValueType{ raw: info.name.to_lower(), typ: .object },
		data: ValueData{ object: voidptr(0) }
	}
	
	return obj_value
}

@[inline]
// TODO rename .......
pub fn (mut ctx ExecutionContext) create_value_none_object_from_script_name(script_name string) Value {
	info := ctx.find_script(script_name) or { panic("script with name `${script_name}` not found") }
	return ctx.create_value_none_object_from_info(info)
}

@[inline]
pub fn (ctx ExecutionContext) create_array(typ ValueType) Value {
	assert typ.typ == .array
	assert typ.raw.ends_with("[]")
	assert !typ.raw.all_before_last("[]").ends_with("[]") // array in array unsupported 

	return Value{
		typ: typ,
		data: ValueData{ array: []Value{} }
	}
}

fn (mut self Value) clear() {
	match self.typ.typ {
		.none {
			self.data.bool = false
		}
		.i32 {
			self.data.i32 = 0
		}
		.f32 {
			self.data.f32 = 0.0
		}
		.bool {
			self.data.bool = false
		}
		.string {
			self.data.string = ""
		}
		.object {
			self.data.object = voidptr(0)
		}
		.array {
			self.data.array = []Value{}
		}
	}
}

fn (mut ctx ExecutionContext) array_resize(mut value Value, new_size_value Value) {
	assert value.typ.typ == .array

	new_size := new_size_value.get[VmArrayIndex]()

	init_value := match value.typ.elem_typ {
		.none {
			panic("WTF")
			ctx.none_value // WTF TODO issue
		}
		.bool { ctx.create_bool(false) }
		.i32 { ctx.create_int(0) }
		.f32 { ctx.create_float(0.0) }
		.string { ctx.create_string("") }
		.object { ctx.create_value_none_object_from_script_name(value.typ.raw.all_before("[]")) }
		.array {
			panic("Array in Array unsupported")
			ctx.none_value // WTF TODO issue
		}
	}
	
	value.data.array = []Value{ cap: new_size.int(), len: new_size.int(), init: init_value }
}

pub fn (self Value) get_array() []Value {
	assert self.typ.typ == .array
	assert unsafe { self.data.array } != voidptr(0)
	return unsafe { self.data.array }
}

pub fn (mut self Value) set_array(arr []Value) {
	assert self.typ.typ == .array
	unsafe { self.data.array = arr }
}

pub fn (self Value) get_array_element(index VmArrayIndex) Value {
	assert self.typ.typ == .array
	assert index.u32() < unsafe { self.data.array.len }
	return  unsafe { self.data.array[index] }
}

pub fn (mut self Value) set_array_element(value_index Value, value Value) {
	assert self.typ.typ == .array
	index := value_index.get[VmArrayIndex]()
	assert index.u32() < unsafe { self.data.array.len }
	unsafe { self.data.array[index] = value }
}

pub fn (self Value) get_array_length() VmArrayIndex {
	assert self.typ.typ == .array
	return unsafe { self.data.array.len }
}

pub fn (self Value) object_is_none() bool {
	assert self.typ.typ == .object
	return unsafe { self.data.object } == voidptr(0)
}

pub fn (self Value) get_object() &Object {
	assert self.typ.typ == .object
	assert unsafe { self.data.object } != voidptr(0)
	return unsafe { self.data.object }
}

pub fn (mut self Value) set_object(obj &Object) {
	assert self.typ.typ == .object
	unsafe { self.data.object = obj }
}

@[inline]
fn (mut self Value) set_object_none() {
	assert self.typ.typ == .object
	unsafe { self.data.object = voidptr(0) }
}

@[inline]
fn (mut self Value) bind_object(object &Object) {
	assert self.typ.typ == .object
	assert self.typ.raw == object.info.name
	assert object != voidptr(0)

	self.data.object = object
}

@[inline]
fn (self Value) to_array_index() VmArrayIndex {
	assert self.typ.typ == .i32
	return self.get[VmArrayIndex]()
}

@[inline]
fn (self Value) to_string() string {
	match self.typ.typ {
		.none { return "None" }
		.bool { return unsafe { if self.data.bool { "True" } else { "False" } } }
		.i32 { return unsafe { self.data.i32.str() } }
		.f32 { return unsafe { self.data.f32.str() } }
		.string { return unsafe { "\"${self.data.string}\"" } }
		.object { return "[ScriptName <EditorID (FormID)>]" } // TODO
		.array {
			mut res := strings.new_builder(30)
			res.write_string("[ ")

			len := math.min(15, self.get_array_length())

			for k := 0 ; k < len; k++ {
				element_value := self.get_array_element(k)
				res.write_string(element_value.to_string())

				if k == len - 1 {
					res.write_string(" ")
				}
				else {
					res.write_string(", ")
				}
			}

			if self.get_array_length() > 15 {
				res.write_string("...")
			}

			res.write_string(" ]")

			return res.str()
		}
	}
}

fn (a Value) == (b Value) bool {
	assert a.typ.typ == b.typ.typ
	assert a.typ.raw == b.typ.raw

	match a.typ.typ {
		.none { panic("TODO") }
		.bool { return a.get[bool]() == b.get[bool]() }
		.i32 { return a.get[i32]() == b.get[i32]() }
		.f32 { return a.get[f32]() == b.get[f32]() }
		.string { return a.get[string]() == b.get[string]() } // TODO ???
		.object { return unsafe { voidptr(a.data.object) == voidptr(b.data.object) } }
		.array { panic("WTF") }
	}
}

pub fn (mut v Value) set[T](value T) {
	$if T is bool {
		assert v.typ.typ == .bool
		v.set_data(value)
	}
	$else $if T is i32 {
		assert v.typ.typ == .i32
		v.set_data(value)
	}
	$else $if T is f32 {
		assert v.typ.typ == .f32
		v.set_data(value)
	}
	$else $if T is string {
		assert v.typ.typ == .string
		unsafe { v.data.string = value }
	}
	$else $if T is VmArrayIndex {
		assert v.typ.typ == .i32
		v.set_data(value)
	}
	//TODO object
	//TODO array
	$else {
		$compile_error("invalid Value.set")
	}
}

pub fn (self Value) get[T]() T {
	$if T is bool {
		assert self.typ.typ == .bool
		return unsafe { self.data.bool }
	}
	$else $if T is i32 {
		assert self.typ.typ == .i32
		return unsafe { self.data.i32 }
	}
	$else $if T is f32 {
		assert self.typ.typ == .f32
		return unsafe { self.data.f32 }
	}
	$else $if T is string {
		assert self.typ.typ == .string
		return unsafe { self.data.string }
	}
	$else $if T is VmArrayIndex {
		assert self.typ.typ == .i32
		return unsafe { self.data.i32 }
	}
	//TODO object
	//TODO array
	$else {
		$compile_error("invalid Value.get")
	}
}

fn (mut self Value) set_data[T](value T) {
	$if T is bool {
		assert self.typ.typ == .bool
		unsafe { self.data.bool = value }
	}
	$else $if T is i32 {
		assert self.typ.typ == .i32
		unsafe { self.data.i32 = value }
	}
	$else $if T is f32 {
		assert self.typ.typ == .f32
		unsafe { self.data.f32 = value }
	}
	$else $if T is string {
		assert self.typ.typ == .string
		unsafe { self.data.string = value }
	}
	$else $if T is VmArrayIndex {
		assert self.typ.typ == .i32
		unsafe { self.data.i32 = value }
	}
	//TODO object
	//TODO array
	$else {
		$compile_error("invalid Value.set_data")
	}
}