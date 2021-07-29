module builder

import os
import time

import pref
import papyrus.ast
import papyrus.parser
import papyrus.checker
import pex
import gen.pex as gen_pex

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

fn compile_pex(pref &pref.Preferences) {
	os.is_writable_folder(pref.paths[0]) or {
		// An early error here, is better than an unclear C error later:
		//verror(err.msg)
		exit(1)
	}

	mut b := new_builder(pref)
	mut c := checker.new_checker(b.table, b.pref)

	//mut sw := time.new_stopwatch({})
	
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

	if c.errors.len == 0 {
		for pfile in parsed_files {
			if b.is_outdated(pfile) {
				b.start_timer('gen file `$pfile.path`')

				pex_file := gen_pex.gen(pfile, b.table, b.pref)
				output_file_name := pfile.file_name + ".pex"
				output_file_path := os.join_path(b.output_dir, output_file_name)
				pex.write(output_file_path, pex_file)
				
				if b.pref.out_dir.len > 1 {
					os.cp(output_file_path, os.join_path(b.pref.out_dir[1], output_file_name)) or { panic(err) }
				}

				b.print_timer('gen file `$pfile.path`')
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

struct CacheFile {
pub mut:
	last_mod_time	int
}

fn read_cache(path string) &CacheFile {
	mut file := os.open(path) or { panic(err) }
	mut cache := CacheFile{}
	file.read_struct(cache) or { panic(err) }
	file.close()
	return &cache
}

fn write_cache(path string, cache &CacheFile) {
	mut file := os.create(path) or { panic(err) }
	file.write_struct(cache) or { panic(err) }
	file.close()
}

fn (mut b Builder) is_outdated(pfile &ast.File) bool {
	if b.pref.no_cache {
		return true
	}
	
	path := os.join_path(cache_path, pfile.file_name + ".obj")
	
	if os.is_file(path) {
		mut cache := read_cache(path)
		
		if cache.last_mod_time == pfile.last_mod_time {
			return false
		}
		else {
			cache.last_mod_time = pfile.last_mod_time
			write_cache(path, cache)
			return true
		}
	}
	else {
		mut cache := CacheFile{}
		cache.last_mod_time = pfile.last_mod_time
		write_cache(path, cache)
		return true
	}
}