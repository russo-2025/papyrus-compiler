module ast

import papyrus.token

[heap]
pub struct Table {
pub mut:
	object_names		[]string
	types				[]TypeSymbol // aka type_symbols
	type_idxs			map[string]int

	fns					map[string]Fn
	props				map[string]Prop
	states				map[string]State
}

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
	
pub struct Fn {
pub:
	params			[]Param
	return_type		Type
	obj_name		string
	state_name		string
	pos				token.Position
pub mut:
	name			string
	lname			string //in lowercase
	is_global		bool
	is_native		bool
}

pub fn (t Table) has_object(name string) bool {
	return name.to_lower() in t.object_names
}

pub fn (mut t Table) register_object(name string) {
	s := name.to_lower()
	
	if s !in t.object_names {
		t.object_names << s
	}
}

pub fn new_table() &Table {
	mut t := &Table{}
	t.register_builtin_type_symbols()
	return t
}

pub fn (t &Table) has_state(obj_name string, name string) bool {
	key := obj_name.to_lower() + "." + name.to_lower()
	
	if _ := t.states[key] {
		return true
	}
	
	return false
}

pub fn (t &Table) find_state(obj_name string, name string) ?State {
	key := obj_name.to_lower() + "." + name.to_lower()
	
	if s := t.states[key] {
		return s
	}
	
	return none
}

pub fn (mut t Table) register_state(s State) {
	t.states[s.obj_name.to_lower() + "." + s.name.to_lower()] = s
}

pub fn (t &Table) has_property(obj_name string, name string) bool {
	key := obj_name.to_lower() + "." + name.to_lower()
	
	if _ := t.props[key] {
		return true
	}
	
	return false
}

pub fn (t &Table) find_property(obj_name string, name string) ?Prop {
	key := obj_name.to_lower() + "." + name.to_lower()
	
	if p := t.props[key] {
		return p
	}
	
	return none
}

pub fn (mut t Table) register_property(p Prop) {
	t.props[p.obj_name.to_lower() + "." + p.name.to_lower()] = p
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

pub fn (mut t Table) add_placeholder_type(name string) int {
	ph_type := TypeSymbol {
		kind:		.placeholder
		name:		name
		methods:	[]Fn{}
	}

	return t.register_type_symbol(ph_type)
}

[inline]
pub fn (mut t Table) register_type_symbol(typ TypeSymbol) int {

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
			else {/*
				// builtin
				// this will override the already registered builtin types
				// with the actual v struct declaration in the source
				if (existing_idx >= string_type_idx && existing_idx <= map_type_idx)
					|| existing_idx == error_type_idx {
					if existing_idx == string_type_idx {
						// existing_type := t.types[existing_idx]
						t.types[existing_idx] = TypeSymbol{
							...typ
							kind: ex_type.kind
						}
					} else {
						t.types[existing_idx] = typ
					}
					return existing_idx
				}*/
				//panic("WARNING: $typ.name, $existing_idx")
				//return -1

				panic("Warning: override type - table.register_type_symbol()")
				return existing_idx
			}
		}
	}
	typ_idx := t.types.len
	t.types << typ
	t.type_idxs[typ.name.to_lower()] = typ_idx
	return typ_idx
}

[inline]
pub fn (t &Table) find_type_idx(name string) int {
	return t.type_idxs[name.to_lower()]
}

pub fn (t &Table) known_type(name string) bool {
	return t.find_type_idx(name) != 0
}

[inline]
pub fn (t &Table) find_type(name string) ?TypeSymbol {
	idx := t.type_idxs[name.to_lower()]
	if idx > 0 {
		return t.types[idx]
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

pub fn (mut t Table) find_or_register_array(elem_type Type) int {
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