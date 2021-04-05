module util

import os
import term
import papyrus.token

const (
	error_context_before = 2
	error_context_after  = 2
)

pub const (
	emanager = new_error_manager()
)

pub struct EManager {
mut:
	support_color bool
}

pub fn new_error_manager() &EManager {
	return &EManager{
		support_color: term.can_show_color_on_stderr() && term.can_show_color_on_stdout()
	}
}

pub fn formatted_error(kind string, omsg string, filepath string, pos token.Position) string {
	emsg := omsg.replace('main.', '')
	mut path := filepath
	verror_paths_override := os.getenv('VERROR_PATHS')
	if verror_paths_override == 'absolute' {
		path = os.real_path(path)
	} else {
		// Get relative path
		workdir := os.getwd() + os.path_separator
		if path.starts_with(workdir) {
			path = path.replace(workdir, '')
		}
	}
	//
	source, column := filepath_pos_to_source_and_column(filepath, pos)
	position := '$path:${pos.line_nr + 1}:${imax(1, column + 1)}:'
	scontext := source_context(kind, source, column, pos).join('\n')
	final_position := bold(position)
	final_kind := bold(color(kind, kind))
	final_msg := emsg
	final_context := if scontext.len > 0 { '\n$scontext' } else { '' }
	//
	return '$final_position $final_kind $final_msg$final_context'.trim_space()
}

pub fn filepath_pos_to_source_and_column(filepath string, pos token.Position) (string, int) {
	// TODO: optimize this; may be use a cache.
	// The column should not be so computationally hard to get.
	source := read_file(filepath) or { '' }
	mut p := imax(0, imin(source.len - 1, pos.pos))
	if source.len > 0 {
		for ; p >= 0; p-- {
			if source[p] == `\n` || source[p] == `\r` {
				break
			}
		}
	}
	column := imax(0, pos.pos - p - 1)
	return source, column
}

pub fn bold(msg string) string {
	if !emanager.support_color {
		return msg
	}
	return term.bold(msg)
}

fn color(kind string, msg string) string {
	if !emanager.support_color {
		return msg
	}
	if kind.contains('error') {
		return term.red(msg)
	} else {
		return term.magenta(msg)
	}
}

pub fn source_context(kind string, source string, column int, pos token.Position) []string {
	mut clines := []string{}
	if source.len == 0 {
		return clines
	}
	source_lines := source.split_into_lines()
	bline := imax(0, pos.line_nr - error_context_before)
	aline := imax(0, imin(source_lines.len - 1, pos.line_nr + error_context_after))
	tab_spaces := '    '
	for iline := bline; iline <= aline; iline++ {
		sline := source_lines[iline]
		start_column := imax(0, imin(column, sline.len))
		end_column := imax(0, imin(column + imax(0, pos.len), sline.len))
		cline := if iline == pos.line_nr { sline[..start_column] + color(kind, sline[start_column..end_column]) +
				sline[end_column..] } else { sline }
		clines << '${iline + 1:5d} | ' + cline.replace('\t', tab_spaces)
		//
		if iline == pos.line_nr {
			// The pointerline should have the same spaces/tabs as the offending
			// line, so that it prints the ^ character exactly on the *same spot*
			// where it is needed. That is the reason we can not just
			// use strings.repeat(` `, col) to form it.
			mut pointerline := ''
			for bchar in sline[..start_column] {
				x := if bchar.is_space() { bchar } else { ` ` }
				pointerline += x.ascii_str()
			}
			underline := if pos.len > 1 { '~'.repeat(end_column - start_column) } else { '^' }
			pointerline += bold(color(kind, underline))
			clines << '      | ' + pointerline.replace('\t', tab_spaces)
		}
	}
	return clines
}