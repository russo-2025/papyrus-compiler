module builder

import os
import runtime
import pex
import papyrus.ast
import papyrus.parser
import papyrus.checker
import gen.gen_v

@[inline]
fn (mut b Builder) compile_v() {
	b.print("${b.files.len} files in total")

	b.start_timer('parse files')
	b.parsed_files = parser.parse_files(b.files, mut b.table, b.pref, mut b.global_scope)
	b.print_timer('parse files')

	assert b.parsed_files.len == b.files.len

	b.start_timer('parse headers files')
	b.parse_deps()
	b.print_timer('parse headers files')
	
	//fns_dump.load("FunctionsDump.json", mut b.table) or { panic(err) }

	b.start_timer('check files')
	mut c := checker.new_checker(b.table, b.pref)
	c.check_files(mut b.parsed_files)
	b.print_timer('check files')

	if c.errors.len != 0 {
		println("failed to compile files, ${c.errors.len} errors")

		$if test {
			assert false, "checker.errors.len != 0"
		}

		exit(1)
	}

	for i := 0; i < b.parsed_files.len; i++ {
		println(gen_v.gen_v_file(mut b.parsed_files[i], mut b.table, b.pref))
	}
}