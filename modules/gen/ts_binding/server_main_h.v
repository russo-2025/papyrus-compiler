module ts_binding

import papyrus.ast
import gen.ts_binding.server_util as s_util
import gen.ts_binding.client_util as c_util

fn (mut g Gen) gen_server_main_h_file() {
	g.server_main_h.writeln(server_main_h_file_start)

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		bind_class_name := s_util.gen_bind_class_name(sym.name)
		obj_type := g.table.find_type_idx(sym.name)

		g.server_main_h.writeln("class ${bind_class_name} {")
		g.server_main_h.writeln("public:")
		g.server_main_h.writeln("\tstatic void Init(v8::Isolate* isolate, v8::Local<v8::Object> exports);")
		g.server_main_h.writeln("\texplicit ${bind_class_name}() {};")
		g.server_main_h.writeln("")
		g.server_main_h.writeln("static void Сtor(const v8::FunctionCallbackInfo<v8::Value>& args);")
		g.server_main_h.writeln("\t// wrappers")

		g.server_main_h.writeln("\t// ${sym.name} methods")

		g.each_all_this_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl) {
			assert func.is_native
		
			js_fn_name := s_util.gen_js_fn_name(func.name)

			g.server_main_h.writeln("\tstatic void ${js_fn_name}(const v8::FunctionCallbackInfo<v8::Value>& info);")
		})

		g.server_main_h.writeln("\t// parent methods")
		g.each_all_parent_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl){
			assert func.is_native
		
			js_fn_name := s_util.gen_js_fn_name(func.name)

			g.server_main_h.writeln("\tstatic void ${js_fn_name}(const v8::FunctionCallbackInfo<v8::Value>& info);")
		})

		if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
			g.server_main_h.writeln("")
			g.server_main_h.writeln("\t// tools")
			g.server_main_h.writeln("\tstatic void From(const v8::FunctionCallbackInfo<v8::Value>& info);")
			g.server_main_h.writeln("\tstatic VarValue UnwrapSelf(v8::Isolate* isolate, v8::Local<v8::Value> value);")
			g.server_main_h.writeln("\tstatic v8::Local<v8::Value> Wrap(v8::Isolate* isolate, const VarValue& value);")
		}
		g.server_main_h.writeln("}; // end class ${bind_class_name}")
		g.server_main_h.writeln("")
	})

	g.server_main_h.writeln(server_main_h_file_end)
}

const server_main_h_file_start = 
"// !!! Generated automatically. Do not edit. !!!
#pragma once
#include <JsHelper.h>
#include <papyrus-vm/Utils.h>
#include <papyrus-vm/VarValue.h>

namespace JSBinding
{
"

const server_main_h_file_end = 
"void RegisterAllVMObjects(v8::Isolate* isolate, v8::Local<v8::Object> exports);
}; // end namespace JSBinding"