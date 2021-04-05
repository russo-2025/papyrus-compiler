module table

pub struct Table {
pub mut:
	types		[]TypeSymbol
	type_idxs	map[string]int

	fns			map[string]Fn
	modules		[]string
}

pub struct Param {
pub mut:
	name			string
	typ				Type
	is_optional		bool
	default_value	string
	
}

pub struct Fn {
pub:
	params			[]Param
	return_type		Type
	mod				string
pub mut:
	name			string
	sname			string
	is_static		bool
}

pub fn (t Table) has_module(name string) bool {
	return name.to_lower() in t.modules
}

pub fn (mut t Table) register_module(name string) {
	s := name.to_lower()
	
	if s !in t.modules {
		t.modules << s
	}
}

pub fn new_table() &Table {
	mut t := &Table{}
	t.register_builtin_type_symbols()
	return t
}

pub fn (t &Table) find_fn(mod string, name string) ?Fn {
	f := t.fns[mod.to_lower() + "." + name.to_lower()]
	if f.name.str != 0 {
		return f
	}
	return none
}

pub fn (mut t Table) register_fn(new_fn Fn) {
	t.fns[new_fn.mod.to_lower() + "." + new_fn.name.to_lower()] = new_fn
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

				println("Warning: override type - table.register_type_symbol()")
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