module builder

import os
import time
import runtime
import datatypes
//import json

import pref
import papyrus.ast
import papyrus.parser
import papyrus.checker
import gen.gen_pex
import pex

const (
	cache_path = os.real_path('./.papyrus')
	compiler_exe_path = os.real_path('./Original Compiler/PapyrusCompiler.exe')
	compiler_flags_path = os.real_path('./Original Compiler/TESV_Papyrus_Flags.flg')
)

struct Builder {
mut:
	timers			map[string]time.StopWatch
pub:
	checker			checker.Checker
pub mut:
	generator		gen_pex.Gen
	pref			&pref.Preferences
	global_scope	&ast.Scope
	files_names		[]string
	parsed_files	[]&ast.File
	table			&ast.Table
}

fn new_builder(prefs &pref.Preferences) Builder{
	mut table := ast.new_table()
	
	return Builder{
		pref: prefs
		checker: checker.new_checker(table, prefs)
		generator: gen_pex.Gen {
			table: table
			pref: prefs
		}
		global_scope: &ast.Scope{}
		table: table
	}
}

pub fn compile(prefs &pref.Preferences) bool {
	if prefs.backend == .original {
		compile_original(prefs)
		return true
	}

	os.ensure_folder_is_writable(prefs.paths[0]) or {
		panic(err)
	}

	mut b := new_builder(prefs)
	mut c := checker.new_checker(b.table, b.pref)

	files, files_names := find_all_src_files(b.pref.paths)
	b.files_names = files_names
	assert b.files_names.len == files.len

	b.print("${files.len} files in total")
	b.start_timer('parse files')

	b.parsed_files = parser.parse_files(files, mut b.table, b.pref, mut b.global_scope)

	mut not_exist_scripts := []string{}
	for mut sym in b.table.types {
		if sym.name == "reserved_0" {
			continue
		}
		
		if sym.kind	== .script {
			not_exist_scripts << sym.deps
		}
		else if sym.kind == .placeholder {
			not_exist_scripts << sym.name

			if sym.parent_idx != 0 {
				// todo
			}
		}
	}
	println(not_exist_scripts)

	assert b.parsed_files.len == files.len

	b.start_timer('parse headers files')
	//b.parse_headers_files(not_exist_scripts)
	b.parse_deps(not_exist_scripts)
	b.print_timer('parse headers files')

	b.print_timer('parse files')

	//$if debug { b.table.save_as_json("Table.json") }
	
	//fns_dump.load("FunctionsDump.json", mut b.table) or { panic(err) }

	b.start_timer('check files')
	c.check_files(mut b.parsed_files)
	b.print_timer('check files')

	if !os.exists(cache_path) {
		os.mkdir(cache_path) or { panic(err) }
	}

	if c.errors.len != 0 {
		println("failed to compile files, ${c.errors.len} errors")

		$if test {
			assert false, "checker.errors.len != 0"
		}

		return false
	}
	
	if b.pref.stats_enabled {
		b.save_stats()
	}

	b.start_timer('gen files')
	
	match b.pref.backend {
		.pex {
			b.compile_pex()
		}
		else { panic('invalid compiler backend') }
	}

	b.print_timer('gen files')

	return true
}

fn (mut b Builder) compile_pex() {
	if b.pref.use_threads {
		mut max_threads_count := runtime.nr_cpus()

		if max_threads_count > 8 {
			max_threads_count = 8
		}

		if max_threads_count > b.parsed_files.len {
			max_threads_count = b.parsed_files.len
		}

		mut threads := []thread{}

		mut cur_index := 0
		max_len := b.parsed_files.len
		work_len := max_len / max_threads_count
		
		b.print("${max_threads_count} threads are used")

		for i in 0 .. max_threads_count {
			start_index := cur_index
			cur_index += work_len
			end_index := if cur_index + work_len > max_len { max_len } else { cur_index }
			threads << spawn b.create_worker(i, start_index, end_index)
		}

		threads.wait()
	}
	else {
		mut buff_bytes := pex.Buffer{ bytes: []u8{ cap: 10000 } }

		for i := 0; i < b.parsed_files.len; i++ {
			assert buff_bytes.is_empty()
			
			b.gen_to_pex_file(mut b.parsed_files[i], mut buff_bytes)
			buff_bytes.clear()
		}
	}
}


fn (mut b Builder) gen_to_pex_file(mut parsed_file ast.File, mut buff_bytes pex.Buffer) {
	if is_outdated(parsed_file, b.pref) {
		output_file_name := parsed_file.file_name + ".pex"
		output_file_path := os.join_path(b.pref.output_dir, output_file_name)
		
		//mut pex_file := gen_pex.gen_pex_file(mut parsed_file, mut b.table, b.pref)
		mut pex_file := b.generator.gen(mut parsed_file)

		pex.write_to_buff(mut pex_file, mut buff_bytes)
		
		assert !buff_bytes.is_empty()
		
		mut file := os.create(output_file_path) or { panic(err) }
		file.write(buff_bytes.bytes) or { panic(err) }
		file.close()
		
		//os.write_file_array(output_file_path, buff_bytes.bytes) or { panic(err) }
	}
}

fn (mut b Builder) create_worker(worker_id int, start_index int, end_index int) {
	b.print("gen in task(${worker_id}): ${start_index} - ${end_index}")
	mut buff_bytes := pex.Buffer{ bytes: []u8{ cap: 10000 } }

	for i in start_index .. end_index {
		assert buff_bytes.is_empty()
		mut parsed_file := b.parsed_files[i]

		b.gen_to_pex_file(mut parsed_file, mut buff_bytes)
		buff_bytes.clear()
	}
}

@[inline]
fn (mut b Builder) start_timer(name string) {
	b.timers[name] = time.new_stopwatch()
}

@[inline]
fn (mut b Builder) print_timer(name string) {
	if sw := b.timers[name] {
		time_ms := f32(sw.elapsed().microseconds()) / 1000
		b.print('$name: $time_ms ms')
		b.timers.delete(name)
	}
	else {
		panic('invalid timer')
	}
}
/*
fn (mut b Builder) register_info_from_dump(dump_obj &pex.DumpObject) {
	mut parent_idx := 0

	if dump_obj.parent_name != "" {
		parent_idx = b.table.find_or_add_placeholder_type(dump_obj.parent_name)
	}

	b.table.register_object(dump_obj.name)
	b.table.register_type_symbol(
		parent_idx: parent_idx
		kind: .script
		name: dump_obj.name
		obj_name: dump_obj.name
		methods: []ast.Fn{}
	)

	mut sym := b.table.find_type(dump_obj.name) or { panic("failed to find type") }

	for dump_method in dump_obj.methods {
		if !sym.has_method(dump_method.name) {
			mut tmethod := ast.Fn {
				return_type: b.table.find_or_add_placeholder_type(dump_method.return_type)
				obj_name: dump_obj.name
				state_name: pex.empty_state_name
				params: []ast.Param{}
				name: dump_method.name
				lname: dump_method.name.to_lower()
				is_native: dump_method.is_native
			}

			for dump_arg in dump_method.arguments {
				tmethod.params << ast.Param{
					name: dump_arg.name
					typ: b.table.find_or_add_placeholder_type(dump_arg.typ)
					//is_optional		bool
					//default_value	string
				}
			}

			sym.register_method(tmethod)
		}
	}
}
*/

/*
fn (mut b Builder) parse_headers_files(header_names []string)  {
	//b.pref.header_dirs.filter(os.is_dir(it))
	//headers_paths := b.find_all_headers(header_names)
	//parser.parse_files(headers_paths, mut b.table, b.pref, mut b.global_scope)
	//headers_paths.filter(it !in b.pref.paths)

	b.parse_deps(header_names)
}
*/
fn (mut b Builder) parse_deps(arg_deps []string)  {
	mut deps := []string{}
	deps << arg_deps
	for dep in deps {
		name := dep
		typ := b.table.find_type_idx(name)
		if typ != 0 && b.table.type_is_script(typ) {
			continue
		}
		path := b.find_header(name) or { continue }
		file := parser.parse_file(path, mut b.table, b.pref, mut b.global_scope)
		deps << file.deps

		//println("header `${path}` parsed")
	}
}

fn (b Builder) save_stats() {
	mut stats := Stats{}
	stats.from_table(b.table)
	stats.from_files(b.parsed_files)
	stats.save()
}

@[inline]
fn (b Builder) print(msg string) {
	if b.pref.output_mode == .silent {
		return
	}

	println(msg)
}

fn (mut b Builder) find_header(name string) ?string {
	for dir in b.pref.header_dirs {
		file := os.join_path(dir, name + ".psc")
		
		if os.is_file(file) {
			return file
		}
	}

	return none
}
/*
fn (mut b Builder) find_all_headers(names []string) []string {
	mut headers := []string{}

	for_names: for name in names {
		for_dirs: for dir in b.pref.header_dirs {
			file := os.join_path(dir, name + ".psc")
			
			if !os.is_file(file) {
				continue
			}

			headers << file

			continue for_names
		}
	}

	println(headers)
	/*
	rev_dirs := dirs.reverse()
	mut headers := []string{}
	mut found_names := []string{}

	mut ref_headers := &headers
	mut ref_found_names := &found_names

	for dir in rev_dirs {
		os.walk(dir, fn[b, mut ref_headers, mut ref_found_names](file string) {
			name := os.file_name(file).all_before_last(".").to_lower()

			if os.is_file(file) && os.file_ext(file).to_lower() == ".psc" && name !in b.files_names && name !in ref_found_names {
				ref_headers << file
				ref_found_names << name
			}
		})
	}
	*/

	return headers
}
*/
fn find_all_src_files(paths []string) ([]string, []string) {
	mut files := []string{}
	mut names := []string{}

	for path in paths {
		files << os.walk_ext(path, ".psc")
	}

	for file in files {
		names << os.file_name(file).all_before_last(".").to_lower()
	}

	return files, names
}