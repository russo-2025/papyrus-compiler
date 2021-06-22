module parser

import papyrus.ast

pub fn (mut p Parser) get_parsed_type() ast.Type {
	if p.parsed_type == 0 {
		panic("invalid type")
	}
	
	typ := p.parsed_type
	p.parsed_type = 0

	return ast.new_type(typ)
}

pub fn (mut p Parser) parse_array_type(name string) ast.Type {
	mut idx := p.table.find_type_idx(name)
	
	if idx == 0 {
		idx = p.table.add_placeholder_type(name)
	}
	
	elem_type := ast.new_type(idx)

	idx = p.table.find_or_register_array(elem_type)
	return ast.new_type(idx)
}

pub fn (mut p Parser) parse_type() {
	mut name := p.tok.lit
	p.next()

	if p.tok.kind == .lsbr && p.peek_tok.kind == .rsbr
	{
		p.next()
		p.next()
		
		p.parsed_type = p.parse_array_type(name)
		return
	}

	mut idx := p.table.find_type_idx(name)
	
	if idx > 0 {
		p.parsed_type = ast.new_type(idx)
		return
	}

	idx = p.table.add_placeholder_type(name)

	p.parsed_type = ast.new_type(idx)
}

pub fn (mut p Parser) next_is_type() bool {
	/*
	.name .key_function
	.name .key_event
	.name .key_property
	.name .name
	.name .lsbr .rsbr .key_function
	.name .lsbr .rsbr .key_event
	.name .lsbr .rsbr .key_property
	.name .lsbr .rsbr .name
	*/

	if p.tok.kind.is_type() {
		return true
	}
	
	if p.tok.kind != .name {
		return false
	}

	if p.tok.line_nr != p.peek_tok.line_nr {
		return false
	}

	match p.peek_tok.kind {
		.key_function,
		.key_event,
		.key_property,
		.name {
			return true
		}
		.lsbr {
			if p.peek_tok2.kind != .rsbr {
				return false
			}
			
			match p.peek_tok3.kind {
				.key_function,
				.key_event,
				.key_property,
				.name {
					return true
				}
				else {
					return false
				}
			}
		}
		else {
			return false
		}
	}

	return false
}