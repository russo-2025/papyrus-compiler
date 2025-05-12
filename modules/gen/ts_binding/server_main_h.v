module ts_binding

import papyrus.ast
import gen.ts_binding.server_util as s_util
import gen.ts_binding.client_util as c_util

fn (mut g Gen) gen_server_main_h_file() {
	g.server_main_h.writeln(server_main_h_file_start)

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		bind_class_name := s_util.gen_bind_class_name(sym.name)
		obj_type := g.table.find_type_idx(sym.name)

		g.server_main_h.writeln("class ${bind_class_name} final : public Napi::ObjectWrap<${bind_class_name}> {")
		g.server_main_h.writeln("public:")
		g.server_main_h.writeln("\tstatic Napi::Object Init(Napi::Env env, Napi::Object exports);")
		g.server_main_h.writeln("\t${bind_class_name}(const Napi::CallbackInfo& info);")
		g.server_main_h.writeln("\t~${bind_class_name}() {};")
		g.server_main_h.writeln("")
		g.server_main_h.writeln("\t// wrappers")

		g.server_main_h.writeln("\t// ${sym.name} methods")

		g.each_all_this_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl) {
			assert func.is_native
		
			js_fn_name := s_util.gen_js_fn_name(func.name)

			if func.is_global {
				g.server_main_h.writeln("\tstatic Napi::Value ${js_fn_name}(const Napi::CallbackInfo& info);")
			}
			else {
				g.server_main_h.writeln("\tNapi::Value ${js_fn_name}(const Napi::CallbackInfo& info);")
			}
		})

		g.server_main_h.writeln("\t// parent methods")
		g.each_all_parent_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl){
			assert func.is_native
		
			js_fn_name := s_util.gen_js_fn_name(func.name)

			if func.is_global {
				g.server_main_h.writeln("\tstatic Napi::Value ${js_fn_name}(const Napi::CallbackInfo& info);")
			}
			else {
				g.server_main_h.writeln("\tNapi::Value ${js_fn_name}(const Napi::CallbackInfo& info);")
			}
		})

		if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
			g.server_main_h.writeln("")
			g.server_main_h.writeln("\t// tools")
			g.server_main_h.writeln("\tstatic Napi::Value From(const Napi::CallbackInfo& info);")
			g.server_main_h.writeln("\tstatic bool IsInstance(const Napi::Value& value);")
			g.server_main_h.writeln("\tstatic VarValue ToVMValue(const Napi::Value& value);")
			g.server_main_h.writeln("\tstatic Napi::Value ToNapiValue(Napi::Env env, const VarValue& value);")
			g.server_main_h.writeln("")
			g.server_main_h.writeln("private:")
			g.server_main_h.writeln("\tVarValue self;")
		}
		g.server_main_h.writeln("}; // end class ${bind_class_name}")
		g.server_main_h.writeln("")
	})

	g.server_main_h.writeln(server_main_h_file_end)
}

const server_main_h_file_start = 
"// !!! Generated automatically. Do not edit. !!!
#pragma once
#include <napi.h>
#include \"NapiHelper.h\"
#include \"papyrus-vm/Utils.h\"
#include \"papyrus-vm/VarValue.h\"

namespace JSBinding
{
"

const server_main_h_file_end = 
"void RegisterAllVMObjects(Napi::Env env, Napi::Object exports);
}; // end namespace JSBinding"