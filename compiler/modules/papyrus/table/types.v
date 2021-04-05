module table

pub type Type = int

pub type TypeInfo = Array | EmptyInfo

pub struct TypeSymbol {
pub:
	parent_idx	int
pub mut:
	info		TypeInfo
	kind		Kind
	name		string
	methods		[]Fn
	mod			string
}

pub struct EmptyInfo {}
pub struct Array {
pub mut:
	elem_type Type
}

pub enum Kind {
	placeholder
	none_
	int
	float
	string
	bool
	array
	script
}

pub const (
	none_type_idx = 1
	int_type_idx = 2
	float_type_idx = 3
	string_type_idx = 4
	bool_type_idx = 5
	array_type_idx = 6

	form_type_idx = 7
	obj_ref_type_idx = 8
	actor_type_idx = 9
	game_type_idx = 10
	actor_value_info_type_idx = 11
	weapon_type_idx = 12
	debug_type_idx = 13
	utility_type_idx = 14
	string_util_type_idx = 15
)

pub const (
	none_type          = new_type(none_type_idx)	//1
	int_type          = new_type(int_type_idx)		//2
	float_type          = new_type(float_type_idx)	//3
	string_type          = new_type(string_type_idx)//4
	bool_type          = new_type(bool_type_idx)	//5
	array_type          = new_type(array_type_idx)	//6
)


pub fn (mut t Table) register_builtin_type_symbols() {
	// reserve index 0 so nothing can go there
	// save index check, 0 will mean not found
	t.register_type_symbol(kind: .placeholder, name: 'reserved_0')		//0
	t.register_type_symbol(kind: .none_, name: 'None', mod: 'builtin')	//1
	t.register_type_symbol(kind: .int, name: 'Int', mod: 'builtin')		//2
	t.register_type_symbol(kind: .float, name: 'Float', mod: 'builtin')	//3
	t.register_type_symbol(kind: .string, name: 'String', mod: 'builtin')	//4
	t.register_type_symbol(kind: .bool, name: 'Bool', mod: 'builtin')		//5
	t.register_type_symbol(kind: .array, name: 'Array', mod: 'builtin')		//6

	t.register_type_symbol({ //7
		parent_idx: array_type
		info: Array { elem_type: string_type}
		kind: .array
		name: 'String[]'
		mod: 'builtin'
	})
	t.register_type_symbol({ //8
		parent_idx: array_type
		info: Array { elem_type: int_type}
		kind: .array
		name: 'Int[]'
		mod: 'builtin'
	})
	t.register_type_symbol({ //9
		parent_idx: array_type
		info: Array { elem_type: float_type}
		kind: .array
		name: 'Float[]'
		mod: 'builtin'
	})
	t.register_type_symbol({ //10
		parent_idx: array_type
		info: Array { elem_type: bool_type}
		kind: .array
		name: 'Bool[]'
		mod: 'builtin'
	})
}

pub fn (k Kind) str() string {
	mut k_str := match k {
		.placeholder { 'placeholder' }
		.none_ { 'None' }
		.int { 'Int' }
		.float { 'Float' }
		.string { 'String' }
		.bool { 'Bool' }
		.array { 'array' }
		.script { 'script' }
	}

	return k_str
}

[inline]
pub fn (t Type) idx() int {
	return u16(t)
}

[inline]
pub fn new_type(idx int) Type {
	if idx < 1 || idx > 65535 {
		panic('new_type: idx($idx) must be between 1 & 65535')
	}
	return idx
}

pub fn (t &Table) type_to_str(typ Type) string {
	sym := t.get_type_symbol(typ)

	return match sym.kind {
		.none_,
		.int,
		.float,
		.string,
		.bool {
			sym.kind.str()
		}
		.array,
		.script {
			sym.name
		}
		.placeholder { 'placeholder' }
	}
}

pub fn (t &TypeSymbol) has_method(name string) bool {
	t.find_method(name) or { return false }
	return true
}

pub fn (t &TypeSymbol) find_method(name string) ?Fn {
	s := name.to_lower()
	for method in t.methods {
		if method.sname == s {
			return method
		}
	}
	return none
}

pub fn (mut t TypeSymbol) register_method(new_fn Fn) int {
	// returns a method index, stored in the ast.FnDecl
	// for faster lookup in the checker's fn_decl method
	// println('reg me $new_fn.name nr_args=$new_fn.args.len')
	//println("register method: $new_fn.mod . $new_fn.name, $new_fn.is_static, $new_fn.return_type")
	
	t.methods << new_fn
	
	return t.methods.len - 1
}