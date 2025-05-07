module ts_binding_client

import papyrus.ast
import strings
import os
import json

@[heap]
struct Gen {
mut:
	table					ast.Table
	impl_classes			map[string]string
	parents_of_objects		map[ast.Type]map[ast.Type]u8
	no_instance_class		[]ast.Type

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

// temp
	file_by_name			map[string]&ast.File
	fns						[]ast.FnDecl
	temp_args				strings.Builder = strings.new_builder(200)
	form_idx				ast.Type
}

struct JsonCompileSettings {
	impl_classes		map[string]string
	no_instance_class	[]string
}

const settings_file_name = "clientCompileSettings.json"

pub fn gen(mut files []&ast.File, mut table ast.Table, output_dir string) {
	println("generate client bindings")

	mut g := Gen{
		table: table
		file_by_name: map[string]&ast.File{}
		impl_classes: map[string]string{}
		form_idx: table.find_type_idx("form")
		parents_of_objects: map[ast.Type]map[ast.Type]u8{}
		no_instance_class: []ast.Type{ cap: 7 }
	}

	// parse compile config file
	if os.is_file("${settings_file_name}") {
		println("uses ${settings_file_name} from ${os.getwd()}")
		json_data := os.read_file("${settings_file_name}") or { panic(err) }
		data := json.decode(JsonCompileSettings, json_data) or { panic(err) }

		for papyrus_name, impl_name in data.impl_classes {
			g.impl_classes[papyrus_name.to_lower()] = impl_name
		}

		for name in data.no_instance_class {
			idx := g.table.find_type_idx(name)
			if idx == 0 {
				continue
			}

			g.no_instance_class << idx
		}
	}
	else {
		eprintln("!!! file ${settings_file_name} not found in `${os.getwd()}`")
		exit(1)
	}

	// fill map of child objects of the object
	for file in files {
		g.file_by_name[file.obj_name.to_lower()] = file
	}

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
	
	g.gen_client_main_h_file()
	g.gen_client_ts_h_file()
	g.gen_client_main_cpp_file()
	g.gen_rpc_client()
	g.gen_rpc_server()

	// create output files
	os.write_file(os.join_path(output_dir, "__js_rpc_client_bindings.cpp"), g.b_rpc_client_cpp.str()) or { panic(err) }
	os.write_file(os.join_path(output_dir, "__js_rpc_server_bindings.cpp"), g.b_rpc_server_cpp.str()) or { panic(err) }
	os.write_file(os.join_path(output_dir, "__js_rpc_server_bindings.h"), g.b_rpc_server_h.str()) or { panic(err) }
	os.write_file(os.join_path(output_dir, "__js_bindings.h"), g.b_main_client_h.str()) or { panic(err) }
	os.write_file(os.join_path(output_dir, "__js_bindings.cpp"), g.b_main_client_cpp.str()) or { panic(err) }
	os.write_file(os.join_path(output_dir, "papyrusObjects.d.ts"), g.b_main_client_ts.str()) or { panic(err) }
}