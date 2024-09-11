module util

@[inline]
pub fn is_name_char(c u8) bool {
	return (c >= `a` && c <= `z`) || (c >= `A` && c <= `Z`) || c == `_`
}

@[inline]
pub fn is_nl(c u8) bool {
	return c == `\r` || c == `\n`
}

pub const non_whitespace_table = get_non_white_space_table()

fn get_non_white_space_table() [256]bool {
	mut bytes := [256]bool{}
	for c in 0 .. 256 {
		bytes[c] = !u8(c).is_space()
	}
	return bytes
}