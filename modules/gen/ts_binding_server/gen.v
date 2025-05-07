module ts_binding_server

import papyrus.ast
import strings
import os

@[heap]
struct Gen {
mut:
	table					ast.Table
	file_by_name			map[string]&ast.File

// server ts header file
	server_ts_h				strings.Builder
// server main h file
	server_main_cpp			strings.Builder
// server main cpp file
	server_main_h			strings.Builder
}

pub fn gen(mut files []&ast.File, mut table ast.Table, output_dir string) {
	println("generate server bindings")

	mut g := Gen{
		server_ts_h: strings.new_builder(1000)
		server_main_cpp: strings.new_builder(1000)
		server_main_h: strings.new_builder(1000)
		table: table
		file_by_name: map[string]&ast.File{}
	}

	for file in files {
		g.file_by_name[file.obj_name.to_lower()] = file
	}

	g.gen_server_main_h_file()
	g.gen_server_main_cpp_file()
	g.gen_server_main_ts_h_file()

	os.write_file(os.join_path(output_dir, "__js_bindings.h"), g.server_main_h.str()) or { panic("write_file err") }
	os.write_file(os.join_path(output_dir, "__js_bindings.cpp"), g.server_main_cpp.str()) or { panic("write_file err") }
	os.write_file(os.join_path(output_dir, "papyrusObjects.d.ts"), g.server_ts_h.str()) or { panic("write_file err") }
}
