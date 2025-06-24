module ts_binding

import papyrus.ast
import gen.ts_binding.client_util as c_util

fn (mut g Gen) gen_client_main_h_file() {
	g.b_main_client_h.writeln(client_main_h_start_file)

	// write h - cpp impl functions list
	g.each_files_fns(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File, func &ast.FnDecl) {
		assert func.is_native
		
		if func.return_type != ast.none_type {
			g.b_main_client_h.write_string(c_util.get_impl_type_name(g.table, g.client_impl_classes, func.return_type))
			g.b_main_client_h.write_string(" ")
		}
		else {
			g.b_main_client_h.write_string("void ")
		}

		g.b_main_client_h.write_string(c_util.get_real_impl_fn_name(sym.name, func.name))

		mut args_list := ""

		if !func.is_global {
			args_list += c_util.get_impl_type_name(g.table, g.client_impl_classes, g.table.find_type_idx(sym.name))
			args_list += " self"

			if func.params.len != 0 {
				args_list += ", "
			}
		}

		for i in 0..func.params.len {
			param := func.params[i]
			
			if param.typ == ast.string_type {
				args_list += "const ${c_util.get_impl_type_name(g.table, g.client_impl_classes, param.typ)}& ${param.name}"
			}
			else {
				args_list += "${c_util.get_impl_type_name(g.table, g.client_impl_classes, param.typ)} ${param.name}"
			}
			
			if i != func.params.len - 1 {
				args_list += ", "
			}
		}
		g.b_main_client_h.write_string("(")
		g.b_main_client_h.write_string(args_list)
		g.b_main_client_h.writeln(");")
	})

	g.b_main_client_h.writeln("")

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		obj_type := g.table.find_type_idx(sym.name)
		bind_class_name := c_util.gen_bind_class_name(sym.obj_name)

		g.b_main_client_h.writeln("class ${bind_class_name} {")
		g.b_main_client_h.writeln("public:")
		g.b_main_client_h.writeln("\tstatic void Init(v8::Isolate* isolate, v8::Local<v8::Object> exports);")
		g.b_main_client_h.writeln("\texplicit ${bind_class_name}() {};")
		g.b_main_client_h.writeln("")
		if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
			g.b_main_client_h.writeln("\tstatic void Сtor(const v8::FunctionCallbackInfo<v8::Value>& args);")
			g.b_main_client_h.writeln("\tstatic void From(const v8::FunctionCallbackInfo<v8::Value>& args);")
			g.b_main_client_h.writeln("\tstatic void As(const v8::FunctionCallbackInfo<v8::Value>& args);")
		}

		g.b_main_client_h.writeln("\t// ${sym.name} methods")

		g.each_all_this_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl) {
			assert func.is_native
		
			g.gen_client_main_h_fn(sym, sym, func)
		})
		
		g.b_main_client_h.writeln("\t// parent methods")
		g.each_all_parent_fns(sym, fn[sym](mut g Gen, parent_sym &ast.TypeSymbol, func &ast.FnDecl) {
			assert func.is_native
		
			g.gen_client_main_h_fn(sym, parent_sym, func)
		})

		impl_type_name := c_util.get_impl_type_name(g.table, g.client_impl_classes, obj_type)
		g.b_main_client_h.writeln("")
		if !c_util.is_no_instance_class(g.no_instance_class, obj_type) {
			g.b_main_client_h.writeln("\t// tools")
			g.b_main_client_h.writeln("\tstatic ${impl_type_name} Cast(v8::Isolate* isolate, v8::Local<v8::Value> value);")
			g.b_main_client_h.writeln("\tstatic bool IsInstance(v8::Isolate* isolate, v8::Local<v8::Value> value);")
			g.b_main_client_h.writeln("\tstatic ${impl_type_name} Unwrap(v8::Isolate* isolate, v8::Local<v8::Value> value);")
			g.b_main_client_h.writeln("\tstatic ${impl_type_name} UnwrapSelf(v8::Isolate* isolate, v8::Local<v8::Value> value);")
			g.b_main_client_h.writeln("\tstatic v8::Local<v8::Value> Wrap(v8::Isolate* isolate, ${impl_type_name} value);")
		}
		g.b_main_client_h.writeln("}; // end class ${bind_class_name}")
		g.b_main_client_h.writeln("")
	})
	
	g.b_main_client_h.writeln(g.create_rpc_headers())

	g.b_main_client_h.writeln(client_main_h_end_file)
}

fn (mut g Gen) gen_client_main_h_fn(sym &ast.TypeSymbol, parent_sym &ast.TypeSymbol, func &ast.FnDecl) {
	//js_class_name := g.gen_bind_class_name(g.obj_name)
	js_fn_name := c_util.gen_js_fn_name(func.name)

	if func.is_global {
		g.b_main_client_h.writeln("\tstatic void ${js_fn_name}(const v8::FunctionCallbackInfo<v8::Value>& args);")
	}
	else {
		g.b_main_client_h.writeln("\tstatic void ${js_fn_name}(const v8::FunctionCallbackInfo<v8::Value>& args);")
	}
}

const client_main_h_start_file =
"// !!! Generated automatically. Do not edit. !!!

#pragma once

#include <JsHelper.h>
#include \"../data/PlayerContainer.h\"

namespace JSBinding
{"

const client_main_h_end_file = 
"void RegisterAllVMObjects(v8::Isolate* isolate, v8::Local<v8::Object> exports);
void HandleSpSnippet(std::shared_ptr<PlayerContainer> playerContainer, RpcPacket packet);
}; // end namespace JSBinding
"
