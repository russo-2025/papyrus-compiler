module util

import os

pub fn read_file(file_path string) !string {
	raw_text := os.read_file(file_path) or { return error('failed to open $file_path') }
	return skip_bom(raw_text)
}

pub fn skip_bom(file_content string) string {
	mut raw_text := file_content
	// BOM check
	if raw_text.len >= 3 {
		unsafe {
			c_text := raw_text.str
			if c_text[0] == 0xEF && c_text[1] == 0xBB && c_text[2] == 0xBF {
				// skip three BOM bytes
				offset_from_begin := 3
				raw_text = tos(c_text[offset_from_begin], vstrlen(c_text) - offset_from_begin)
			}
		}
	}
	return raw_text
}

[inline]
pub fn imin(a int, b int) int {
	return if a < b {
		a
	} else {
		b
	}
}

[inline]
pub fn imax(a int, b int) int {
	return if a > b {
		a
	} else {
		b
	}
}