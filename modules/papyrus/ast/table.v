module ast

import papyrus.token
//import os
//import json
//import x.json2

[heap]
pub struct Table {
pub mut:
	types				[]TypeSymbol // aka type_symbols
	type_idxs			map[string]int

	fns					map[string]Fn

	allow_override		bool
}
/*
pub fn (t Table) to_json() string {
	//result := json.encode_pretty(t)
	//result := json2.encode_pretty[Table](t)
	return ""
}

pub fn (t Table) save_as_json(file string) {
	os.write_file(file, t.to_json()) or { panic(err) }
}*/

pub struct Param {
pub mut:
	name			string
	typ				Type
	is_optional		bool
	default_value	string
	
}

pub struct State {
pub:
	name		string
	obj_name	string
	is_auto		bool //flag
	pos			token.Position
pub mut:
	methods		[]Fn
	//props		map[string]Prop
	//states	map[string]State
	//vars		map[string]Var
}

pub struct Prop {
pub:
	name				string
	obj_name			string
	auto_var_name		string
	typ					Type
	pos					token.Position
	is_auto				bool //flag
}

pub struct Var {
pub:
	name				string
	obj_name			string
	typ					Type
	pos					token.Position
}
	
pub struct Fn {
pub:
	return_type		Type
	obj_name		string
	state_name		string
	pos				token.Position
pub mut:
	params			[]Param
	name			string
	lname			string //in lowercase
	is_global		bool
	is_native		bool
}

pub fn new_table() &Table {
	mut t := &Table{}
	t.register_builtin_type_symbols()
	return t
}

pub fn (t &Table) typ_is_parent(child_type int, parent_type int) bool {
	child_sym := t.get_type_symbol(child_type)
	parent_sym := t.get_type_symbol(parent_type)

	if child_sym.parent_idx == 0 {
		return false
	}

	mut tsym := t.get_type_symbol(child_sym.parent_idx)
	for {
		if tsym.name == parent_sym.name {
			return true
		}

		if tsym.parent_idx != 0 {
			tsym = t.get_type_symbol(tsym.parent_idx)
			continue
		}
		
		break
	}

	return false
}

pub fn (t &Table) has_fn(obj_name string, name string) bool {
	key := obj_name.to_lower() + "." + name.to_lower()
	
	if _ := t.fns[key] {
		return true
	}
	
	return false
}

pub fn (t &Table) find_fn(obj_name string, name string) ?Fn {
	key := obj_name.to_lower() + "." + name.to_lower()
	
	if f := t.fns[key] {
		return f
	}
	
	return none
}

pub fn (mut t Table) register_fn(new_fn Fn) {
	t.fns[new_fn.obj_name.to_lower() + "." + new_fn.name.to_lower()] = new_fn
}

pub fn (mut t Table) add_placeholder_type(name string) Type {
	ph_type := TypeSymbol {
		kind:		.placeholder
		name:		name
		methods:	[]Fn{}
	}

	return t.register_type_symbol(ph_type)
}

[inline]
pub fn (mut t Table) register_type_symbol(typ TypeSymbol) Type {
	existing_idx := t.type_idxs[typ.name.to_lower()]
	if existing_idx > 0 {
		ex_type := t.types[existing_idx]
		match ex_type.kind {
			.placeholder {
				// override placeholder
				t.types[existing_idx] = TypeSymbol{
					...typ
					methods: ex_type.methods
				}
				return existing_idx
			}
			else {
				if t.allow_override {
					t.types[existing_idx] = TypeSymbol{
						...typ
						methods: ex_type.methods
					}
					return existing_idx
				}
				else {
					panic("Warning: override type(${typ.name}) - table.register_type_symbol()")
					return existing_idx
				}
			}
		}
	}
	
	typ_idx := t.types.len
	t.types << typ
	t.type_idxs[typ.name.to_lower()] = typ_idx
	return typ_idx
}

[inline]
pub fn (t &Table) find_type_idx(name string) Type {
	return t.type_idxs[name.to_lower()]
}

pub fn (t &Table) known_type(name string) bool {
	return t.find_type_idx(name) != 0
}

pub fn (mut t Table) find_or_add_placeholder_type(name string) Type {
	if !t.known_type(name) {
		return t.add_placeholder_type(name)
	}

	return t.find_type_idx(name)
}

[inline]
pub fn (t &Table) find_type(name string) ?&TypeSymbol {
	idx := t.type_idxs[name.to_lower()]
	if idx > 0 {
		return &t.types[idx]
	}
	return none
}

[inline]
pub fn (t &Table) get_type_symbol(typ Type) &TypeSymbol {
	idx := typ.idx()
	if idx > 0 {
		return unsafe { &t.types[idx] }
	}
	// this should never happen
	panic('get_type_symbol: invalid type (typ=$typ idx=$idx). Compiler bug.')
	return 0
}

[inline]
pub fn (t &Table) array_name(elem_type Type) string {
	elem_type_sym := t.get_type_symbol(elem_type)
	return '$elem_type_sym.name[]'
}

[inline]
pub fn (t &Table) type_is_array(typ Type) bool {
	if typ > 0 {
		sym := t.get_type_symbol(typ)
		return sym.kind == .array
	}
	
	return false
}

pub fn (mut t Table) find_or_register_array(elem_type Type) Type {
	name := t.array_name(elem_type)
	// existing
	existing_idx := t.type_idxs[name.to_lower()]
	if existing_idx > 0 {
		return existing_idx
	}
	// register
	array_type_ := TypeSymbol{
		kind: .array
		name: name
		info: Array{
			elem_type: elem_type
		}
		methods: []Fn{}
	}
	return t.register_type_symbol(array_type_)
}