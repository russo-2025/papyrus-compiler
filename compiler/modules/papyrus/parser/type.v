module parser

import papyrus.table

pub fn (mut p Parser) get_parsed_type() table.Type {
	if p.parsed_type == 0 {
		panic("invalid type")
	}
	
	typ := p.parsed_type
	p.parsed_type = 0

	return table.new_type(typ)
}

pub fn (mut p Parser) parse_array_type(name string) table.Type {
	mut idx := p.table.find_type_idx(name)
	
	if idx == 0 {
		idx = p.table.add_placeholder_type(name)
	}
	
	elem_type := table.new_type(idx)

	idx = p.table.find_or_register_array(elem_type)
	return table.new_type(idx)
}

pub fn (mut p Parser) parse_type() table.Type {
	mut name := p.tok.lit
	p.next()

	if p.tok.kind == .lsbr && p.peek_tok.kind == .rsbr
	{
		p.next()
		p.next()
		
		return p.parse_array_type(name)
	}

	mut idx := p.table.find_type_idx(name)
	
	if idx > 0 {
		return table.new_type(idx)
	}

	idx = p.table.add_placeholder_type(name)

	return table.new_type(idx)
}

pub fn (mut p Parser) next_is_type() bool {
	if p.tok.kind.is_type() {
		return true
	}
	
	if p.tok.kind == .name {
		if p.peek_tok.kind == .key_function {
			return true
		}

		if p.peek_tok.kind == .key_event {
			return true
		}

		if p.peek_tok.kind == .name {
			return true
		}

		if p.peek_tok.kind == .lsbr {
			if p.peek_tok2.kind == .rsbr {
				if p.peek_tok3.kind  == .key_function {
					return true
				}

				if p.peek_tok3.kind  == .key_event {
					return true
				}
			}
		}
	}

	return false
}