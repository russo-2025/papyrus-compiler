module ast

import papyrus.table
import papyrus.token

pub struct Scope {
pub mut:
	objects              map[string]ScopeObject
	parent               &Scope
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
	typ			table.Type
	pos			token.Position
	is_used		bool
}

pub fn new_scope(parent &Scope, start_pos int) &Scope {
	return &Scope{
		parent: parent
		start_pos: start_pos
	}
}

pub fn (s &Scope) find(name string) ?ScopeObject {
	lname := name.to_lower()
	if lname in s.objects {
		return s.objects[lname]
	}

	return none
}

pub fn (s &Scope) find_var(name string) ?&ScopeVar {
	
	if obj := s.find(name.to_lower()) {
		match obj {
			ScopeVar { return &obj }
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