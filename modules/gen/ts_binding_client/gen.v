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
// Init Fn - methods list
	init_methods_bind_cpp	strings.Builder = strings.new_builder(300)

// temp
	obj_type				ast.Type 
	sym						&ast.TypeSymbol = unsafe { voidptr(0) }
	psym					&ast.TypeSymbol = unsafe { voidptr(0) }
	obj_name				string
	parent_obj_name			string
	file_by_name			map[string]&ast.File
	fns						[]ast.FnDecl
	pfns					[]ast.FnDecl
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
	
	// write start file text
	g.b_main_client_h.writeln(h_start_file)
	g.b_main_client_cpp.writeln(cpp_start_file)
	g.b_main_client_ts.writeln(ts_start_file)
	g.gen_rpc_clint_start_file()
	g.gen_rpc_server_start_file()

	// write cpp - constructor list
	for file in files {
		g.b_main_client_cpp.writeln("static Napi::FunctionReference ${g.gen_ctor_name(file.obj_name)};")
	}

	// write h - cpp impl functions list
	g.each_files_fns(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File, func &ast.FnDecl){
		if func.return_type != ast.none_type {
			g.b_main_client_h.write_string(g.get_impl_type_name(func.return_type))
			g.b_main_client_h.write_string(" ")
		}
		else {
			g.b_main_client_h.write_string("void ")
		}

		g.b_main_client_h.write_string(g.get_real_impl_fn_name(sym.name, func.name))

		mut args_list := ""

		if !func.is_global {
			args_list += g.get_impl_type_name(g.table.find_type_idx(sym.name))
			args_list += " self"

			if func.params.len != 0 {
				args_list += ", "
			}
		}

		for i in 0..func.params.len {
			param := func.params[i]
			args_list += "${g.get_impl_type_name(param.typ)} ${param.name}"
			if i != func.params.len - 1 {
				args_list += ", "
			}
		}
		g.b_main_client_h.write_string("(")
		g.b_main_client_h.write_string(args_list)
		g.b_main_client_h.writeln(");")
	})

	// write h - rpc headers
	g.b_main_client_h.writeln("")

	// for each all stmts in files
	for file in files {
		g.pfns = []ast.FnDecl{}
		g.fns = []ast.FnDecl{}
		g.obj_name = file.obj_name
		g.obj_type = g.table.find_type_idx(file.obj_name)
		g.sym = g.table.get_type_symbol(g.obj_type)
		if g.sym.parent_idx != 0 {
			g.psym = g.table.get_type_symbol(g.sym.parent_idx)
			g.parent_obj_name = (file.stmts[0] as ast.ScriptDecl).parent_name
		}
		g.init_methods_bind_cpp.str() // clear

		for top_stmt in file.stmts {
			match top_stmt {
				ast.Comment {}
				ast.ScriptDecl {}
				ast.FnDecl {
					g.fns << top_stmt
				}
				else { panic("invalid top stmt ${top_stmt}") }
			}	
		}

		g.gen(file)
	}

	// write end of file
	g.b_main_client_h.writeln(g.create_rpc_headers())
	g.b_main_client_h.writeln(h_end_file)

	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("void RegisterAllVMObjects(Napi::Env env, Napi::Object exports)")
	g.b_main_client_cpp.writeln("{")
	g.b_main_client_cpp.writeln(g.main_register_func.str())
	g.b_main_client_cpp.writeln("}")
	g.b_main_client_cpp.writeln("}; // end namespace JSBinding")

	g.b_main_client_ts.writeln(ts_end_file)

	g.gen_rpc_clint_end_file()
	g.gen_rpc_server_end_file()
	
	// create output files
	os.write_file(os.join_path(output_dir, "__js_rpc_client_bindings.cpp"), g.b_rpc_client_cpp.str()) or { panic(err) }
	os.write_file(os.join_path(output_dir, "__js_rpc_server_bindings.cpp"), g.b_rpc_server_cpp.str()) or { panic(err) }
	os.write_file(os.join_path(output_dir, "__js_rpc_server_bindings.h"), g.b_rpc_server_h.str()) or { panic(err) }
	os.write_file(os.join_path(output_dir, "__js_bindings.h"), g.b_main_client_h.str()) or { panic(err) }
	os.write_file(os.join_path(output_dir, "__js_bindings.cpp"), g.b_main_client_cpp.str()) or { panic(err) }
	os.write_file(os.join_path(output_dir, "papyrusObjects.d.ts"), g.b_main_client_ts.str()) or { panic(err) }
}

fn (mut g Gen) gen_end_impl() {
	impl_type_name := g.get_impl_type_name(g.obj_type)
	impl_obj_type_name := g.get_impl_obj_type_name(g.obj_type)
	bind_class_name := g.gen_bind_class_name(g.obj_name)

	g.each_all_fns(g.sym, fn(mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl){
		js_class_name := g.gen_bind_class_name(g.sym.obj_name)
		js_fn_name := g.gen_js_fn_name(func.name)
		fn_name := func.name

		if func.is_global {
			g.init_methods_bind_cpp.write_string("\t\tStaticMethod(\"${fn_name}\", &${js_class_name}::${js_fn_name})")
		}
		else {
			g.init_methods_bind_cpp.write_string("\t\tInstanceMethod(\"${fn_name}\", &${js_class_name}::${js_fn_name})")
		}
		
		g.init_methods_bind_cpp.write_string(",\n")
	})
	
	if g.init_methods_bind_cpp.len > 0 {
		g.init_methods_bind_cpp.go_back(",\n".len) // remove last `,` + `\n`
	}

	g.b_main_client_cpp.writeln("Napi::Object ${bind_class_name}::Init(Napi::Env env, Napi::Object exports)")
	g.b_main_client_cpp.writeln("{")
	
	/*
	g.each_all_this_fns(g.sym, fn(mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl){
		is_static_str := if func.is_global { "true" } else { "false" }
		g.b_main_client_cpp.writeln("\t${g.get_fn_impl_name(sum.obj_name, func.name)} = VirtualMachine::GetInstance()->GetFunctionImplementation(\"${sum.obj_name}\", \"${func.name}\", ${is_static_str});")
		g.b_main_client_cpp.writeln("\tif(!${g.get_fn_impl_name(sum.obj_name, func.name)}){")
		g.b_main_client_cpp.writeln("\t\tERR(\"failed to find function in Papyrus VM: `${sum.obj_name}.${func.name}`\");")
		g.b_main_client_cpp.writeln("\t\tthrow std::runtime_error(\"failed to find function in Papyrus VM: `${sum.obj_name}.${func.name}`\");")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
	})
	*/

	g.b_main_client_cpp.writeln("\tNapi::HandleScope scope(env);")
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\tNapi::Function func = DefineClass(env, \"${g.obj_name}\", {")
	if !g.is_no_instance_class(g.obj_type) {
		g.b_main_client_cpp.writeln("\t\tStaticMethod(\"From\", &${bind_class_name}::From),")
		g.b_main_client_cpp.write_string("\t\tInstanceMethod(\"As\", &${bind_class_name}::As)")
		if g.init_methods_bind_cpp.len != 0 {
			g.b_main_client_cpp.writeln(",")
		}
		else {
			g.b_main_client_cpp.writeln("")
		}
	}
	g.b_main_client_cpp.writeln("${g.init_methods_bind_cpp.str()}")
	g.b_main_client_cpp.writeln("\t});")
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\t${g.gen_ctor_name(g.obj_name)} = Napi::Persistent(func);")
	g.b_main_client_cpp.writeln("\t${g.gen_ctor_name(g.obj_name)}.SuppressDestruct();")
	g.b_main_client_cpp.writeln("\texports.Set(\"${g.obj_name}\", func);")
	g.b_main_client_cpp.writeln("")
	g.b_main_client_cpp.writeln("\treturn exports;")
	g.b_main_client_cpp.writeln("}")

	g.b_main_client_cpp.writeln("")
	
	g.b_main_client_cpp.write_string("${bind_class_name}::${bind_class_name}(const Napi::CallbackInfo& info) : ObjectWrap(info)")

	g.b_main_client_cpp.writeln("{")
	g.b_main_client_cpp.writeln("}")

	g.b_main_client_cpp.writeln("")
	
	if !g.is_no_instance_class(g.obj_type) {
		g.b_main_client_cpp.writeln("Napi::Value ${bind_class_name}::From(const Napi::CallbackInfo& info)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\ttry")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tuint32_t formId = NapiHelper::ExtractUInt32(info[0], \"formId\");")
		g.b_main_client_cpp.writeln("\t\t${impl_type_name} obj = RE::TESForm::LookupByID<${impl_obj_type_name}>(formId);")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t\tif(!obj) {")
		g.b_main_client_cpp.writeln("\t\t\treturn info.Env().Null();")
		g.b_main_client_cpp.writeln("\t\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t\treturn ${g.gen_convert_to_napivalue(g.obj_type, "obj")};")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\tcatch(std::exception& e) {")
		g.b_main_client_cpp.writeln("\t\tERR((std::string)e.what());")
		g.b_main_client_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\treturn info.Env().Null();")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		g.b_main_client_cpp.writeln("Napi::Value ${bind_class_name}::As(const Napi::CallbackInfo& info)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\ttry")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tif(!${bind_class_name}::IsInstance(this->Value()))")
		g.b_main_client_cpp.writeln("\t\t{")
		g.b_main_client_cpp.writeln("\t\t\treturn info.Env().Null();")
		g.b_main_client_cpp.writeln("\t\t}")
		g.b_main_client_cpp.writeln("\t\tNapi::Value class_ctor = info[0];")
		g.each_all_parent(g.sym, fn(mut g Gen, file &ast.File, idx ast.Type, sym &ast.TypeSymbol) {
			cur_bind_class_name := g.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\t\tif(class_ctor == ${g.gen_ctor_name(sym.name)}.Value())")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\treturn ${cur_bind_class_name}::ToNapiValue(info.Env(), this->self->As<${g.get_impl_obj_type_name(idx)}>());")
			g.b_main_client_cpp.writeln("\t\t}")
		})
		g.each_all_child(g.obj_type, fn(mut g Gen, idx ast.Type, sym &ast.TypeSymbol){
			cur_bind_class_name := g.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\t\tif(class_ctor == ${g.gen_ctor_name(sym.name)}.Value())")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\treturn ${cur_bind_class_name}::ToNapiValue(info.Env(), this->self->As<${g.get_impl_obj_type_name(idx)}>());")
			g.b_main_client_cpp.writeln("\t\t}")
		})
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\tcatch(std::exception& e)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tERR((std::string)e.what());")
		g.b_main_client_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\treturn info.Env().Null();")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		g.b_main_client_cpp.writeln("${impl_type_name} ${bind_class_name}::Cast(const Napi::Value& value)")
		g.b_main_client_cpp.writeln("{")
		g.each_all_parent(g.sym, fn[impl_type_name, impl_obj_type_name](mut g Gen, file &ast.File, idx ast.Type, sym &ast.TypeSymbol) {
			cur_bind_class_name := g.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\tif(${cur_bind_class_name}::IsInstance(value))")
			g.b_main_client_cpp.writeln("\t{")
			g.b_main_client_cpp.writeln("\t\tNapi::Object obj = value.As<Napi::Object>();")
			g.b_main_client_cpp.writeln("\t\t${cur_bind_class_name}* wrapper = Napi::ObjectWrap<${cur_bind_class_name}>::Unwrap(obj);")
			g.b_main_client_cpp.writeln("\t\t${impl_type_name} res = wrapper->self->As<${impl_obj_type_name}>();")
			g.b_main_client_cpp.writeln("\t\tif (!res)")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\tstd::string errMsg = \"Failed to cast to `${impl_obj_type_name}`\";")
			g.b_main_client_cpp.writeln("\t\t\tERR(errMsg);")
			g.b_main_client_cpp.writeln("\t\t\tthrow Napi::Error::New(value.Env(), errMsg);")
			g.b_main_client_cpp.writeln("\t\t}")
			g.b_main_client_cpp.writeln("\t\treturn res;")
			g.b_main_client_cpp.writeln("\t}")
		})
		g.each_all_child(g.obj_type, fn[impl_type_name, impl_obj_type_name](mut g Gen, idx ast.Type, sym &ast.TypeSymbol){
			cur_bind_class_name := g.gen_bind_class_name(sym.name)
			g.b_main_client_cpp.writeln("\tif(${cur_bind_class_name}::IsInstance(value))")
			g.b_main_client_cpp.writeln("\t{")
			g.b_main_client_cpp.writeln("\t\tNapi::Object obj = value.As<Napi::Object>();")
			g.b_main_client_cpp.writeln("\t\t${cur_bind_class_name}* wrapper = Napi::ObjectWrap<${cur_bind_class_name}>::Unwrap(obj);")
			g.b_main_client_cpp.writeln("\t\t${impl_type_name} res = wrapper->self->As<${impl_obj_type_name}>();")
			g.b_main_client_cpp.writeln("\t\tif (!res)")
			g.b_main_client_cpp.writeln("\t\t{")
			g.b_main_client_cpp.writeln("\t\t\tstd::string errMsg = \"Failed to cast to `${impl_obj_type_name}`\";")
			g.b_main_client_cpp.writeln("\t\t\tERR(errMsg);")
			g.b_main_client_cpp.writeln("\t\t\tthrow Napi::Error::New(value.Env(), errMsg);")
			g.b_main_client_cpp.writeln("\t\t}")
			g.b_main_client_cpp.writeln("\t\treturn res;")
			g.b_main_client_cpp.writeln("\t}")
		})

		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\treturn nullptr;")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		g.b_main_client_cpp.writeln("bool ${bind_class_name}::IsInstance(const Napi::Value& value)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tif (!value.IsObject())")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\treturn false;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\tNapi::Object obj = value.As<Napi::Object>();")
		g.b_main_client_cpp.writeln("\treturn obj.InstanceOf(${g.gen_ctor_name(g.obj_name)}.Value());")
		g.b_main_client_cpp.writeln("}")

		g.b_main_client_cpp.writeln("")

		g.b_main_client_cpp.writeln("${impl_type_name} ${bind_class_name}::ToImplValue(const Napi::Value& value)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tif (IsInstance(value))")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tNapi::Object obj = value.As<Napi::Object>();")
		g.b_main_client_cpp.writeln("\t\t${bind_class_name}* wrapper = Napi::ObjectWrap<${bind_class_name}>::Unwrap(obj);")
		g.b_main_client_cpp.writeln("\t\treturn wrapper->self;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\t${impl_type_name} res = Cast(value);")
		g.b_main_client_cpp.writeln("\tif(!res)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tERR(\"invalid cast in (${bind_class_name}::ToImplValue)\");")
		g.b_main_client_cpp.writeln("\t\tthrow Napi::Error::New(value.Env(), std::string(\"invalid cast in (${bind_class_name}::ToImplValue)\"));")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("")
		g.b_main_client_cpp.writeln("\treturn res;")
		g.b_main_client_cpp.writeln("}")
		
		g.b_main_client_cpp.writeln("")

		g.b_main_client_cpp.writeln("Napi::Value ${bind_class_name}::ToNapiValue(Napi::Env env, ${impl_type_name} self)")
		g.b_main_client_cpp.writeln("{")
		g.b_main_client_cpp.writeln("\tif (!self)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\tERR(\"invalid object in cast (${bind_class_name}::ToNapiValue)\")")
		g.b_main_client_cpp.writeln("\t\treturn env.Null();")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\t// Создаем новый экземпляр ${bind_class_name}")
		g.b_main_client_cpp.writeln("\tNapi::EscapableHandleScope scope(env);")
		g.b_main_client_cpp.writeln("\tNapi::Function ctor = ${g.gen_ctor_name(g.obj_name)}.Value();")
		g.b_main_client_cpp.writeln("\tNapi::Object instance = ctor.New({});")
		g.b_main_client_cpp.writeln("\t${bind_class_name}* wrapper = Napi::ObjectWrap<${bind_class_name}>::Unwrap(instance);")
		g.b_main_client_cpp.writeln("\tif (wrapper)")
		g.b_main_client_cpp.writeln("\t{")
		g.b_main_client_cpp.writeln("\t\twrapper->self = self;")
		g.b_main_client_cpp.writeln("\t}")
		g.b_main_client_cpp.writeln("\treturn scope.Escape(instance);")
		g.b_main_client_cpp.writeln("}")
	}
}


const h_start_file =
"// !!! Generated automatically. Do not edit. !!!

#pragma once

#include <napi.h>
#include \"../NapiHelper.h\"

namespace JSBinding
{"

const h_end_file = 
"void RegisterAllVMObjects(Napi::Env env, Napi::Object exports);
void HandleSpSnippet(RpcPacket packet);
}; // end namespace JSBinding"

const cpp_start_file =  "// !!! Generated automatically. Do not edit. !!!

#include \"__js_bindings.h\"
#include \"../ThreadCommunicator.h\"

#ifdef GetForm
#undef GetForm
#endif

namespace JSBinding {
"

const ts_start_file = 
"// !!! Generated automatically. Do not edit. !!!

declare global {
"

const ts_end_file = "}

export {};"