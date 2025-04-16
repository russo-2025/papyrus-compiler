module ts_binding_client

import papyrus.ast
import pref
import strings
import os

@[heap]
struct Gen {
mut:
	table					ast.Table

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
}

pub fn gen(mut files []&ast.File, mut table ast.Table, prefs &pref.Preferences) {
	mut g := Gen{
		temp_args: strings.new_builder(200)
		main_register_func: strings.new_builder(300)
		ts_headers: strings.new_builder(1000)
		class_bind_cpp: strings.new_builder(1000)
		class_bind_h: strings.new_builder(1000)
		init_methods_bind_cpp: strings.new_builder(300)
		table: table
		file_by_name: map[string]&ast.File{}
	}

	for file in files {
		g.file_by_name[file.obj_name.to_lower()] = file
	}

	// ============== generate h js bind =======================

	g.class_bind_h.writeln("#pragma once")
	g.class_bind_h.writeln("")

	g.class_bind_h.writeln("#include <napi.h>")
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("namespace JSBinding")
	g.class_bind_h.writeln("{")
	g.class_bind_h.writeln("")

	// ============== generate cpp js bind =======================

	g.class_bind_cpp.writeln("#include \"__jsbind.h\"")
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("namespace JSBinding {")

	// ============== generate ts headers =====================

	g.ts_headers.writeln("declare global {")
	g.ts_headers.writeln("")

	// ===========================================================

	g.class_bind_cpp.writeln("")
	

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

	os.write_file(os.join_path(prefs.output_dir, "__jsbind.h"), g.class_bind_h.str()) or { panic("write_file err") }
	os.write_file(os.join_path(prefs.output_dir, "__jsbind.cpp"), g.class_bind_cpp.str()) or { panic("write_file err") }
	os.write_file(os.join_path(prefs.output_dir, "jsbind.d.ts"), g.ts_headers.str()) or { panic("write_file err") }
}

fn (mut g Gen) gen_end_impl() {
	impl_type_name := g.get_impl_type_name(g.obj_type)

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

	g.class_bind_cpp.writeln("Napi::Object ${g.gen_bind_class_name(g.obj_name)}::Init(Napi::Env env, Napi::Object exports)")
	g.class_bind_cpp.writeln("{")
	
	g.each_all_this_fns(g.sym, fn(mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl){
		is_static_str := if func.is_global { "true" } else { "false" }
		g.class_bind_cpp.writeln("\t${g.get_fn_impl_name(sum.obj_name, func.name)} = VirtualMachine::GetInstance()->GetFunctionImplementation(\"${sum.obj_name}\", \"${func.name}\", ${is_static_str});")
		g.class_bind_cpp.writeln("\tif(!${g.get_fn_impl_name(sum.obj_name, func.name)}){")
		g.class_bind_cpp.writeln("\t\tspdlog::error(\"failed to find function in Papyrus VM: `${sum.obj_name}.${func.name}`\");")
		g.class_bind_cpp.writeln("\t\tthrow std::runtime_error(\"failed to find function in Papyrus VM: `${sum.obj_name}.${func.name}`\");")
		g.class_bind_cpp.writeln("\t}")
		g.class_bind_cpp.writeln("")
	})

	g.class_bind_cpp.writeln("\tNapi::HandleScope scope(env);")
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("\tNapi::Function func = DefineClass(env, \"${g.obj_name}\", {")
	g.class_bind_cpp.writeln("\t\tStaticMethod(\"From\", &${g.gen_bind_class_name(g.obj_name)}::From),")
	g.class_bind_cpp.writeln("${g.init_methods_bind_cpp.str()}")
	g.class_bind_cpp.writeln("\t});")
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("\t${g.gen_ctor_name(g.obj_name)} = Napi::Persistent(func);")
	g.class_bind_cpp.writeln("\t${g.gen_ctor_name(g.obj_name)}.SuppressDestruct();")
	g.class_bind_cpp.writeln("\texports.Set(\"${g.obj_name}\", func);")
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("\treturn exports;")
	g.class_bind_cpp.writeln("};")

	g.class_bind_cpp.writeln("")
	
	g.class_bind_cpp.write_string("${g.gen_bind_class_name(g.obj_name)}::${g.gen_bind_class_name(g.obj_name)}(const Napi::CallbackInfo& info) : ObjectWrap(info)")

	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("\tself = ${impl_type_name}::None();")
	g.class_bind_cpp.writeln("};")

	g.class_bind_cpp.writeln("")

	g.class_bind_cpp.writeln("Napi::Value ${g.gen_bind_class_name(g.obj_name)}::From(const Napi::CallbackInfo& info)")
	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("\ttry")
	g.class_bind_cpp.writeln("\t{")
	g.class_bind_cpp.writeln("\t\tauto formId = NapiHelper::ExtractUInt32(info[0], \"formId\");")
	g.class_bind_cpp.writeln("\t\tauto& form = g_partOne->worldState.GetFormAt<MpForm>(formId);")
	g.class_bind_cpp.writeln("\t\t// if(!form) {")
	g.class_bind_cpp.writeln("\t\t//\t throw std::runtime_error(\"form not found `${g.gen_bind_class_name(g.obj_name)}::From`\");")
	g.class_bind_cpp.writeln("\t\t// }")
	g.class_bind_cpp.writeln("")
	
	g.class_bind_cpp.writeln("\t\treturn ${g.gen_convert_to_napivalue(g.obj_type, "VarValue(form.ToGameObject())")};")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\tcatch(std::exception& e) {")
	g.class_bind_cpp.writeln("\t\tspdlog::error((std::string)e.what());")
	g.class_bind_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\treturn info.Env().Undefined();")
	g.class_bind_cpp.writeln("};")

	g.class_bind_cpp.writeln("")

	g.class_bind_cpp.writeln("bool ${g.gen_bind_class_name(g.obj_name)}::IsInstance(const Napi::Value& value)")
	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("\tif (!value.IsObject())")
	g.class_bind_cpp.writeln("\t{")
	g.class_bind_cpp.writeln("\t\treturn false;")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\tNapi::Object obj = value.As<Napi::Object>();")
	g.class_bind_cpp.writeln("\treturn obj.InstanceOf(${g.gen_ctor_name(g.obj_name)}.Value());")
	g.class_bind_cpp.writeln("};")

	g.class_bind_cpp.writeln("")

	g.class_bind_cpp.writeln("${impl_type_name} ${g.gen_bind_class_name(g.obj_name)}::ToImplValue(const Napi::Value& value)")
	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("\tif (!IsInstance(value))")
	g.class_bind_cpp.writeln("\t{")
	g.class_bind_cpp.writeln("\t\treturn VarValue::None();")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\tNapi::Object obj = value.As<Napi::Object>();")
	g.class_bind_cpp.writeln("\t${g.gen_bind_class_name(g.obj_name)}* wrapper = Napi::ObjectWrap<${g.gen_bind_class_name(g.obj_name)}>::Unwrap(obj);")
	g.class_bind_cpp.writeln("\treturn wrapper->self;")
	g.class_bind_cpp.writeln("};")
	
	g.class_bind_cpp.writeln("")

	g.class_bind_cpp.writeln("Napi::Value ${g.gen_bind_class_name(g.obj_name)}::ToNapiValue(Napi::Env env, const ${impl_type_name}& self)")
	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("\tif (self.GetType() != VarValue::Type::kType_Object || !self)")
	g.class_bind_cpp.writeln("\t{")
	g.class_bind_cpp.writeln("\t\t//todo error invalid self")
	g.class_bind_cpp.writeln("\t\treturn env.Null();")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\t// Создаем новый экземпляр ${g.gen_bind_class_name(g.obj_name)}")
	g.class_bind_cpp.writeln("\tNapi::EscapableHandleScope scope(env);")
	g.class_bind_cpp.writeln("\tNapi::Function ctor = ${g.gen_ctor_name(g.obj_name)}.Value();")
	g.class_bind_cpp.writeln("\tNapi::Object instance = ctor.New({});")
	g.class_bind_cpp.writeln("\t${g.gen_bind_class_name(g.obj_name)}* wrapper = Napi::ObjectWrap<${g.gen_bind_class_name(g.obj_name)}>::Unwrap(instance);")
	g.class_bind_cpp.writeln("\tif (wrapper)")
	g.class_bind_cpp.writeln("\t{")
	g.class_bind_cpp.writeln("\t\twrapper->self = self;")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\treturn scope.Escape(instance);")
	g.class_bind_cpp.writeln("}")
}