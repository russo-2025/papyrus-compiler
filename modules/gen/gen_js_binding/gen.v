module gen_js_binding

import papyrus.ast
import pref
import strings
import os

struct Gen {
mut:
	table					ast.Table

// h file
	class_bind_cpp			strings.Builder
// cpp file
	class_bind_h			strings.Builder
// Init Fn - methods list
	init_methods_bind_cpp	strings.Builder
// temp
	obj_name				string
	parent_obj_name			string
	fns						[]ast.FnDecl
}

pub fn gen(mut files []&ast.File, mut table ast.Table, prefs &pref.Preferences) {
	mut g := Gen{
		class_bind_cpp: strings.new_builder(1000)
		class_bind_h: strings.new_builder(1000)
		init_methods_bind_cpp: strings.new_builder(1000)
		table: table
	}


	g.class_bind_h.writeln("#pragma once")
	g.class_bind_h.writeln("")

	g.class_bind_h.writeln("#include <napi.h>")
	g.class_bind_h.writeln("#include \"NapiHelper.h\"")
	g.class_bind_h.writeln("#include \"papyrus-vm/Utils.h\"")
	g.class_bind_h.writeln("#include \"papyrus-vm/VarValue.h\"")
	g.class_bind_h.writeln("#include \"script_classes/PapyrusForm.h\"")
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("namespace JSBinding")
	g.class_bind_h.writeln("{")
	g.class_bind_h.writeln("")

	g.class_bind_cpp.writeln("#include \"__jsbind.h\"")
	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("namespace JSBinding {")

	for file in files {
		g.gen(file)
	}
	g.class_bind_cpp.writeln("}; // end namespace JSBinding")

	g.class_bind_h.writeln("}; // end namespace JSBinding")

	os.write_file(os.join_path(prefs.output_dir, "__jsbind.h"), g.class_bind_h.str()) or { panic("write_file err") }
	os.write_file(os.join_path(prefs.output_dir, "__jsbind.cpp"), g.class_bind_cpp.str()) or { panic("write_file err") }
}

fn (mut g Gen) gen(file &ast.File) {
	g.fns = []ast.FnDecl{}
	g.obj_name = file.obj_name
	g.parent_obj_name = (file.stmts[0] as ast.ScriptDecl).parent_name
	g.init_methods_bind_cpp.str() // clear

	for top_stmt in file.stmts {
		match top_stmt {
			ast.FnDecl {
				g.fns << top_stmt
			}
			else {}
		}		
	}

	impl_class_name := g.gen_impl_class_name(g.obj_name)
	bind_class_name := g.gen_bind_class_name(g.obj_name)

	// ============== generate h js bind =======================
	g.class_bind_h.writeln("class ${bind_class_name} : public Napi::ObjectWrap<${bind_class_name}> {")
	g.class_bind_h.writeln("public:")
	g.class_bind_h.writeln("\tstatic Napi::Object Init(Napi::Env env, Napi::Object exports);")
	g.class_bind_h.writeln("\t${bind_class_name}(const Napi::CallbackInfo& info);")
	g.class_bind_h.writeln("\t~${bind_class_name}() {};")
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("\t// wrappers")

	// ============== generate cpp js bind =======================

	g.class_bind_cpp.writeln("")
	g.class_bind_cpp.writeln("// ==================================================================================")
	g.class_bind_cpp.writeln("// ==================================${bind_class_name}==============================")
	g.class_bind_cpp.writeln("")
	
	// ===========================================================

	for top_stmt in file.stmts {
		match top_stmt {
			ast.ScriptDecl {
				//g.obj_name = top_stmt.name
				g.parent_obj_name = top_stmt.parent_name
			}
			ast.FnDecl { g.gen_func(&top_stmt) }
			ast.Comment {}
			ast.PropertyDecl {}
			ast.VarDecl {}
			ast.StateDecl {}
		}
	}

	// ============== generate cpp js bind =======================
	// Init
	// constructor
	// destructor
	// From
	// IsInstance
	// ToVMValue
	// ToNapiValue
	g.gen_end_bind_cpp()
	// ============== generate h js bind =======================
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("\t// tools")
	g.class_bind_h.writeln("\tstatic Napi::Value From(const Napi::CallbackInfo& info);")
	g.class_bind_h.writeln("\tstatic bool IsInstance(const Napi::Value& value);")
	g.class_bind_h.writeln("\tstatic VarValue ToVMValue(const Napi::Value& value);")
	g.class_bind_h.writeln("\tstatic Napi::Value ToNapiValue(Napi::Env env, const VarValue& value);")
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("private:")
	g.class_bind_h.writeln("\tVarValue self;")
	g.class_bind_h.writeln("")
	g.class_bind_h.writeln("\tstatic inline Napi::FunctionReference constructor;")
	g.class_bind_h.writeln("}; // end class ${bind_class_name}")
	g.class_bind_h.writeln("")
}

fn (mut g Gen) gen_end_bind_cpp() {
	for i, func in g.fns {
		js_class_name := g.gen_bind_class_name(g.obj_name)
		js_fn_name := g.gen_js_fn_name(func.name)
		fn_name := func.name

		if func.is_global {
			g.init_methods_bind_cpp.write_string("\t\tStaticMethod(\"${fn_name}\", &${js_class_name}::${js_fn_name})")
		}
		else {
			g.init_methods_bind_cpp.write_string("\t\tInstanceMethod(\"${fn_name}\", &${js_class_name}::${js_fn_name})")
		}

		if i != g.fns.len - 1 {
			g.init_methods_bind_cpp.writeln(",")
		}
	}

	g.class_bind_cpp.writeln("Napi::Object ${g.gen_bind_class_name(g.obj_name)}::Init(Napi::Env env, Napi::Object exports)")
	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("\tNapi::HandleScope scope(env);")
	g.class_bind_cpp.writeln("\tNapi::Function func = DefineClass( env, \"Form\", {")
	g.class_bind_cpp.writeln("${g.init_methods_bind_cpp.str()}")
	g.class_bind_cpp.writeln("\t});")
	g.class_bind_cpp.writeln("\tconstructor = Napi::Persistent(func);")
	g.class_bind_cpp.writeln("\tconstructor.SuppressDestruct();")
	g.class_bind_cpp.writeln("\texports.Set(\"Form\", func);")
	g.class_bind_cpp.writeln("\treturn exports;")
	g.class_bind_cpp.writeln("};")

	g.class_bind_cpp.writeln("")
	
	g.class_bind_cpp.writeln("${g.gen_bind_class_name(g.obj_name)}::${g.gen_bind_class_name(g.obj_name)}(const Napi::CallbackInfo& info) : ObjectWrap(info)")
	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("\tself = VarValue::None();")
	g.class_bind_cpp.writeln("};")

	g.class_bind_cpp.writeln("")

	g.class_bind_cpp.writeln("Napi::Value ${g.gen_bind_class_name(g.obj_name)}::From(const Napi::CallbackInfo& info)")
	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("\tauto formId = NapiHelper::ExtractUInt32(info[0], \"formId\");")
	g.class_bind_cpp.writeln("\t//todo add try catch")
	g.class_bind_cpp.writeln("\tauto& form = g_partOne->worldState.GetFormAt<MpForm>(formId);")
	g.class_bind_cpp.writeln("\t// todo check form")
	g.class_bind_cpp.writeln("\t// todo add check VarValue")
	//g.class_bind_cpp.writeln("\tauto res = ToNapiValue(info.Env(), VarValue(form.ToGameObject()));")
	
	g.class_bind_cpp.writeln("\treturn ${g.gen_convert_to_napivalue(g.obj_name, "VarValue(form.ToGameObject())")};")
	g.class_bind_cpp.writeln("};")

	g.class_bind_cpp.writeln("")

	g.class_bind_cpp.writeln("bool ${g.gen_bind_class_name(g.obj_name)}::IsInstance(const Napi::Value& value)")
	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("\tif (!value.IsObject())")
	g.class_bind_cpp.writeln("\t{")
	g.class_bind_cpp.writeln("\t\treturn false;")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\tNapi::Object obj = value.As<Napi::Object>();")
	g.class_bind_cpp.writeln("\treturn obj.InstanceOf(constructor.Value());")
	g.class_bind_cpp.writeln("};")

	g.class_bind_cpp.writeln("")

	g.class_bind_cpp.writeln("VarValue ${g.gen_bind_class_name(g.obj_name)}::ToVMValue(const Napi::Value& value)")
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

	g.class_bind_cpp.writeln("Napi::Value ${g.gen_bind_class_name(g.obj_name)}::ToNapiValue(Napi::Env env, const VarValue& self)")
	g.class_bind_cpp.writeln("{")
	g.class_bind_cpp.writeln("\tif (self.GetType() != VarValue::Type::kType_Object || !self)")
	g.class_bind_cpp.writeln("\t{")
	g.class_bind_cpp.writeln("\t\t//todo error invalid self")
	g.class_bind_cpp.writeln("\t\treturn env.Null();")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\t// Создаем новый экземпляр ${g.gen_bind_class_name(g.obj_name)}")
	g.class_bind_cpp.writeln("\tNapi::EscapableHandleScope scope(env);")
	g.class_bind_cpp.writeln("\tNapi::Function ctor = constructor.Value();")
	g.class_bind_cpp.writeln("\tNapi::Object instance = ctor.New({});")
	g.class_bind_cpp.writeln("\t${g.gen_bind_class_name(g.obj_name)}* wrapper = Napi::ObjectWrap<${g.gen_bind_class_name(g.obj_name)}>::Unwrap(instance);")
	g.class_bind_cpp.writeln("\tif (wrapper)")
	g.class_bind_cpp.writeln("\t{")
	g.class_bind_cpp.writeln("\t\twrapper->self = self;")
	g.class_bind_cpp.writeln("\t}")
	g.class_bind_cpp.writeln("\treturn scope.Escape(instance);")
	g.class_bind_cpp.writeln("}")
}

fn (mut g Gen) gen_func(func &ast.FnDecl) {
	js_class_name := g.gen_bind_class_name(g.obj_name)
	js_fn_name := g.gen_js_fn_name(func.name)

	// ============== generate h js bind =======================
	if func.is_global {
		g.class_bind_h.writeln("\tstatic Napi::Value ${js_fn_name}(const Napi::CallbackInfo& info);")
	}
	else {
		g.class_bind_h.writeln("\tNapi::Value ${js_fn_name}(const Napi::CallbackInfo& info);")
	}

	// ============== generate cpp js bind =======================
	g.class_bind_cpp.writeln("Napi::Value ${js_class_name}::${js_fn_name}(const Napi::CallbackInfo& info)")
	g.class_bind_cpp.writeln("{")
	
	mut all_args := ""
	return_type_name := g.table.get_type_symbol(func.return_type).name

	g.class_bind_cpp.writeln("\tstd::vector<VarValue> args = {")
	for i in 0..func.params.len {
		param := func.params[i]
		all_args += param.name

		param_type_name := g.table.get_type_symbol(param.typ).name
		arg := "info[${i}]"
		g.class_bind_cpp.write_string("\t\t${g.gen_convert_to_varvalue(param_type_name, arg)}")
		// g.class_bind_cpp.writeln("\tauto ${param.name} = NapiHelper::${get_extract_fn_name(g.table.get_type_symbol(param.typ).name)}(info[${i}], \"${param.name}\");")

		if i != func.params.len - 1 {
			g.class_bind_cpp.writeln(",")
		}
	}
	g.class_bind_cpp.writeln("\t};")

	if !func.is_global {
		g.class_bind_cpp.writeln("\tif (self.GetType() != VarValue::Type::kType_Object || !self)")
		g.class_bind_cpp.writeln("\t{")
		g.class_bind_cpp.writeln("\t\t//todo error invalid self")
		g.class_bind_cpp.writeln("\t\treturn info.Env().Null();")
		g.class_bind_cpp.writeln("\t}")
	}

	g.class_bind_cpp.writeln("\tstatic NativeFunction vm_${func.name} = VirtualMachine::GetInstance()->GetFunctionImplementation(\"Form\", \"GetFormID\", false);")
	g.class_bind_cpp.writeln("\t//todo error vm_${func.name} not found")
	g.class_bind_cpp.writeln("\t//todo add try catch")
	g.class_bind_cpp.writeln("\tNapi::Env env = info.Env();")
	
	if func.is_global {
		g.class_bind_cpp.writeln("\tVarValue res = vm_${func.name}(VarValue::None(), args);")
	}
	else {
		g.class_bind_cpp.writeln("\tVarValue res = vm_${func.name}(self, args);")
	}
	
	g.class_bind_cpp.writeln("\treturn ${g.gen_convert_to_napivalue(return_type_name, "res")};")
	g.class_bind_cpp.writeln("}")
	g.class_bind_cpp.writeln("")
}

//--------------------------------------utils--------------------------------------

fn (mut g Gen) gen_js_fn_name(name string) string {
	return name
}

fn (mut g Gen) gen_impl_class_name(name string) string {
	return "Papyrus${name}"
}

fn (mut g Gen) gen_bind_class_name(name string) string {
	return "JSPapyrus${name}"
}

fn (mut g Gen) gen_type_name(type_name string) string {
	match type_name.to_lower() {
		"bool" { return "Bool" }
		"int" { return "Int" }
		"float" { return "Float" }
		"string" { return "String" }
		else {
			if type_name.ends_with("[]") {
				panic("invlid type")
			}
			else {
				return type_name // TODO form -> Form
			}
		}
	}
}

fn (mut g Gen) gen_convert_to_napivalue(type_name string, var_value string) string {
	match type_name.to_lower() {
		"none" {
			return "info.Env().Null();"
		}
		"bool" {
			return "Napi::Boolean::New(info.Env(), (bool)${var_value})"
		}
		"int" {
			return "Napi::Number::New(info.Env(), (int)${var_value})"
		}
		"float" {
			return "Napi::Number::New(info.Env(), (double)${var_value})"
		}
		"string" {
			return "Napi::String::New(info.Env(), std::string((const char*)${var_value}))"
		}
		else {
			if type_name.ends_with("[]") {
				panic("invlid type")
			}
			else {
				return "${g.gen_bind_class_name(type_name)}::ToNapiValue(info.Env(), ${var_value})"
			}
		}
	}
}

fn (mut g Gen) gen_convert_to_varvalue(type_name string, js_value string) string {
	match type_name.to_lower() {
		"none" {
			panic("invlid type")
		}
		"bool" {
			return "VarValue(NapiHelper::ExtractBoolean(${js_value}, \"${js_value}\"))"
		}
		"int" {
			return "VarValue(NapiHelper::ExtractInt32(${js_value}, \"${js_value}\"))"
		}
		"float" {
			return "VarValue(NapiHelper::ExtractFloat(${js_value}, \"${js_value}\"))"
		}
		"string" {
			return "VarValue(NapiHelper::ExtractString(${js_value}, \"${js_value}\"))"
		}
		else {
			if type_name.ends_with("[]") {
				panic("invlid type")
			}
			else {
				return "${g.gen_bind_class_name(type_name)}::ToVMValue(${js_value})"
			}
		}
	}
}