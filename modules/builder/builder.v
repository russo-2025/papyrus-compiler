module builder

import os
import time
import runtime
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
	pref			&pref.Preferences
	checker			checker.Checker
	global_scope	&ast.Scope
pub mut:
	files_names		[]string
	parsed_files	[]ast.File
	table			&ast.Table
}

fn new_builder(prefs &pref.Preferences) Builder{
	mut table := ast.new_table()
	
	return Builder{
		pref: prefs
		checker: checker.new_checker(table, prefs)
		global_scope: &ast.Scope{
			parent: 0
		}
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

	b.start_timer('parse headers files')
	b.parse_headers_files()
	b.print_timer('parse headers files')

	println("${files.len} files in total")
	b.start_timer('parse files')
	b.parsed_files = parser.parse_files(files, b.table, b.pref, b.global_scope)
	b.print_timer('parse files')

	/*$if debug {
		b.table.save_as_json("Table.json")
	}*/
	
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
/*
	b.save_info()
*/
	b.start_timer('gen files')
	
	match b.pref.backend {
		.pex {
			b.compile_pex(mut b.parsed_files)
		}
		else { panic('invalid compiler backend') }
	}

	b.print_timer('gen files')
	return true
}

fn (b Builder) compile_pex(mut parsed_files []ast.File) {
	if b.pref.use_threads {
		mut max_threads_count := runtime.nr_cpus()

		if max_threads_count > 8 {
			max_threads_count = 8
		}

		if max_threads_count > parsed_files.len {
			max_threads_count = parsed_files.len
		}

		mut threads := []thread{}

		mut cur_index := 0
		max_len := parsed_files.len
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

		for parsed_file in parsed_files{
			assert buff_bytes.is_empty()
			
			b.gen_to_pex_file(parsed_file, mut buff_bytes)
			buff_bytes.clear()
		}
	}
}


fn (b Builder) gen_to_pex_file(parsed_file &ast.File, mut buff_bytes pex.Buffer) {
	if is_outdated(parsed_file, b.pref) {
		output_file_name := parsed_file.file_name + ".pex"
		output_file_path := os.join_path(b.pref.output_dir, output_file_name)
		
		pex_file := gen_pex.gen_pex_file(parsed_file, b.table, b.pref)
		
		pex.write_to_buff(pex_file, mut buff_bytes)
		
		assert !buff_bytes.is_empty()
		mut file := os.create(output_file_path) or { panic(err) }
		file.write(buff_bytes.bytes) or { panic(err) }
		file.close()
	}
}

fn (b Builder) create_worker(worker_id int, start_index int, end_index int) {
	b.print("gen in task(${worker_id}): ${start_index} - ${end_index}")
	mut buff_bytes := pex.Buffer{ bytes: []u8{ cap: 10000 } }

	for i in start_index .. end_index {
		assert buff_bytes.is_empty()
		parsed_file := b.parsed_files[i]

		b.gen_to_pex_file(parsed_file, mut buff_bytes)
		buff_bytes.clear()
	}
}

[inline]
fn (mut b Builder) start_timer(name string) {
	b.timers[name] = time.new_stopwatch()
}

[inline]
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
fn (mut b Builder) parse_headers_files()  {
	if !os.is_dir(b.pref.papyrus_headers_dir) {
		panic("invalid papyrus headers dir - `${b.pref.papyrus_headers_dir}`")
	}
	/*
	mut dump_objects := []pex.DumpObject{}
	b.table.allow_override = true

	// load headers from Dump.json 
	if os.is_file("Dump.json") {
		json_data := os.read_file("Dump.json") or { panic(err) }
		dump_objects = json.decode([]pex.DumpObject, json_data) or { panic(err) }
		println("obj len: ${dump_objects.len}")

		for dump_obj in dump_objects {
			// if a file with this name already exists, skip it
			if dump_obj.name.to_lower() in b.files_names {
				continue
			}

			b.register_info_from_dump(dump_obj)
		}
	}

	// load headers from pex files
	files_pex := os.walk_ext(b.pref.papyrus_headers_dir, ".pex")
	dump_objects = pex.create_dump_from_pex_files(files_pex)
	println("obj len: ${dump_objects.len}")

	for dump_obj in dump_objects {
		// if a file with this name already exists, skip it
		if dump_obj.name.to_lower() in b.files_names {
			continue
		}

		b.register_info_from_dump(dump_obj)
	}
*/

	// load headers from psc(source) files 
	if b.pref.papyrus_headers_dir in b.pref.paths {
		// no need to parse the same file many times
		return 
	}
	
	mut header_files := []string{}
	mut ref_header_files := &header_files
	os.walk(b.pref.papyrus_headers_dir, fn[b, mut ref_header_files](file string) {
		name := os.file_name(file).all_before_last(".").to_lower()
		if os.is_file(file) && name !in b.files_names {
			ref_header_files << file
		}
	})

	parser.parse_files(header_files, b.table, b.pref, b.global_scope)
}
/*
fn (b Builder) save_info() {
	mut all_fns_count := 0
	mut methods_count := 0
	mut methods_native_count := 0
	mut global_fns_count := 0
	mut global_native_fns_count := 0

	for tsym in b.table.types {
		for tmethod in tsym.methods {
			all_fns_count++

			if tmethod.is_native {
				methods_native_count++
			}
			else {
				methods_count++
			}
		}
	}

	for _, tfunc in b.table.fns {
		all_fns_count++

		if tfunc.is_native {
			global_native_fns_count++
		}
		else {
			global_fns_count++
		}
	}

	println("total functions(all): ${all_fns_count}")
	println("total methods(no native): ${methods_count}")
	println("total methods(native): ${methods_native_count}")
	println("total global func`s(no native): ${global_fns_count}")
	println("total global func`s(native): ${global_native_fns_count}")
	
}
*/
[inline]
fn (b Builder) print(msg string) {
	if b.pref.output_mode == .silent {
		return
	}

	println(msg)
}

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