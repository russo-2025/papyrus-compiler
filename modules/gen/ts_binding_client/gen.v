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

// func reg all object wrappers
	main_register_func		strings.Builder
// ts header file
	ts_headers				strings.Builder
// h file
	class_bind_cpp			strings.Builder
// cpp file
	class_bind_h			strings.Builder
// Init Fn - methods list
	init_methods_bind_cpp	strings.Builder

// temp
	obj_type				ast.Type
	sym						&ast.TypeSymbol = unsafe { voidptr(0) }
	psym					&ast.TypeSymbol = unsafe { voidptr(0) }
	obj_name				string
	parent_obj_name			string
	file_by_name			map[string]&ast.File
	fns						[]ast.FnDecl
	pfns					[]ast.FnDecl
	temp_args				strings.Builder
	form_idx				ast.Type

	no_instance_class		[]ast.Type
}

struct JsonCompileSettings {
	impl_classes		map[string]string
	no_instance_class	[]string
}

const settings_file_name = "clientCompileSettings.json"

pub fn gen(mut files []&ast.File, mut table ast.Table, output_dir string) {
	println("generate client bindings")

	mut g := Gen{
		temp_args: strings.new_builder(200)
		main_register_func: strings.new_builder(300)
		ts_headers: strings.new_builder(1000)
		class_bind_cpp: strings.new_builder(1000)
		class_bind_h: strings.new_builder(1000)
		init_methods_bind_cpp: strings.new_builder(300)
		table: table
		file_by_name: map[string]&ast.File{}
		impl_classes: map[string]string{}
		form_idx: table.find_type_idx("form")
		parents_of_objects: map[ast.Type]map[ast.Type]u8{}
		no_instance_class: []ast.Type{ cap: 7 }
	}

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
	

	// ============== generate h js bind =======================

	g.class_bind_h.writeln("// !!! Generated automatically. Do not edit. !!!")
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("#pragma once")
	g.class_bind_h.writeln("")

	g.class_bind_h.writeln("#include <napi.h>")
	g.class_bind_h.writeln("#include \"../NapiHelper.h\"")
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("namespace JSBinding")
	g.class_bind_h.writeln("{")
	g.class_bind_h.writeln("")

	// ============== generate cpp js bind =======================

	g.class_bind_cpp.writeln("// !!! Generated automatically. Do not edit. !!!")
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("#include \"__js_bindings.h\"")
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("#ifdef GetForm")
	g.class_bind_cpp.writeln("#undef GetForm")
	g.class_bind_cpp.writeln("#endif")
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("namespace JSBinding {")

	g.class_bind_cpp.writeln("")

	// ============== generate ts headers =====================

	g.ts_headers.writeln("// !!! Generated automatically. Do not edit. !!!")
	g.ts_headers.writeln("")
	g.ts_headers.writeln("declare global {")
	g.ts_headers.writeln("")

	// ===========================================================
	
	for file in files {
		g.class_bind_cpp.writeln("static Napi::FunctionReference ${g.gen_ctor_name(file.obj_name)};")
	}

	g.each_files_fns(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File, func &ast.FnDecl){
		if func.return_type != ast.none_type {
			g.class_bind_h.write_string(g.get_impl_type_name(func.return_type))
			g.class_bind_h.write_string(" ")
		}
		else {
			g.class_bind_h.write_string("void ")
		}

		g.class_bind_h.write_string(g.get_real_impl_fn_name(sym.name, func.name))

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
		g.class_bind_h.write_string("(")
		g.class_bind_h.write_string(args_list)
		g.class_bind_h.writeln(");")
	})

	g.class_bind_h.writeln("")

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

	// ============== generate h js bind =======================
	
	g.class_bind_h.writeln("void RegisterAllVMObjects(Napi::Env env, Napi::Object exports);")
	g.class_bind_h.writeln("}; // end namespace JSBinding")

	// ============== generate cpp js bind =======================
	
	g.class_bind_cpp.writeln("void RegisterAllVMObjects(Napi::Env env, Napi::Object exports)")
	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln(g.main_register_func.str())
	g.class_bind_cpp.writeln("}")

	g.class_bind_cpp.writeln("}; // end namespace JSBinding")

	// ============== generate ts headers =====================
	
	g.ts_headers.writeln("}")
	g.ts_headers.writeln("")
	g.ts_headers.writeln("export {};")

	// ===========================================================

	os.write_file(os.join_path(output_dir, "__js_bindings.h"), g.class_bind_h.str()) or { panic("write_file err") }
	os.write_file(os.join_path(output_dir, "__js_bindings.cpp"), g.class_bind_cpp.str()) or { panic("write_file err") }
	os.write_file(os.join_path(output_dir, "papyrusObjects.d.ts"), g.ts_headers.str()) or { panic("write_file err") }
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

	g.class_bind_cpp.writeln("Napi::Object ${bind_class_name}::Init(Napi::Env env, Napi::Object exports)")
	g.class_bind_cpp.writeln("{")
	
	/*
	g.each_all_this_fns(g.sym, fn(mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl){
		is_static_str := if func.is_global { "true" } else { "false" }
		g.class_bind_cpp.writeln("\t${g.get_fn_impl_name(sum.obj_name, func.name)} = VirtualMachine::GetInstance()->GetFunctionImplementation(\"${sum.obj_name}\", \"${func.name}\", ${is_static_str});")
		g.class_bind_cpp.writeln("\tif(!${g.get_fn_impl_name(sum.obj_name, func.name)}){")
		g.class_bind_cpp.writeln("\t\tERR(\"failed to find function in Papyrus VM: `${sum.obj_name}.${func.name}`\");")
		g.class_bind_cpp.writeln("\t\tthrow std::runtime_error(\"failed to find function in Papyrus VM: `${sum.obj_name}.${func.name}`\");")
		g.class_bind_cpp.writeln("\t}")
		g.class_bind_cpp.writeln("")
	})*/

	g.class_bind_cpp.writeln("\tNapi::HandleScope scope(env);")
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("\tNapi::Function func = DefineClass(env, \"${g.obj_name}\", {")
	if !g.is_no_instance_class(g.obj_type) {
		g.class_bind_cpp.writeln("\t\tStaticMethod(\"From\", &${bind_class_name}::From),")
		g.class_bind_cpp.write_string("\t\tInstanceMethod(\"As\", &${bind_class_name}::As)")
		if g.init_methods_bind_cpp.len != 0 {
			g.class_bind_cpp.writeln(",")
		}
		else {
			g.class_bind_cpp.writeln("")
		}
	}
	g.class_bind_cpp.writeln("${g.init_methods_bind_cpp.str()}")
	g.class_bind_cpp.writeln("\t});")
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("\t${g.gen_ctor_name(g.obj_name)} = Napi::Persistent(func);")
	g.class_bind_cpp.writeln("\t${g.gen_ctor_name(g.obj_name)}.SuppressDestruct();")
	g.class_bind_cpp.writeln("\texports.Set(\"${g.obj_name}\", func);")
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("\treturn exports;")
	g.class_bind_cpp.writeln("}")

	g.class_bind_cpp.writeln("")
	
	g.class_bind_cpp.write_string("${bind_class_name}::${bind_class_name}(const Napi::CallbackInfo& info) : ObjectWrap(info)")

	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("}")

	g.class_bind_cpp.writeln("")
	
	if !g.is_no_instance_class(g.obj_type) {
		g.class_bind_cpp.writeln("Napi::Value ${bind_class_name}::From(const Napi::CallbackInfo& info)")
		g.class_bind_cpp.writeln("{")
		g.class_bind_cpp.writeln("\ttry")
		g.class_bind_cpp.writeln("\t{")
		g.class_bind_cpp.writeln("\t\tuint32_t formId = NapiHelper::ExtractUInt32(info[0], \"formId\");")
		g.class_bind_cpp.writeln("\t\t${impl_type_name} obj = RE::TESForm::LookupByID<${impl_obj_type_name}>(formId);")
		g.class_bind_cpp.writeln("")
		g.class_bind_cpp.writeln("\t\tif(!obj) {")
		g.class_bind_cpp.writeln("\t\t\treturn info.Env().Null();")
		g.class_bind_cpp.writeln("\t\t}")
		g.class_bind_cpp.writeln("")
		g.class_bind_cpp.writeln("\t\treturn ${g.gen_convert_to_napivalue(g.obj_type, "obj")};")
		g.class_bind_cpp.writeln("\t}")
		g.class_bind_cpp.writeln("\tcatch(std::exception& e) {")
		g.class_bind_cpp.writeln("\t\tERR((std::string)e.what());")
		g.class_bind_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
		g.class_bind_cpp.writeln("\t}")
		g.class_bind_cpp.writeln("\treturn info.Env().Null();")
		g.class_bind_cpp.writeln("}")

		g.class_bind_cpp.writeln("")

		g.class_bind_cpp.writeln("Napi::Value ${bind_class_name}::As(const Napi::CallbackInfo& info)")
		g.class_bind_cpp.writeln("{")
		g.class_bind_cpp.writeln("\ttry")
		g.class_bind_cpp.writeln("\t{")
		g.class_bind_cpp.writeln("\t\tif(!${bind_class_name}::IsInstance(this->Value()))")
		g.class_bind_cpp.writeln("\t\t{")
		g.class_bind_cpp.writeln("\t\t\treturn info.Env().Null();")
		g.class_bind_cpp.writeln("\t\t}")
		g.class_bind_cpp.writeln("\t\tNapi::Value class_ctor = info[0];")
		g.each_all_parent(g.sym, fn(mut g Gen, file &ast.File, idx ast.Type, sym &ast.TypeSymbol) {
			cur_bind_class_name := g.gen_bind_class_name(sym.name)
			g.class_bind_cpp.writeln("\t\tif(class_ctor == ${g.gen_ctor_name(sym.name)}.Value())")
			g.class_bind_cpp.writeln("\t\t{")
			g.class_bind_cpp.writeln("\t\t\treturn ${cur_bind_class_name}::ToNapiValue(info.Env(), this->self->As<${g.get_impl_obj_type_name(idx)}>());")
			g.class_bind_cpp.writeln("\t\t}")
		})
		g.each_all_child(g.obj_type, fn(mut g Gen, idx ast.Type, sym &ast.TypeSymbol){
			cur_bind_class_name := g.gen_bind_class_name(sym.name)
			g.class_bind_cpp.writeln("\t\tif(class_ctor == ${g.gen_ctor_name(sym.name)}.Value())")
			g.class_bind_cpp.writeln("\t\t{")
			g.class_bind_cpp.writeln("\t\t\treturn ${cur_bind_class_name}::ToNapiValue(info.Env(), this->self->As<${g.get_impl_obj_type_name(idx)}>());")
			g.class_bind_cpp.writeln("\t\t}")
		})
		g.class_bind_cpp.writeln("\t}")
		g.class_bind_cpp.writeln("\tcatch(std::exception& e)")
		g.class_bind_cpp.writeln("\t{")
		g.class_bind_cpp.writeln("\t\tERR((std::string)e.what());")
		g.class_bind_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
		g.class_bind_cpp.writeln("\t}")
		g.class_bind_cpp.writeln("\treturn info.Env().Null();")
		g.class_bind_cpp.writeln("}")

		g.class_bind_cpp.writeln("")

		g.class_bind_cpp.writeln("${impl_type_name} ${bind_class_name}::Cast(const Napi::Value& value)")
		g.class_bind_cpp.writeln("{")
		g.each_all_parent(g.sym, fn[impl_type_name, impl_obj_type_name](mut g Gen, file &ast.File, idx ast.Type, sym &ast.TypeSymbol) {
			cur_bind_class_name := g.gen_bind_class_name(sym.name)
			g.class_bind_cpp.writeln("\tif(${cur_bind_class_name}::IsInstance(value))")
			g.class_bind_cpp.writeln("\t{")
			g.class_bind_cpp.writeln("\t\tNapi::Object obj = value.As<Napi::Object>();")
			g.class_bind_cpp.writeln("\t\t${cur_bind_class_name}* wrapper = Napi::ObjectWrap<${cur_bind_class_name}>::Unwrap(obj);")
			g.class_bind_cpp.writeln("\t\t${impl_type_name} res = wrapper->self->As<${impl_obj_type_name}>();")
			g.class_bind_cpp.writeln("\t\tif (!res)")
			g.class_bind_cpp.writeln("\t\t{")
			g.class_bind_cpp.writeln("\t\t\tstd::string errMsg = \"Failed to cast to `${impl_obj_type_name}`\";")
			g.class_bind_cpp.writeln("\t\t\tERR(errMsg);")
			g.class_bind_cpp.writeln("\t\t\tthrow Napi::Error::New(value.Env(), errMsg);")
			g.class_bind_cpp.writeln("\t\t}")
			g.class_bind_cpp.writeln("\t\treturn res;")
			g.class_bind_cpp.writeln("\t}")
		})
		g.each_all_child(g.obj_type, fn[impl_type_name, impl_obj_type_name](mut g Gen, idx ast.Type, sym &ast.TypeSymbol){
			cur_bind_class_name := g.gen_bind_class_name(sym.name)
			g.class_bind_cpp.writeln("\tif(${cur_bind_class_name}::IsInstance(value))")
			g.class_bind_cpp.writeln("\t{")
			g.class_bind_cpp.writeln("\t\tNapi::Object obj = value.As<Napi::Object>();")
			g.class_bind_cpp.writeln("\t\t${cur_bind_class_name}* wrapper = Napi::ObjectWrap<${cur_bind_class_name}>::Unwrap(obj);")
			g.class_bind_cpp.writeln("\t\t${impl_type_name} res = wrapper->self->As<${impl_obj_type_name}>();")
			g.class_bind_cpp.writeln("\t\tif (!res)")
			g.class_bind_cpp.writeln("\t\t{")
			g.class_bind_cpp.writeln("\t\t\tstd::string errMsg = \"Failed to cast to `${impl_obj_type_name}`\";")
			g.class_bind_cpp.writeln("\t\t\tERR(errMsg);")
			g.class_bind_cpp.writeln("\t\t\tthrow Napi::Error::New(value.Env(), errMsg);")
			g.class_bind_cpp.writeln("\t\t}")
			g.class_bind_cpp.writeln("\t\treturn res;")
			g.class_bind_cpp.writeln("\t}")
		})

		g.class_bind_cpp.writeln("")
		g.class_bind_cpp.writeln("\treturn nullptr;")
		g.class_bind_cpp.writeln("}")

		g.class_bind_cpp.writeln("")

		g.class_bind_cpp.writeln("bool ${bind_class_name}::IsInstance(const Napi::Value& value)")
		g.class_bind_cpp.writeln("{")
		g.class_bind_cpp.writeln("\tif (!value.IsObject())")
		g.class_bind_cpp.writeln("\t{")
		g.class_bind_cpp.writeln("\t\treturn false;")
		g.class_bind_cpp.writeln("\t}")
		g.class_bind_cpp.writeln("\tNapi::Object obj = value.As<Napi::Object>();")
		g.class_bind_cpp.writeln("\treturn obj.InstanceOf(${g.gen_ctor_name(g.obj_name)}.Value());")
		g.class_bind_cpp.writeln("}")

		g.class_bind_cpp.writeln("")

		g.class_bind_cpp.writeln("${impl_type_name} ${bind_class_name}::ToImplValue(const Napi::Value& value)")
		g.class_bind_cpp.writeln("{")
		g.class_bind_cpp.writeln("\tif (IsInstance(value))")
		g.class_bind_cpp.writeln("\t{")
		g.class_bind_cpp.writeln("\t\tNapi::Object obj = value.As<Napi::Object>();")
		g.class_bind_cpp.writeln("\t\t${bind_class_name}* wrapper = Napi::ObjectWrap<${bind_class_name}>::Unwrap(obj);")
		g.class_bind_cpp.writeln("\t\treturn wrapper->self;")
		g.class_bind_cpp.writeln("\t}")
		g.class_bind_cpp.writeln("")
		g.class_bind_cpp.writeln("\t${impl_type_name} res = Cast(value);")
		g.class_bind_cpp.writeln("\tif(!res)")
		g.class_bind_cpp.writeln("\t{")
		g.class_bind_cpp.writeln("\t\tERR(\"invalid cast in (${bind_class_name}::ToImplValue)\");")
		g.class_bind_cpp.writeln("\t\tthrow Napi::Error::New(value.Env(), std::string(\"invalid cast in (${bind_class_name}::ToImplValue)\"));")
		g.class_bind_cpp.writeln("\t}")
		g.class_bind_cpp.writeln("")
		g.class_bind_cpp.writeln("\treturn res;")
		g.class_bind_cpp.writeln("}")
		
		g.class_bind_cpp.writeln("")

		g.class_bind_cpp.writeln("Napi::Value ${bind_class_name}::ToNapiValue(Napi::Env env, ${impl_type_name} self)")
		g.class_bind_cpp.writeln("{")
		g.class_bind_cpp.writeln("\tif (!self)")
		g.class_bind_cpp.writeln("\t{")
		g.class_bind_cpp.writeln("\t\tERR(\"invalid object in cast (${bind_class_name}::ToNapiValue)\")")
		g.class_bind_cpp.writeln("\t\treturn env.Null();")
		g.class_bind_cpp.writeln("\t}")
		g.class_bind_cpp.writeln("\t// Создаем новый экземпляр ${bind_class_name}")
		g.class_bind_cpp.writeln("\tNapi::EscapableHandleScope scope(env);")
		g.class_bind_cpp.writeln("\tNapi::Function ctor = ${g.gen_ctor_name(g.obj_name)}.Value();")
		g.class_bind_cpp.writeln("\tNapi::Object instance = ctor.New({});")
		g.class_bind_cpp.writeln("\t${bind_class_name}* wrapper = Napi::ObjectWrap<${bind_class_name}>::Unwrap(instance);")
		g.class_bind_cpp.writeln("\tif (wrapper)")
		g.class_bind_cpp.writeln("\t{")
		g.class_bind_cpp.writeln("\t\twrapper->self = self;")
		g.class_bind_cpp.writeln("\t}")
		g.class_bind_cpp.writeln("\treturn scope.Escape(instance);")
		g.class_bind_cpp.writeln("}")
	}
}