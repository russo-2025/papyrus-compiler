module builder

import os

import time

import papyrus.ast
import pref
import papyrus.parser
import papyrus.checker
import papyrus.table
import pex
import gen

struct Builder {
pub:
	compiled_dir	string
	pref			&pref.Preferences
	checker			checker.Checker
	global_scope	&ast.Scope
pub mut:
	parsed_files	[]ast.File
	table			&table.Table
}

fn new_builder(pref &pref.Preferences) Builder{
	rdir := os.real_path(pref.out_dir[0])
	compiled_dir := if os.is_dir(rdir) { rdir } else { os.dir(rdir) }
	mut table := table.new_table()

	if pref.mode != .compilebuiltin {
		//table.register_builtin_papyrus_types()
		//table.register_builtin_papyrus_functions()
	}
	
	return Builder{
		pref: pref
		checker: checker.new_checker(table, pref)
		global_scope: &ast.Scope{
			parent: 0
		}
		compiled_dir: compiled_dir
		table: table
	}
}

pub fn compile_builtin_files(pref &pref.Preferences) {
	mut b := new_builder(pref)
	mut c := checker.new_checker(b.table, pref)

	println("get files")
	files := b.get_all_src_files()

	println("parse files")
	parsed_files := parser.parse_files(files, b.table, b.pref, b.global_scope)

	println("check files")
	c.check_files(parsed_files)

	if c.errors.len == 0 {
		println("convert builtin files to module")
		gen.gen_builtin_module(pref.out_dir[0], b.table, parsed_files)
	}
}

pub fn compile(pref &pref.Preferences) {
	os.is_writable_folder(pref.paths[0]) or {
		// An early error here, is better than an unclear C error later:
		//verror(err.msg)
		exit(1)
	}

	mut b := new_builder(pref)
	mut c := checker.new_checker(b.table, pref)

	b.load_builtin_files()

	print("input - ")
	files := b.get_all_src_files()
	println(files.len.str() + " files")

	print("parse all files: ")
	mut sw := time.new_stopwatch({})
	sw.start()
	parsed_files := parser.parse_files(files, b.table, b.pref, b.global_scope)
	println('${f32(sw.elapsed().microseconds()) / 1000} ms')
	
	print("check all files: ")
	sw.start()
	c.check_files(parsed_files)
	println('${f32(sw.elapsed().microseconds()) / 1000} ms')

	cache_dir := os.dir(os.args[0]) + "//.papyrus"
	
	if !os.exists(cache_dir) {
		os.mkdir(cache_dir) or { panic(err) }
	}

	assert os.is_dir(cache_dir)

	if c.errors.len == 0 {
		for pfile in parsed_files {
			if b.is_outdated(pfile) {
				sw.start()

				pex_file := gen.gen(b.table, pfile)
				output_file_path := b.compiled_dir + "/" + pfile.file_name + ".pex"
				pex.write(output_file_path, pex_file)
				
				if b.pref.out_dir.len > 1 {
					os.cp(output_file_path, b.pref.out_dir[1] + "/" + pfile.file_name + ".pex") or { panic(err) }
				}
				
				t := f32(sw.elapsed().microseconds()) / 1000

				println("compile: `$pfile.path` - $t ms")
			}
		}
	}
}

fn (mut b Builder) load_builtin_files()  {
	path := os.dir(os.args[0]) + "\\builtin"
	
	if os.is_dir(path) {
		files := os.walk_ext(os.dir(os.args[0]) + "\\builtin", ".psc")
		parser.parse_files(files, b.table, b.pref, b.global_scope)
	}
	else {
		panic("invalid builtin dir - `$path`")
	}
}

pub fn (b Builder) get_all_src_files() []string {
	mut files := []string{}

	mut i := 0
	for i < b.pref.paths.len {
		path := b.pref.paths[i]
		files << os.walk_ext(path, ".psc")
		i++
	}

	return files
}