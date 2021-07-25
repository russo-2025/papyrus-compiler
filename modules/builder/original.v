module builder

import os

import pref

struct BuilderOrigin {
mut:
	builtin_path	string
	input_paths		[]string
	output_path		string
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
	real_path := os.real_path(path)

	if !os.is_dir(real_path) {
		panic('invalid input path \n`$path` -> `$real_path`')
	}

	b.input_paths << real_path
	b.input_paths << walk(real_path)
}

fn (mut b BuilderOrigin) set_builtin_path(path string) {
	real_path := os.real_path(path)

	if !os.is_dir(real_path) {
		panic('invalid builtin path \n`$path` -> `$real_path`')
	}

	b.builtin_path = real_path
}

fn (mut b BuilderOrigin) set_output_path(path string) {
	real_path := os.real_path(path)

	if !os.is_dir(real_path) {
		panic('invalid output path \n`$path` -> `$real_path`')
	}

	b.output_path = real_path
}

/*

-i="D:\_projects\skymp5-papyrus\bin\builtin"
-i="D:\_projects\hive-workspace\scripts\Custom"
-i="D:\_projects\hive-workspace\scripts\Custom\Debug"
-i="D:\_projects\hive-workspace\scripts\Custom\FrontCommands"
-i="D:\_projects\hive-workspace\scripts\Custom\Profession"
-i="D:\_projects\hive-workspace\scripts\Custom\Systems"
-i="D:\_projects\hive-workspace\scripts\Custom\Test"

*/

fn (mut b BuilderOrigin) run() {
	//<PapyrusCompiler.exe> <folder> -i="<scripts folder>" -o="Data\Scripts" -f="TESV_Papyrus_Flags.flg"
	compiler_path := os.real_path('./Original Compiler/PapyrusCompiler.exe')
	flags_file_path := os.real_path('./Original Compiler/TESV_Papyrus_Flags.flg')

	mut all_inputs := ""

	all_inputs += '-i="'

	all_inputs += b.builtin_path + ";"

	for path in b.input_paths {
		all_inputs += '$path' + ";"
	}

	all_inputs = all_inputs[..all_inputs.len-1] + '"'

	for path in b.input_paths {
		cmd := '"$compiler_path" "$path" -all -quiet $all_inputs -o="$b.output_path" -f="$flags_file_path"'
		res := os.system(cmd)
		println(res)
	}


/*
	cmd := '"$compiler_path" "D:\\_projects\\hive-workspace\\scripts\\GM\\M.psc" -quiet $all_inputs -o="$b.output_path" -f="$flags_file_path"'
	res := os.system(cmd)
	println(res)
*/
}

pub fn compile_original(pref &pref.Preferences) {

	mut b := BuilderOrigin{}
	
	b.set_builtin_path('./builtin')

	for path in pref.paths {
		b.add_input_path(path)
	}

	b.set_output_path(pref.out_dir[0])

	b.run()
}