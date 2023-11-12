module util

[inline]
pub fn is_name_char(c u8) bool {
	return (c >= `a` && c <= `z`) || (c >= `A` && c <= `Z`) || c == `_`
}

[inline]
pub fn is_nl(c u8) bool {
	return c == `\r` || c == `\n`
}
