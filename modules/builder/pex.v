module builder

import os
import runtime
import pex
import datatypes
import papyrus.ast
import papyrus.parser
import papyrus.checker

@[inline]
fn (mut b Builder) compile_pex() {
	b.print("${b.files.len} files in total")

	b.start_timer('parse files')
	b.parsed_files = parser.parse_files(b.files, mut b.table, b.pref, mut b.global_scope)
	b.print_timer('parse files')

	assert b.parsed_files.len == b.files.len

	b.start_timer('parse headers files')
	b.parse_deps()
	b.print_timer('parse headers files')

	//$if debug { b.table.save_as_json("Table.json") }
	
	//fns_dump.load("FunctionsDump.json", mut b.table) or { panic(err) }

	b.start_timer('check files')
	mut c := checker.new_checker(b.table, b.pref)
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

		exit(1)
	}

	if b.pref.backend == .check {
		return
	}

	if b.pref.stats_enabled {
		b.save_stats()
	}

	b.start_timer('gen files')

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

	b.print_timer('gen files')
}

@[inline]
fn (mut b Builder) gen_to_pex_file(mut parsed_file ast.File, mut buff_bytes pex.Buffer) {
	if is_outdated(parsed_file, b.pref) {
		output_file_name := parsed_file.file_name + ".pex"
		output_file_path := os.join_path(b.pref.output_dir, output_file_name)
		
		mut pex_file := b.generator.gen(mut parsed_file)

		pex.write_to_buff(mut pex_file, mut buff_bytes)
		
		assert !buff_bytes.is_empty()
		
		mut file := os.create(output_file_path) or { panic(err) }
		file.write(buff_bytes.bytes) or { panic(err) }
		file.close()
	}
}

@[inline]
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
fn (mut b Builder) parse_deps()  {
	//mut deps := []string{}
	mut q := datatypes.Queue[string]{}

	for mut sym in b.table.types {
		if sym.name == "reserved_0" {
			continue
		}
		
		if sym.kind == .script {
			//deps << sym.deps
			for tdep in sym.deps {
				q.push(tdep)
			}

		}
		else if sym.kind == .placeholder {
			//deps << sym.name
			q.push(sym.name)
		}
	}

	println(q.array().sorted())


	for !q.is_empty() {
		name := q.pop() or { continue }
	//for dep in deps {
	//	name := dep
		typ := b.table.find_type_idx(name)
		if typ != 0 && b.table.type_is_script(typ) {
			continue
		}
		path := b.find_header(name) or {
			//println("header not found `${name}`")
			continue
		}
		
		file := parser.parse_file(path, mut b.table, b.pref, mut b.global_scope)
		//deps << file.deps
		for tdep in file.deps {
			q.push(tdep)
		}

		println("header `${name}` - `${path}` parsed, deps: ${file.deps}")
	}
	/*
	mut udeps := map[string]u8{}
	mut udeps_ptr := &udeps
	deps.map(fn[mut udeps_ptr](it string) string { udeps_ptr[it.to_lower()] = 1 return it})

	println("deps len ${udeps.keys().sorted().len}")
	println(udeps.keys().sorted())
	*/
}