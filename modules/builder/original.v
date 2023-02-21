module builder

import os

import pref

//https://www.creationkit.com/index.php?title=Papyrus_Compiler_Reference

struct BuilderOrigin {
mut:
	papyrus_headers_dir	string
	input_paths			[]string
	output_path			string
}

fn walk(parent_path string) []string {
	mut result := []string{}
	
	files := os.ls(parent_path) or { panic(err) }
	for file in files {
		path := os.join_path(parent_path, file)
		if os.is_dir(path) {
			result << path
		}
	}
	
	return result
} 

fn (mut b BuilderOrigin) add_input_path(path string) {
	if !os.is_dir(path) {
		panic('invalid input path \n`$path`')
	}

	b.input_paths << path
	b.input_paths << walk(path)
}

fn (mut b BuilderOrigin) set_headers_path(path string) {
	if !os.is_dir(path) {
		panic('invalid papyrus headers dir \n`$path`')
	}

	b.papyrus_headers_dir = path
}

fn (mut b BuilderOrigin) set_output_path(path string) {
	if !os.is_dir(path) {
		panic('invalid output path \n`$path`')
	}

	b.output_path = path
}

fn (mut b BuilderOrigin) run() {
	mut all_inputs := ""

	all_inputs += '-i="'

	all_inputs += b.papyrus_headers_dir + ";"

	for path in b.input_paths {
		all_inputs += '$path' + ";"
	}

	all_inputs = all_inputs[..all_inputs.len-1] + '"'
	
	for path in b.input_paths {
		cmd := '"$compiler_exe_path" "$path" -all -quiet $all_inputs -o="$b.output_path" -f="$compiler_flags_path"'
		res := unsafe { os.raw_execute(cmd) }
		
		if res.exit_code == 0 {
			println('successfully - ${path}')
		}
		else {
			println('failed - ${path}')
			println(res.output)
		}
	}
}

fn compile_original(prefs &pref.Preferences) {
	$if windows {
		mut b := BuilderOrigin{}
		
		b.set_headers_path(prefs.papyrus_headers_dir)

		for path in prefs.paths {
			b.add_input_path(path)
		}

		b.set_output_path(prefs.out_dir[0])

		b.run()
	}
	$else {
		println("Original compiler is only available on Windows OS")
	}
}