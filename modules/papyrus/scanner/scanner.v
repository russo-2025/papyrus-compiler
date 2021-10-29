module scanner

import math.mathutil as mu
import os
import pref
import papyrus.token
import papyrus.util
import papyrus.errors

const (
	single_quote = `\'`
	double_quote = `"`
)

pub struct Scanner {
pub mut:
	file_path			string	// путь до файла
	text				string	// текст файла
	pos					int		// текущая позиция
	line_nr				int		// номер строки
	last_nl_pos			int		// последняя позиция новой строки
	
	line_ends			[]int	// позиции концов строк // the positions of source lines ends   (i.e. \n signs)
	nr_lines			int		// кол-во отсканированных строк
	eofs				int
	pref				&pref.Preferences
	errors				[]errors.Error
	warnings			[]errors.Warning
}

pub fn new_scanner_file(file_path string, pref &pref.Preferences) &Scanner {
	if !os.exists(file_path) {
		panic("$file_path doesn't exist")
	}

	raw_text := util.read_file(file_path) or {
		panic(err)
	}

	return &Scanner{
		pref: pref
		text: raw_text
		file_path: file_path
	}
}

pub fn new_scanner(text string, pref &pref.Preferences) &Scanner {
	return &Scanner{
		pref: pref
		text: text
		file_path: ''
	}
}

pub fn new_scanner_test(raw_text string, pref &pref.Preferences) &Scanner {

	return &Scanner{
		pref: pref
		text: raw_text
		file_path: "::test::in-memory::"
	}
}

pub fn (mut s Scanner) scan() token.Token {
	return s.text_scan()
}

fn (mut s Scanner) text_scan() token.Token {
	for {
		s.skip_whitespace()

		if s.pos >= s.text.len {
			return s.end_of_file()
		}

		for s.text[s.pos] == `\\`{
			s.pos++ 
			s.skip_whitespace()
		}

		c := s.text[s.pos]
		nextc := s.look_ahead(1)

		//name or keyword
		if util.is_name_char(c) {
			name := s.ident_name()
			
			kind := token.key_to_token(name.to_lower())

			if kind != .unknown {
				return s.new_token(kind, name, name.len)
			}

			if s.pos == 0 && s.look_ahead(1) == ` ` {
				// If a single letter name at the start of the file, increment
				// Otherwise the scanner would be stuck at s.pos = 0
				s.pos++
			}

			return s.new_token(.name, name, name.len)
		}
		else if c.is_digit() {
			num := s.ident_number()
			return s.new_token(.number, num, num.len)
		}

		match c {
			`\'`, 
			`"` {
				ident_string := s.ident_string()
				return s.new_token(.string, ident_string, ident_string.len + 2) // + two quotes
			}
			`+` {
				if nextc == `=` {
					s.pos++
					s.pos++
					return s.new_token(.plus_assign, '', 2)
				}
				s.pos++
				return s.new_token(.plus, '', 1)
			}
			`-` {
				if nextc == `=` {
					s.pos++
					s.pos++
					return s.new_token(.minus_assign, '', 2)
				}
				s.pos++
				return s.new_token(.minus, '', 1)
			}
			`*` {
				if nextc == `=` {
					s.pos++
					s.pos++
					return s.new_token(.mult_assign, '', 2)
				}
				s.pos++
				return s.new_token(.mul, '', 1)
			}
			`/` {
				if nextc == `=` {
					s.pos++
					s.pos++
					return s.new_token(.div_assign, '', 2)
				}
				s.pos++
				return s.new_token(.div, '', 1)
			}
			`%` {
				if nextc == `=` {
					s.pos++
					s.pos++
					return s.new_token(.mod_assign, '', 2)
				}
				s.pos++
				return s.new_token(.mod, '', 1)
			}
			`&` {
				if nextc == `&` {
					s.pos++
					s.pos++
					return s.new_token(.and, '', 2)
				}
			}
			`|` {
				if nextc == `|` {
					s.pos++
					s.pos++
					return s.new_token(.logical_or, '', 2)
				}
			}
			`!` {
				if nextc == `=` {
					s.pos++
					s.pos++
					return s.new_token(.ne, '', 2)
				}
				s.pos++
				return s.new_token(.not, '', 1)
			}
			`,` {
				s.pos++
				return s.new_token(.comma, '', 1)
			}
			`.` {
				s.pos++
				return s.new_token(.dot, '', 1)
			}
			`=` {
				if nextc == `=` {
					s.pos++
					s.pos++
					return s.new_token(.eq, '', 2)
				}
				s.pos++
				return s.new_token(.assign, '', 1)
			}
			`(` {
				s.pos++
				return s.new_token(.lpar, '', 1)
			}
			`)` {
				s.pos++
				return s.new_token(.rpar, '', 1)
			}
			`{` {
				start := s.pos
				start_line := s.line_nr
				
				if nextc == `}` {
					s.pos += 2
					continue
				}
				for s.pos < s.text.len - 1 {
					s.pos++
						
					if s.text[s.pos] == `\n` {
						s.inc_line_number()
						continue
					}

					if s.text[s.pos] == `}` {
						break
					}
				}

				comment := s.text[start+1..s.pos]
				s.pos++
				len := comment.len + 2 + 1
				return s.new_multiline_token(.comment, comment, len, start_line)
			}
			`;` {
				if nextc == `/` {
					start_line := s.line_nr
					start := s.pos

					s.pos++

					for s.pos < s.text.len - 1 {
						s.pos++
							
						if s.text[s.pos] == `\n` {
							s.inc_line_number()
							continue
						}

						if s.expect('/;', s.pos) {
							break
						}
					}
					
					s.pos += 2
					comment := s.text[start+2..s.pos-2]
					len := comment.len + 4
					return s.new_multiline_token(.comment, comment, len, start_line)
				}

				start := s.pos
				s.ignore_line()
				
				if s.text[s.pos - 1] == `\r` {
					s.pos--
					s.line_nr--
				}

				comment := s.text[start+1..s.pos]

				return s.new_token(.comment, comment, comment.len + 1)
			}
			`[` {
				s.pos++
				return s.new_token(.lsbr, '', 1)
			}
			`]` {
				s.pos++
				return s.new_token(.rsbr, '', 1)
			}
			`>` {
				if nextc == `=` {
					s.pos++
					s.pos++
					return s.new_token(.ge, '', 2)
				}
				s.pos++
				return s.new_token(.gt, '', 1)
			}
			`<` {
				if nextc == `=` {
					s.pos++
					s.pos++
					return s.new_token(.le, '', 2)
				}
				s.pos++
				return s.new_token(.lt, '', 1)
			}
			else {}
		}

		if c == `\0` {
			return s.end_of_file()
		}

		s.error('invalid character `$c.ascii_str()`')
		break
	}

	return s.end_of_file()
}

[inline]
fn (s Scanner) look_ahead(n int) byte {
	if s.pos + n < s.text.len {
		return s.text[s.pos + n]
	} else {
		return `\0`
	}
}


[inline]
fn (mut s Scanner) skip_whitespace() {

	for s.pos < s.text.len && s.text[s.pos].is_space() {
		if util.is_nl(s.text[s.pos]) && !s.expect('\r\n', s.pos - 1) {
			s.inc_line_number()
		}
		s.pos++
	}
}

fn (mut s Scanner) end_of_file() token.Token {
	s.eofs++
	if s.eofs > 50 {
		s.line_nr--
		panic('the end of file `$s.file_path` has been reached 50 times already, the v parser is probably stuck.\n' +
			'This should not happen. Please report the bug here, and include the last 2-3 lines of your source code:\n')
	}
	if s.pos != s.text.len && s.eofs == 1 {
		s.inc_line_number()
	}
	s.pos = s.text.len
	return s.new_token(.eof, '', 1)
}

[inline]
fn (mut s Scanner) ignore_line() {
	s.eat_to_end_of_line()
	s.inc_line_number()
}

[inline]
fn (mut s Scanner) eat_to_end_of_line() {
	for s.pos < s.text.len && s.text[s.pos] != `\n` {
		s.pos++
	}
}

[inline]
fn (mut s Scanner) inc_line_number() {
	s.last_nl_pos = mu.min(s.text.len - 1, s.pos)
	s.line_nr++
	s.line_ends << s.pos

	if s.line_nr > s.nr_lines {
		s.nr_lines = s.line_nr
	}
}

[inline]
fn (mut s Scanner) ident_name() string {
	start := s.pos
	s.pos++
	for s.pos < s.text.len && (util.is_name_char(s.text[s.pos]) || s.text[s.pos].is_digit()) {
		s.pos++
	}
	name := s.text[start..s.pos]
	//s.pos--
	return name
}

fn (mut s Scanner) ident_number() string {
	if s.expect('0x', s.pos) {
		return s.ident_hex_number()
	} else {
		return s.ident_dec_number()
	}
}

fn (mut s Scanner) ident_string() string {
	
	q := s.text[s.pos]
	
	if q != single_quote && q != double_quote {
		s.error('first quote not found')
		return ''
	}

	mut quote := single_quote

	if q == single_quote {
		quote = single_quote
	} 
	else {
		quote = double_quote
	}
	
	mut n_cr_chars := 0
	mut start := s.pos + 1
	
	slash := `\\`

	for {
		s.pos++

		if s.pos >= s.text.len {
			s.error('unfinished string literal')
			break
		}

		c := s.text[s.pos]
		prevc := s.text[s.pos - 1]

		if c == quote && (prevc != slash || (prevc == slash && s.text[s.pos - 2] == slash)) {
			s.pos++
			break
		}
		if c == `\r` {
			n_cr_chars++
		}
		if c == `\n` {
			s.inc_line_number()
		}
	}

	mut lit := ''
	mut end := s.pos - 1

	if start <= s.pos {
		mut string_so_far := s.text[start..end]
		if n_cr_chars > 0 {
			string_so_far = string_so_far.replace('\r', '')
		}
		if string_so_far.contains('\\\n') {
			lit = trim_slash_line_break(string_so_far)
		} else {
			lit = string_so_far
		}
	}

	return lit
}

fn trim_slash_line_break(s string) string {
	mut start := 0
	mut ret_str := s
	for {
		idx := ret_str.index_after('\\\n', start)
		if idx != -1 {
			ret_str = ret_str[..idx] + ret_str[idx + 2..].trim_left(' \n\t\v\f\r')
			start = idx
		} else {
			break
		}
	}
	return ret_str
}

fn (mut s Scanner) ident_dec_number() string {
	mut has_wrong_digit := false
	mut first_wrong_digit_pos := 0
	mut first_wrong_digit := `\0`
	start_pos := s.pos
	// scan integer part
	for s.pos < s.text.len {
		c := s.text[s.pos]
		if !c.is_digit() {
			if !c.is_letter() {
				break
			} else if !has_wrong_digit {
				has_wrong_digit = true
				first_wrong_digit_pos = s.pos
				first_wrong_digit = c
			}
		}
		s.pos++
	}
	
	mut call_method := false // true for, e.g., 5.str(), 5.5.str(), 5e5.str()
	mut is_range := false // true for, e.g., 5..10
	// scan fractional part
	if s.pos < s.text.len && s.text[s.pos] == `.` {
		s.pos++
		if s.pos < s.text.len {
			// 5.5, 5.5.str()
			if s.text[s.pos].is_digit() {
				for s.pos < s.text.len {
					c := s.text[s.pos]
					if !c.is_digit() {
						if !c.is_letter() {
							// 5.5.str()
							if c == `.` && s.pos + 1 < s.text.len && s.text[s.pos + 1].is_letter() {
								call_method = true
							}
							break
						} else if !has_wrong_digit {
							has_wrong_digit = true
							first_wrong_digit_pos = s.pos
							first_wrong_digit = c
						}
					}
					s.pos++
				}
			} else if s.text[s.pos].is_letter() {
				// 5.str()
				call_method = true
				s.pos--
			}
		}
	}

	if has_wrong_digit {
		// error check: wrong digit
		s.pos = first_wrong_digit_pos // adjust error position
		s.error('this number has unsuitable digit `$first_wrong_digit.str()`')
	} else if s.pos < s.text.len && s.text[s.pos] == `.` && !is_range && !call_method {
		// error check: 1.23.4, 123.e+3.4
		
		s.error('too many decimal points in number')
	}

	number := s.num_lit(start_pos, s.pos)
	return number
}

fn (mut s Scanner) ident_hex_number() string {
	mut has_wrong_digit := false
	mut first_wrong_digit_pos := 0
	mut first_wrong_digit := `\0`

	start_pos := s.pos
	
	if s.pos + 2 >= s.text.len {
		return '0x'
	}
	
	s.pos += 2 // skip '0x'

	for s.pos < s.text.len {
		c := s.text[s.pos]

		if !c.is_hex_digit() {
			if !c.is_letter() {
				break
			}
			else if !has_wrong_digit {
				has_wrong_digit = true
				first_wrong_digit_pos = s.pos
				first_wrong_digit = c
			}
		}

		s.pos++
	}
	
	if start_pos + 2 == s.pos {
		s.pos-- // adjust error position
		s.error('number part of this hexadecimal is not provided')
	}
	else if has_wrong_digit {
		s.pos = first_wrong_digit_pos // adjust error position
		s.error('this hexadecimal number has unsuitable digit `$first_wrong_digit.str()`')
	}

	number := s.num_lit(start_pos, s.pos)
	return number
}

[inline]
fn (mut s Scanner) new_multiline_token(tok_kind token.Kind, lit string, len int, start_line int) token.Token {
	return token.Token{
		kind: tok_kind
		lit: lit
		line_nr: start_line + 1
		pos: s.pos - len + 1
		len: len
	}
}

[inline]
fn (mut s Scanner) new_token(tok_kind token.Kind, lit string, len int) token.Token {
	return token.Token{
		kind: tok_kind
		lit: lit
		line_nr: s.line_nr + 1
		pos: s.pos - len
		len: len
	}
}

[inline]
fn (s &Scanner) expect(want string, start_pos int) bool {
	end_pos := start_pos + want.len
	if start_pos < 0 || end_pos < 0 || start_pos >= s.text.len || end_pos > s.text.len {
		return false
	}
	for pos in start_pos .. end_pos {
		if s.text[pos] != want[pos - start_pos] {
			return false
		}
	}
	return true
}

fn (s Scanner) num_lit(start int, end int) string {
	unsafe {
		txt := s.text.str
		mut b := malloc(end - start + 1) // add a byte for the endstring 0
		mut i1 := 0
		for i := start; i < end; i++ {
			b[i1] = txt[i]
			i1++
		}
		b[i1] = 0 // C string compatibility
		return b.vstring_with_len(i1)
	}
}

pub fn (mut s Scanner) warn(msg string) {
	pos := token.Position{
		line_nr: s.line_nr
		pos: s.pos
	}
	
	eprintln(util.formatted_error('warning:', msg, s.file_path, pos))
}

pub fn (mut s Scanner) error(msg string) {
	pos := token.Position{
		line_nr: s.line_nr
		pos: s.pos
	}
	
	eprintln(util.formatted_error('error:', msg, s.file_path, pos))
	exit(1)
}