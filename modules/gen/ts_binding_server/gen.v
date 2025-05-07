module ts_binding_server

import papyrus.ast
import strings
import os

@[heap]
struct Gen {
mut:
	table					ast.Table

// ts header file
	server_ts_h				strings.Builder
// h file
	server_main_cpp			strings.Builder
// cpp file
	server_main_h			strings.Builder

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

pub fn gen(mut files []&ast.File, mut table ast.Table, output_dir string) {
	println("generate server bindings")

	mut g := Gen{
		temp_args: strings.new_builder(200)
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

	// ============== generate h js bind =======================

	// ============== generate cpp js bind =======================

	g.server_main_cpp.writeln("// !!! Generated automatically. Do not edit. !!!")
	g.server_main_cpp.writeln("#include \"__js_bindings.h\"")
	g.server_main_cpp.writeln("#include \"PartOne.h\"")
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("#ifdef GetForm")
	g.server_main_cpp.writeln("#undef GetForm")
	g.server_main_cpp.writeln("#endif")
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("extern std::shared_ptr<PartOne> g_partOne;")
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("namespace JSBinding {")
	
	g.server_main_cpp.writeln("")

	// ============== generate ts headers =====================

	g.server_ts_h.writeln("// !!! Generated automatically. Do not edit. !!!")
	g.server_ts_h.writeln("")
	g.server_ts_h.writeln("declare global {")
	g.server_ts_h.writeln("")

	// ===========================================================
	for file in files {
		g.server_main_cpp.writeln("static inline Napi::FunctionReference ${g.gen_ctor_name(file.obj_name)};")
		
		for top_stmt in file.stmts {
			match top_stmt {
				ast.Comment {}
				ast.ScriptDecl {}
				ast.FnDecl {
					func := top_stmt
					g.server_main_cpp.writeln("static NativeFunction ${g.gen_vm_fn_impl_name(file.obj_name, func.name)} = nullptr;")
				}
				else { panic("invalid top stmt ${top_stmt}") }
			}	
		}
	}

	g.server_main_cpp.writeln("")
	

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

	// ============== generate cpp js bind =======================
	
	g.server_main_cpp.writeln("void RegisterAllVMObjects(Napi::Env env, Napi::Object exports)")
	g.server_main_cpp.writeln("{")
	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		bind_class_name := g.gen_bind_class_name(sym.name)
		g.server_main_cpp.writeln("\t${bind_class_name}::Init(env, exports);")
	})
	g.server_main_cpp.writeln("}")

	g.server_main_cpp.writeln("}; // end namespace JSBinding")

	// ============== generate ts headers =====================
	
	g.server_ts_h.writeln("}")
	g.server_ts_h.writeln("")
	g.server_ts_h.writeln("export {};")

	// ===========================================================

	os.write_file(os.join_path(output_dir, "__js_bindings.h"), g.server_main_h.str()) or { panic("write_file err") }
	os.write_file(os.join_path(output_dir, "__js_bindings.cpp"), g.server_main_cpp.str()) or { panic("write_file err") }
	os.write_file(os.join_path(output_dir, "papyrusObjects.d.ts"), g.server_ts_h.str()) or { panic("write_file err") }
}

fn (mut g Gen) gen_end_impl() {
	mut init_methods_bind_cpp := strings.new_builder(300)
	mut init_methods_bind_cpp_ptr := &init_methods_bind_cpp

	g.each_all_fns(g.sym, fn[mut init_methods_bind_cpp_ptr](mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl){
		js_class_name := g.gen_bind_class_name(g.sym.obj_name)
		js_fn_name := g.gen_js_fn_name(func.name)
		fn_name := func.name

		if func.is_global {
			init_methods_bind_cpp_ptr.write_string("\t\tStaticMethod(\"${fn_name}\", &${js_class_name}::${js_fn_name})")
		}
		else {
			init_methods_bind_cpp_ptr.write_string("\t\tInstanceMethod(\"${fn_name}\", &${js_class_name}::${js_fn_name})")
		}
		
		init_methods_bind_cpp_ptr.write_string(",\n")
	})
	
	if init_methods_bind_cpp_ptr.len > 0 {
		init_methods_bind_cpp_ptr.go_back(",\n".len) // remove last `,` + `\n`
	}

	g.server_main_cpp.writeln("Napi::Object ${g.gen_bind_class_name(g.obj_name)}::Init(Napi::Env env, Napi::Object exports)")
	g.server_main_cpp.writeln("{")
	
	g.each_all_this_fns(g.sym, fn(mut g Gen, sum &ast.TypeSymbol, func &ast.FnDecl){
		is_static_str := if func.is_global { "true" } else { "false" }
		g.server_main_cpp.writeln("\t${g.gen_vm_fn_impl_name(sum.obj_name, func.name)} = VirtualMachine::GetInstance()->GetFunctionImplementation(\"${sum.obj_name}\", \"${func.name}\", ${is_static_str});")
		g.server_main_cpp.writeln("\tif(!${g.gen_vm_fn_impl_name(sum.obj_name, func.name)}){")
		g.server_main_cpp.writeln("\t\tspdlog::error(\"failed to find function in Papyrus VM: `${sum.obj_name}.${func.name}`\");")
		g.server_main_cpp.writeln("\t\tthrow std::runtime_error(\"failed to find function in Papyrus VM: `${sum.obj_name}.${func.name}`\");")
		g.server_main_cpp.writeln("\t}")
		g.server_main_cpp.writeln("")
	})

	g.server_main_cpp.writeln("\tNapi::HandleScope scope(env);")
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\tNapi::Function func = DefineClass(env, \"${g.obj_name}\", {")
	g.server_main_cpp.writeln("\t\tStaticMethod(\"From\", &${g.gen_bind_class_name(g.obj_name)}::From),")
	g.server_main_cpp.writeln("${init_methods_bind_cpp_ptr.str()}")
	g.server_main_cpp.writeln("\t});")
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\t${g.gen_ctor_name(g.obj_name)} = Napi::Persistent(func);")
	g.server_main_cpp.writeln("\t${g.gen_ctor_name(g.obj_name)}.SuppressDestruct();")
	g.server_main_cpp.writeln("\texports.Set(\"${g.obj_name}\", func);")
	g.server_main_cpp.writeln("")
	g.server_main_cpp.writeln("\treturn exports;")
	g.server_main_cpp.writeln("};")

	g.server_main_cpp.writeln("")
	
	g.server_main_cpp.write_string("${g.gen_bind_class_name(g.obj_name)}::${g.gen_bind_class_name(g.obj_name)}(const Napi::CallbackInfo& info) : ObjectWrap(info)")

	g.server_main_cpp.writeln("{")
	g.server_main_cpp.writeln("\tself = VarValue::None();")
	g.server_main_cpp.writeln("};")

	g.server_main_cpp.writeln("")

	g.server_main_cpp.writeln("Napi::Value ${g.gen_bind_class_name(g.obj_name)}::From(const Napi::CallbackInfo& info)")
	g.server_main_cpp.writeln("{")
	g.server_main_cpp.writeln("\ttry")
	g.server_main_cpp.writeln("\t{")
	g.server_main_cpp.writeln("\t\tauto formId = NapiHelper::ExtractUInt32(info[0], \"formId\");")
	g.server_main_cpp.writeln("\t\tauto& form = g_partOne->worldState.GetFormAt<MpForm>(formId);")
	g.server_main_cpp.writeln("\t\t// if(!form) {")
	g.server_main_cpp.writeln("\t\t//\t throw std::runtime_error(\"form not found `${g.gen_bind_class_name(g.obj_name)}::From`\");")
	g.server_main_cpp.writeln("\t\t// }")
	g.server_main_cpp.writeln("")
	
	g.server_main_cpp.writeln("\t\treturn ${g.gen_convert_to_napivalue(g.obj_type, "VarValue(form.ToGameObject())")};")
	g.server_main_cpp.writeln("\t}")
	g.server_main_cpp.writeln("\tcatch(std::exception& e) {")
	g.server_main_cpp.writeln("\t\tspdlog::error((std::string)e.what());")
	g.server_main_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
	g.server_main_cpp.writeln("\t}")
	g.server_main_cpp.writeln("\treturn info.Env().Undefined();")
	g.server_main_cpp.writeln("};")

	g.server_main_cpp.writeln("")

	g.server_main_cpp.writeln("bool ${g.gen_bind_class_name(g.obj_name)}::IsInstance(const Napi::Value& value)")
	g.server_main_cpp.writeln("{")
	g.server_main_cpp.writeln("\tif (!value.IsObject())")
	g.server_main_cpp.writeln("\t{")
	g.server_main_cpp.writeln("\t\treturn false;")
	g.server_main_cpp.writeln("\t}")
	g.server_main_cpp.writeln("\tNapi::Object obj = value.As<Napi::Object>();")
	g.server_main_cpp.writeln("\treturn obj.InstanceOf(${g.gen_ctor_name(g.obj_name)}.Value());")
	g.server_main_cpp.writeln("};")

	g.server_main_cpp.writeln("")

	g.server_main_cpp.writeln("VarValue ${g.gen_bind_class_name(g.obj_name)}::ToVMValue(const Napi::Value& value)")
	g.server_main_cpp.writeln("{")
	g.server_main_cpp.writeln("\tif (!IsInstance(value))")
	g.server_main_cpp.writeln("\t{")
	g.server_main_cpp.writeln("\t\treturn VarValue::None();")
	g.server_main_cpp.writeln("\t}")
	g.server_main_cpp.writeln("\tNapi::Object obj = value.As<Napi::Object>();")
	g.server_main_cpp.writeln("\t${g.gen_bind_class_name(g.obj_name)}* wrapper = Napi::ObjectWrap<${g.gen_bind_class_name(g.obj_name)}>::Unwrap(obj);")
	g.server_main_cpp.writeln("\treturn wrapper->self;")
	g.server_main_cpp.writeln("};")
	
	g.server_main_cpp.writeln("")

	g.server_main_cpp.writeln("Napi::Value ${g.gen_bind_class_name(g.obj_name)}::ToNapiValue(Napi::Env env, const VarValue& self)")
	g.server_main_cpp.writeln("{")
	g.server_main_cpp.writeln("\tif (self.GetType() != VarValue::Type::kType_Object || !self)")
	g.server_main_cpp.writeln("\t{")
	g.server_main_cpp.writeln("\t\t//todo error invalid self")
	g.server_main_cpp.writeln("\t\treturn env.Null();")
	g.server_main_cpp.writeln("\t}")
	g.server_main_cpp.writeln("\t// Создаем новый экземпляр ${g.gen_bind_class_name(g.obj_name)}")
	g.server_main_cpp.writeln("\tNapi::EscapableHandleScope scope(env);")
	g.server_main_cpp.writeln("\tNapi::Function ctor = ${g.gen_ctor_name(g.obj_name)}.Value();")
	g.server_main_cpp.writeln("\tNapi::Object instance = ctor.New({});")
	g.server_main_cpp.writeln("\t${g.gen_bind_class_name(g.obj_name)}* wrapper = Napi::ObjectWrap<${g.gen_bind_class_name(g.obj_name)}>::Unwrap(instance);")
	g.server_main_cpp.writeln("\tif (wrapper)")
	g.server_main_cpp.writeln("\t{")
	g.server_main_cpp.writeln("\t\twrapper->self = self;")
	g.server_main_cpp.writeln("\t}")
	g.server_main_cpp.writeln("\treturn scope.Escape(instance);")
	g.server_main_cpp.writeln("}")
}