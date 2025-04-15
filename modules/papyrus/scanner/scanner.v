module scanner

import os
import pref
import papyrus.token
import papyrus.util
import papyrus.errors

const single_quote = `\'`
const double_quote = `"`
const b_lf = 10
const b_cr = 13

pub struct Scanner {
mut:
	file_path			string	// src file path
	text				string	// src file text
	pos					int		// current position
	line_nr				int		// current line number
	last_nl_pos			int		// last newline position
	line_nr_lt_escaped	int
	is_crlf				bool	// special check when computing columns
	nr_lines			int		// number of scanned lines
	eofs				int
	pref				&pref.Preferences
	errors				[]errors.Error
	warnings			[]errors.Warning
}

pub fn new_scanner_file(file_path string, prefs &pref.Preferences) &Scanner {
	if !os.exists(file_path) {
		panic("$file_path doesn't exist")
	}

	raw_text := util.read_file(file_path) or {
		panic(err)
	}

	return &Scanner{
		pref: prefs
		text: raw_text
		file_path: file_path
	}
}

pub fn new_scanner(text string, prefs &pref.Preferences) &Scanner {
	return &Scanner{
		pref: prefs
		text: text
		file_path: ''
	}
}

pub fn new_scanner_test(raw_text string, prefs &pref.Preferences) &Scanner {

	return &Scanner{
		pref: prefs
		text: raw_text
		file_path: "::test::in-memory::"
	}
}

pub fn (mut s Scanner) scan() token.Token {
	return s.text_scan()
}

@[direct_array_access]
fn (mut s Scanner) text_scan() token.Token {
	for {
		s.skip_whitespace()

		if s.pos >= s.text.len {
			return s.end_of_file()
		}

		for s.text[s.pos] == `\\`{
			s.line_nr_lt_escaped = s.line_nr + 1
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
					return s.new_token(.logical_and, '', 2)
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
				mut comment_line_end := s.pos
				
				if s.text[s.pos - 1] == scanner.b_cr {
					comment_line_end--
				} else {
					s.line_nr--
				}
				
				comment := s.text[start + 1..comment_line_end]

				return s.new_token(.comment, comment, comment.len + 2)
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

		s.error('invalid character `${c.ascii_str()}`')
		break
	}

	return s.end_of_file()
}

@[direct_array_access; inline]
fn (s Scanner) look_ahead(n int) u8 {
	if s.pos + n < s.text.len {
		return s.text[s.pos + n]
	} else {
		return `\0`
	}
}


@[direct_array_access; inline]
fn (mut s Scanner) skip_whitespace() {
	for s.pos < s.text.len {
		c := s.text[s.pos]
		if c == 9 {
			// tabs are most common
			s.pos++
			continue
		}
		if util.non_whitespace_table[c] {
			return
		}
		c_is_nl := c == scanner.b_cr || c == scanner.b_lf
		
		if s.pos + 1 < s.text.len && c == scanner.b_cr && s.text[s.pos + 1] == scanner.b_lf {
			s.is_crlf = true
		}
		// Count \r\n as one line
		if c_is_nl && !(s.pos > 0 && s.text[s.pos - 1] == scanner.b_cr && c == scanner.b_lf) {
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

@[inline]
fn (mut s Scanner) ignore_line() {
	s.eat_to_end_of_line()
	s.inc_line_number()
}

@[direct_array_access; inline]
fn (mut s Scanner) eat_to_end_of_line() {
	for s.pos < s.text.len && s.text[s.pos] != scanner.b_lf {
		s.pos++
	}
}

@[inline]
fn (mut s Scanner) inc_line_number() {
	s.last_nl_pos = s.text.len - 1
	if s.last_nl_pos > s.pos {
		s.last_nl_pos = s.pos
	}
	if s.is_crlf {
		s.last_nl_pos++
	}
	s.line_nr++
	if s.line_nr > s.nr_lines {
		s.nr_lines = s.line_nr
	}
}

@[direct_array_access; inline]
fn (mut s Scanner) ident_name() string {
	start := s.pos
	s.pos++
	for s.pos < s.text.len && (util.is_name_char(s.text[s.pos]) || s.text[s.pos].is_digit()) {
		s.pos++
	}
	name := s.text[start..s.pos]
	
	return name
}

fn (mut s Scanner) ident_number() string {
	if s.expect('0x', s.pos) || s.expect('0X', s.pos) {
		return s.ident_hex_number()
	} else {
		return s.ident_dec_number()
	}
}

@[direct_array_access]
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
		idx := ret_str.index_after('\\\n', start) or { panic(err) }
		if idx != -1 {
			ret_str = ret_str[..idx] + ret_str[idx + 2..].trim_left(' \n\t\v\f\r')
			start = idx
		} else {
			break
		}
	}
	return ret_str
}

@[direct_array_access]
fn (mut s Scanner) ident_dec_number() string {
	mut has_wrong_digit := false
	mut first_wrong_digit_pos := 0
	mut first_wrong_digit := `\0`
	start_pos := s.pos
	// scan integer part
	for s.pos < s.text.len {
		c := s.text[s.pos]
		if !c.is_digit() {
			break
		}
		s.pos++
	}
	
	// scan fractional part
	if s.pos < s.text.len && s.text[s.pos] == `.` {
		s.pos++
		if s.pos < s.text.len {
			// 5.5, 5.5.str()
			if s.text[s.pos].is_digit() {
				for s.pos < s.text.len {
					c := s.text[s.pos]
					if !c.is_digit() {
						break
					}
					s.pos++
				}
			} else if s.text[s.pos].is_letter() {
				// 5.str()
				s.pos--
			}
		}
	}

	if has_wrong_digit {
		// error check: wrong digit
		s.pos = first_wrong_digit_pos // adjust error position
		s.error('this number has unsuitable digit `$first_wrong_digit.str()`')
	}

	number := s.num_lit(start_pos, s.pos)
	return number
}

@[direct_array_access]
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

@[inline]
fn (mut s Scanner) new_multiline_token(tok_kind token.Kind, lit string, len int, start_line int) token.Token {
	return token.Token{
		kind: tok_kind
		lit: lit
		line_nr: start_line + 1
		pos: s.pos - len + 1
		len: len
	}
}

@[inline]
fn (mut s Scanner) new_token(tok_kind token.Kind, lit string, len int) token.Token {
	return token.Token{
		kind: tok_kind
		lit: lit
		line_nr: s.line_nr + 1
		pos: s.pos - len
		len: len
		lt_escaped: s.line_nr_lt_escaped == s.line_nr
	}
}

@[direct_array_access; inline]
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
	
	eprintln(util.formatted_error('Scanner warning:', msg, s.file_path, pos))
}

pub fn (mut s Scanner) error(msg string) {
	pos := token.Position{
		line_nr: s.line_nr
		pos: s.pos
	}
	
	eprintln(util.formatted_error('Scanner error:', msg, s.file_path, pos))
	exit(1)
}