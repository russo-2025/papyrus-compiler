module token

pub struct Position {
pub:
	len     int // length of the literal in the source
	line_nr int // the line number in the source where the token occured
	pos     int // the position of the token in scanner text
pub mut:
	last_line int // the line number where the ast object ends (used by vfmt)
}

fn (a Position) == (b Position) bool {
	if a.len != b.len || a.line_nr != b.line_nr || a.pos != b.pos || a.last_line != b.last_line {
		return false
	}

	return true
}

pub fn (pos Position) str() string {
	return 'Position{ line_nr: $pos.line_nr, pos: $pos.pos, len: $pos.len }'
}

pub fn (pos Position) extend(end Position) Position {
	return {
		...pos
		len: end.pos - pos.pos + end.len
		last_line: end.last_line
	}
}

pub fn (mut pos Position) update_last_line(last_line int) {
	pos.last_line = last_line - 1
}