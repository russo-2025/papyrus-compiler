module builder

import os
import time

import pref
import papyrus.ast
import papyrus.parser
import papyrus.checker
import gen.pex as gen_pex

const (
	builtin_path = os.real_path('./builtin')
	cache_path = os.real_path('./.papyrus')
	compiler_exe_path = os.real_path('./Original Compiler/PapyrusCompiler.exe')
	compiler_flags_path = os.real_path('./Original Compiler/TESV_Papyrus_Flags.flg')
)

struct Builder {
mut:
	timers			map[string]time.StopWatch
pub:
	output_dir	string
	pref			&pref.Preferences
	checker			checker.Checker
	global_scope	&ast.Scope
pub mut:
	parsed_files	[]ast.File
	table			&ast.Table
}

fn new_builder(pref &pref.Preferences) Builder{
	rdir := pref.out_dir[0]
	output_dir := if os.is_dir(rdir) { rdir } else { os.dir(rdir) }
	mut table := ast.new_table()
	
	return Builder{
		pref: pref
		checker: checker.new_checker(table, pref)
		global_scope: &ast.Scope{
			parent: 0
		}
		output_dir: output_dir
		table: table
	}
}

pub fn compile(pref &pref.Preferences) {
	if pref.backend == .original {
		compile_original(pref)
		return
	}

	os.is_writable_folder(pref.paths[0]) or {
		panic(err)
	}

	mut b := new_builder(pref)
	mut c := checker.new_checker(b.table, b.pref)
	
	b.start_timer('load builtin files')
	b.load_builtin_files()
	b.print_timer('load builtin files')

	b.start_timer('find source files')
	files := get_all_src_files(b.pref.paths)
	b.print_timer('find source files')

	b.start_timer('parse files')
	parsed_files := parser.parse_files(files, b.table, b.pref, b.global_scope)
	b.print_timer('parse files')

	b.start_timer('check files')
	c.check_files(parsed_files)
	b.print_timer('check files')

	if !os.exists(cache_path) {
		os.mkdir(cache_path) or { panic(err) }
	}

	if c.errors.len != 0 {
		return
	}
	
	b.start_timer('gen files')
	match b.pref.backend {
		.pex {
			compile_pex(parsed_files, b.table, b.pref)
		}
		else { panic('invalid compiler backend') }
	}

	b.print_timer('gen files')
}

fn compile_pex(parsed_files []ast.File, table &ast.Table, pref &pref.Preferences) {
	for pfile in parsed_files {
		if is_outdated(pfile, pref) {
			output_file_name := pfile.file_name + ".pex"
			output_file_path := os.join_path(pref.out_dir[0], output_file_name)
			gen_pex.gen(pfile, output_file_path, table, pref)
			
			if pref.out_dir.len > 1 {
				os.cp(output_file_path, os.join_path(pref.out_dir[1], output_file_name)) or { panic(err) }
			}
		}
	}
}

fn (mut b Builder) start_timer(name string) {
	b.timers[name] = time.new_stopwatch({})
}

fn (mut b Builder) print_timer(name string) {
	if sw := b.timers[name] {
		time := f32(sw.elapsed().microseconds()) / 1000
		println('$name: $time ms')
		b.timers.delete(name)
	}
	else {
		panic('invalid timer')
	}
}

fn (mut b Builder) load_builtin_files()  {
	if os.is_dir(builtin_path) {
		files := os.walk_ext(builtin_path, ".psc")
		parser.parse_files(files, b.table, b.pref, b.global_scope)
	}
	else {
		panic("invalid builtin dir - `$builtin_path`")
	}
}

fn get_all_src_files(paths []string) []string {
	mut files := []string{}

	for path in paths {
		files << os.walk_ext(path, ".psc")
	}

	return files
}