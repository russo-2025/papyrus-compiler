module ast

import papyrus.token

@[heap]
pub struct Scope {
pub mut:
	objects              map[string]ScopeObject
	parent               &Scope = unsafe { voidptr(0) }
	children             []&Scope
	start_pos            int
	end_pos              int
}

pub type ScopeObject = ScopeVar | ScopeNone

pub struct ScopeNone {
	name	string
} //tmp

pub struct ScopeVar {
pub:
	name		string
pub mut:
	typ			Type
	pos			token.Position
	is_used		bool
}

pub fn new_scope(parent &Scope, start_pos int) &Scope {
	return &Scope{
		parent: parent
		start_pos: start_pos
	}
}

pub fn (mut s Scope) find(name string) ?ScopeObject {
	lname := name.to_lower()
	
	mut current_scope := &Scope(&s)
	for {
		if lname in current_scope.objects {
			return current_scope.objects[lname] or { panic('key not found') }
		}

		if !isnil(current_scope.parent) {
			current_scope = current_scope.parent
			continue
		}

		break
	}
	
	return none
}

pub fn (mut s Scope) find_var(name string) ?ScopeVar {
	if obj := s.find(name.to_lower()) {
		match obj {
			ScopeVar { return obj }
			else {}
		}
	}

	return none
}

pub fn (mut s Scope) register(obj ScopeObject) {
	if obj is ScopeVar {
		name := obj.name.to_lower()
		
		if name in s.objects {
			return
		}

		s.objects[name] = obj
	}
	else {
		panic("invalid scope object")
	}
}