module builder

import os
import time

import pref
import papyrus.ast
import papyrus.checker
import gen.gen_pex

const cache_path = os.real_path('./.papyrus')
const compiler_exe_path = os.real_path('./Original Compiler/PapyrusCompiler.exe')
const compiler_flags_path = os.real_path('./Original Compiler/TESV_Papyrus_Flags.flg')

struct Builder {
mut:
	timers			map[string]time.StopWatch
pub:
	checker			checker.Checker
pub mut:
	generator		gen_pex.Gen
	pref			&pref.Preferences
	global_scope	&ast.Scope
	files			[]string
	files_names		[]string
	parsed_files	[]&ast.File
	table			&ast.Table
}

@[inline]
pub fn compile(prefs &pref.Preferences) bool {
	mut b := new_builder(prefs)
	return b.run()
}

@[inline]
pub fn new_builder(prefs &pref.Preferences) Builder{
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

@[inline]
pub fn (mut b Builder) run() bool {
	for path in b.pref.paths {
		if os.is_dir(path) {
			b.pref.header_dirs << path
		}
		else if os.is_file(path) && os.file_ext(path).to_lower() == ".psc" {
			b.pref.header_dirs << os.dir(path)
		}
	}
	
	b.pref.header_dirs = b.pref.header_dirs.reverse()

	println("used header dirs ${b.pref.header_dirs}")

	b.files, b.files_names = find_all_src_files(b.pref.paths)
	
	match b.pref.backend {
		.check,
		.pex {
			b.compile_pex()
		}
		.original {
			$if windows {
				b.compile_original()
			}
			$else {
				println("Original compiler is only available on Windows OS")
			}
		}
	}

	return true
}

@[inline]
fn (mut b Builder) find_header(name string) ?string {
	for dir in b.pref.header_dirs {
		file := os.join_path(dir, name + ".psc")
		
		if os.is_file(file) {
			return file
		}
	}

	return none
}

@[inline]
fn find_all_src_files(paths []string) ([]string, []string) {
	mut files := []string{}
	mut names := []string{}
	
	for path in paths {
		if os.is_dir(path) {
			files << os.walk_ext(path, ".psc")
		}
		else if os.is_file(path) && os.file_ext(path).to_lower() == ".psc" {
			files << path
		}
	}

	for file in files {
		names << os.file_name(file).all_before_last(".").to_lower()
	}

	assert names.len == files.len

	return files, names
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