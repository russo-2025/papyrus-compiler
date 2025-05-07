module ts_binding_client

import papyrus.ast
import strings
import os
import json

@[heap]
struct Gen {
mut:
	table					ast.Table
	client_impl_classes		map[string]string
	parents_of_objects		map[ast.Type]map[ast.Type]u8
	no_instance_class		[]ast.Type
	file_by_name			map[string]&ast.File

// func reg all object wrappers
	main_register_func		strings.Builder = strings.new_builder(300)
// main files
	b_main_client_ts		strings.Builder = strings.new_builder(1000)
	b_main_client_h			strings.Builder = strings.new_builder(1000)
	b_main_client_cpp		strings.Builder = strings.new_builder(1000)
// rpc files
	b_rpc_client_cpp		strings.Builder = strings.new_builder(1000)
	b_rpc_server_cpp		strings.Builder = strings.new_builder(1000)
	b_rpc_server_h			strings.Builder = strings.new_builder(1000)

// server ts header file
	server_ts_h				strings.Builder = strings.new_builder(1000)
// server main h file
	server_main_cpp			strings.Builder = strings.new_builder(1000)
// server main cpp file
	server_main_h			strings.Builder = strings.new_builder(1000)
}

pub fn gen(mut client_files []&ast.File, mut client_table ast.Table, mut server_files []&ast.File, mut server_table ast.Table, output_dir string) {
	println("generate bindings")

	mut g := Gen{
		table: client_table
		file_by_name: map[string]&ast.File{}
		client_impl_classes: map[string]string{}
		parents_of_objects: map[ast.Type]map[ast.Type]u8{}
		no_instance_class: []ast.Type{ cap: 7 }
	}

	client_output_dir := os.join_path(output_dir, "client")
	if !os.is_dir(client_output_dir) {
		os.mkdir_all(client_output_dir, os.MkdirParams{}) or {
			panic("Failed to create output directory")
		}
		
		println("output dir created `${client_output_dir}`")
	}

	server_output_dir := os.join_path(output_dir, "server")
	if !os.is_dir(server_output_dir) {
		os.mkdir_all(server_output_dir, os.MkdirParams{}) or {
			panic("Failed to create output directory")
		}
		
		println("output dir created `${server_output_dir}`")
	}

	println("using client output dir `${client_output_dir}`")
	println("using server output dir `${server_output_dir}`")

	println("parse config file")
	g.parse_config_file()
	
	println("prepare")
	g.fill_files_map(mut client_files)
	g.fill_child_objects_map()
	
	println("generate client files")
	g.gen_client_main_h_file()
	g.gen_client_ts_h_file()
	g.gen_client_main_cpp_file()
	g.gen_rpc_client()
	g.gen_rpc_server()

	println("write client files")
	os.write_file(os.join_path(client_output_dir, "__js_rpc_client_bindings.cpp"), g.b_rpc_client_cpp.str()) or { panic(err) }
	os.write_file(os.join_path(client_output_dir, "__js_rpc_server_bindings.cpp"), g.b_rpc_server_cpp.str()) or { panic(err) }
	os.write_file(os.join_path(client_output_dir, "__js_rpc_server_bindings.h"), g.b_rpc_server_h.str()) or { panic(err) }
	os.write_file(os.join_path(client_output_dir, "__js_bindings.h"), g.b_main_client_h.str()) or { panic(err) }
	os.write_file(os.join_path(client_output_dir, "__js_bindings.cpp"), g.b_main_client_cpp.str()) or { panic(err) }
	os.write_file(os.join_path(client_output_dir, "papyrusObjects.d.ts"), g.b_main_client_ts.str()) or { panic(err) }

	println("cleanup and prepare")
	g.clear()
	g.table = server_table
	g.fill_files_map(mut server_files)
	g.fill_child_objects_map()

	println("generate server files")
	g.gen_server_main_h_file()
	g.gen_server_main_cpp_file()
	g.gen_server_main_ts_h_file()

	println("write server files")
	os.write_file(os.join_path(server_output_dir, "__js_bindings.h"), g.server_main_h.str()) or { panic("write_file err") }
	os.write_file(os.join_path(server_output_dir, "__js_bindings.cpp"), g.server_main_cpp.str()) or { panic("write_file err") }
	os.write_file(os.join_path(server_output_dir, "papyrusObjects.d.ts"), g.server_ts_h.str()) or { panic("write_file err") }
}

fn (mut g Gen) fill_files_map(mut files []&ast.File) {
	for file in files {
		g.file_by_name[file.obj_name.to_lower()] = file
	}
}

fn (mut g Gen) fill_child_objects_map() {
	// fill map of child objects of the object
	g.each_all_types(fn(mut g Gen, idx ast.Type, sym &ast.TypeSymbol) {
		if sym.kind != .script {
			return
		}
		if sym.parent_idx != 0 {
			g.parents_of_objects[sym.parent_idx][idx] = 1
		}
	})

	for parent_idx, child_arr_idx in g.parents_of_objects {
		mut arr := child_arr_idx.keys()

		for i := 0; i < arr.len; i++ {
			child_idx := arr[i]
			arr << g.parents_of_objects[child_idx].keys()
		}
		
		for key in arr {
			g.parents_of_objects[parent_idx][key] = 1
		}
	}

	for parent_idx, childs in g.parents_of_objects {
		parent_sym := g.table.get_type_symbol(parent_idx)
		print(parent_sym.name)
		print(" - ")
		for child_idx in childs.keys() {
			child_sym := g.table.get_type_symbol(child_idx)
			print(child_sym.name)
			print(",")
		}
		println("")
	}
}

struct JsonCompileSettings {
	client_impl_classes		map[string]string
	no_instance_class		[]string
}

const settings_file_name = "compileSettings.json"

fn (mut g Gen) parse_config_file() {
	if !os.is_file("${settings_file_name}") {
		eprintln("!!! file ${settings_file_name} not found in `${os.getwd()}`")
		exit(1)
	}
	
	println("uses ${settings_file_name} from ${os.getwd()}")
	json_data := os.read_file("${settings_file_name}") or { panic(err) }
	data := json.decode(JsonCompileSettings, json_data) or { panic(err) }

	for papyrus_name, impl_name in data.client_impl_classes {
		g.client_impl_classes[papyrus_name.to_lower()] = impl_name
	}

	for name in data.no_instance_class {
		idx := g.table.find_type_idx(name)
		if idx == 0 {
			continue
		}

		g.no_instance_class << idx
	}
}

fn (mut g Gen) clear() {
	g.file_by_name = map[string]&ast.File{}
	g.parents_of_objects = map[ast.Type]map[ast.Type]u8{}
	g.no_instance_class = []ast.Type{ cap: 7 }
}