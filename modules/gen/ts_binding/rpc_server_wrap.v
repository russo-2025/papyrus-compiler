module ts_binding

import papyrus.ast
import strings
import gen.ts_binding.client_util as c_util
import gen.ts_binding.server_util as s_util

fn (mut g Gen) gen_rpc_server_wrap() {
	g.b_rpc_server_wrap_h.writeln(rpc_server_wrap_h_start)
	g.b_rpc_server_wrap_cpp.writeln(rpc_server_wrap_cpp_start)
	
	// ---------------------------------------------------

	g.gen_rpc_server_wrap_wraps()
	g.gen_rpc_server_wrap_register_func()
	
	// ---------------------------------------------------
	g.b_rpc_server_wrap_h.writeln(rpc_server_wrap_h_end)
	g.b_rpc_server_wrap_cpp.writeln(rpc_server_wrap_cpp_end)
}

fn (mut g Gen) gen_rpc_server_wrap_wraps() {
	g.each_files_fns(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File, func &ast.FnDecl) {
		assert func.is_native

		fn_name := c_util.get_real_impl_fn_name(sym.name, func.name)
		
		mut call_args := strings.new_builder(30)

		g.b_rpc_server_wrap_cpp.writeln("void ${fn_name}(const v8::FunctionCallbackInfo<v8::Value>& info)")
		g.b_rpc_server_wrap_cpp.writeln("{")
		g.b_rpc_server_wrap_cpp.writeln("\ttry")
		g.b_rpc_server_wrap_cpp.writeln("\t{")
		g.b_rpc_server_wrap_cpp.writeln("\t\tv8::Isolate* isolate = info.GetIsolate();")
		g.b_rpc_server_wrap_cpp.writeln("\t\tv8::HandleScope scope(isolate);")
		g.b_rpc_server_wrap_cpp.writeln("")
		g.b_rpc_server_wrap_cpp.writeln("\t\tDEBUG_ASSERT(isolate);")
		g.b_rpc_server_wrap_cpp.writeln("\t\tDEBUG_ASSERT(!isolate->GetCurrentContext().IsEmpty());")
		g.b_rpc_server_wrap_cpp.writeln("")

		mut args_offset := 1
		g.b_rpc_server_wrap_cpp.writeln("\t\tMpActor* playerActor = GetFormPtr<MpActor>(${s_util.gen_bind_class_name("Actor")}::UnwrapSelf(isolate, info[0]));")
		g.b_rpc_server_wrap_cpp.writeln("\t\tif(!playerActor)")
		g.b_rpc_server_wrap_cpp.writeln("\t\t{")
		g.b_rpc_server_wrap_cpp.writeln("\t\t\tERR_AND_THROW(\"invalid playerActor\");")
		g.b_rpc_server_wrap_cpp.writeln("\t\t}")
		g.b_rpc_server_wrap_cpp.writeln("")
		call_args.write_string("playerActor")

		if !func.is_global || (func.is_global && func.params.len != 0) {
			call_args.write_string(", ")
		}
		
		if !func.is_global {
			g.b_rpc_server_wrap_cpp.writeln("\t\tuint32_t selfFormId = JsHelper::ExtractUInt32(isolate, info[1], \"selfFormId\");")
			call_args.write_string("selfFormId")
			if func.params.len > 0 {
				call_args.write_string(", ")
			}
			args_offset++
		}
		
		g.b_rpc_server_wrap_cpp.writeln("")

		// extract args

		for i in args_offset..func.params.len + args_offset {
			param := func.params[i - args_offset]
			param_sym := g.table.get_type_symbol(param.typ)

			call_args.write_string(param.name)
			call_args.write_string(", ")
			
			
			if !param.is_optional {
				match param_sym.kind {
					.placeholder,
					.none_ {
						panic("invalid type in param ${sym.name}.${func.name}")
					}
					.bool {
						g.b_rpc_server_wrap_cpp.writeln("\t\tbool ${param.name} = JsHelper::ExtractBoolean(isolate, info[${i}], \"${param.name}\");")
					}
					.int {
						g.b_rpc_server_wrap_cpp.writeln("\t\tint32_t ${param.name} = JsHelper::ExtractInt32(isolate, info[${i}], \"${param.name}\");")
					}
					.float {
						g.b_rpc_server_wrap_cpp.writeln("\t\tdouble ${param.name} = JsHelper::ExtractDouble(isolate, info[${i}], \"${param.name}\");")
					}
					.string {
						g.b_rpc_server_wrap_cpp.writeln("\t\tstd::string ${param.name} = JsHelper::ExtractString(isolate, info[${i}], \"${param.name}\");")
					}
					.array {
						panic("TODO array support")
					}
					.script {
						g.b_rpc_server_wrap_cpp.writeln("\t\tuint32_t ${param.name} = JsHelper::ExtractUInt32(isolate, info[${i}], \"${param.name}\");")
					}
				}
			}
			else {
				default_value := match param.default_value {
					ast.NoneLiteral {
						"null"
					}
					ast.IntegerLiteral {
						"${param.default_value.val}"
					}
					ast.FloatLiteral {
						"${param.default_value.val}"
					}
					ast.BoolLiteral {
						"${param.default_value.val.to_lower()}"
					}
					ast.StringLiteral {
						"std::string(${param.default_value.val})"
					}
					else {
						panic("invalid expr in param ${param}")
					}
				}

				match param_sym.kind {
					.placeholder,
					.none_ {
						panic("invalid type in param ${sym.name}.${func.name}")
					}
					.bool {
						g.b_rpc_server_wrap_cpp.writeln("\t\tbool ${param.name} = JsHelper::ExtractOptionalBoolean(isolate, info[${i}], ${default_value}, \"${param.name}\");")
					}
					.int {
						g.b_rpc_server_wrap_cpp.writeln("\t\tint32_t ${param.name} = JsHelper::ExtractOptionalInt32(isolate, info[${i}], ${default_value}, \"${param.name}\");")
					}
					.float {
						g.b_rpc_server_wrap_cpp.writeln("\t\tdouble ${param.name} = JsHelper::ExtractOptionalFloat(isolate, info[${i}], ${default_value}, \"${param.name}\");")
					}
					.string {
						g.b_rpc_server_wrap_cpp.writeln("\t\tstd::string ${param.name} = JsHelper::ExtractOptionalString(isolate, info[${i}], ${default_value}, \"${param.name}\");")
					}
					.array {
						panic("TODO array support")
					}
					.script {
						g.b_rpc_server_wrap_cpp.writeln("\t\tuint32_t ${param.name} = JsHelper::ExtractUInt32Optional(isolate, info[${i}], 0, \"${param.name}\");")
					}
				}
			}
		}

		if func.params.len > 0 {
			call_args.go_back(", ".len)

			g.b_rpc_server_wrap_cpp.writeln("")
		}

		g.b_rpc_server_wrap_cpp.writeln("\t\tg_rpcServer->${fn_name}(${call_args.str()});")

		g.b_rpc_server_wrap_cpp.writeln("\t}")
		g.b_rpc_server_wrap_cpp.writeln("\tcatch(std::exception& e)")
		g.b_rpc_server_wrap_cpp.writeln("\t{")
		g.b_rpc_server_wrap_cpp.writeln("\t\tstd::string msg = e.what();")
		g.b_rpc_server_wrap_cpp.writeln("\t\tERR(msg);")
		g.b_rpc_server_wrap_cpp.writeln("\t\tinfo.GetIsolate()->ThrowException(v8::Exception::Error(v8::String::NewFromUtf8(info.GetIsolate(), msg.c_str()).ToLocalChecked()));")
		g.b_rpc_server_wrap_cpp.writeln("\t\treturn;")
		g.b_rpc_server_wrap_cpp.writeln("\t}")
		g.b_rpc_server_wrap_cpp.writeln("")
		g.b_rpc_server_wrap_cpp.writeln("\tinfo.GetReturnValue().Set(v8::Null(info.GetIsolate()));")
		g.b_rpc_server_wrap_cpp.writeln("}")
		g.b_rpc_server_wrap_cpp.writeln("")
	})
}

fn (mut g Gen) gen_rpc_server_wrap_register_func() {
	g.b_rpc_server_wrap_cpp.writeln("void RegisterSpSnippet(v8::Isolate* isolate, v8::Local<v8::Object> exports)")
	g.b_rpc_server_wrap_cpp.writeln("{")
	g.b_rpc_server_wrap_cpp.writeln("\tv8::HandleScope scope(isolate);")
	g.b_rpc_server_wrap_cpp.writeln("\tv8::Local<v8::Context> context = isolate->GetCurrentContext();")
	g.b_rpc_server_wrap_cpp.writeln("")
	g.b_rpc_server_wrap_cpp.writeln("\tauto spSnippet = v8::Object::New(isolate);")
	g.b_rpc_server_wrap_cpp.writeln("")
	g.each_files_fns(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File, func &ast.FnDecl) {
		fn_name := c_util.get_real_impl_fn_name(sym.name, func.name)
		g.b_rpc_server_wrap_cpp.writeln("\tAddObjProperty(isolate, spSnippet, \"${fn_name}\", ${fn_name});")

		
	})
	g.b_rpc_server_wrap_cpp.writeln("")
	g.b_rpc_server_wrap_cpp.writeln("\tSetObjPropertyV8(isolate, exports, \"SpSnippet\", spSnippet);")
	g.b_rpc_server_wrap_cpp.writeln("}")
	g.b_rpc_server_wrap_cpp.writeln("")
}

const rpc_server_wrap_h_start = 
"// !!! Generated automatically. Do not edit. !!!
#pragma once
#include <JsHelper.h>

namespace JSBinding {"
const rpc_server_wrap_h_end = 
"void RegisterSpSnippet(v8::Isolate* isolate, v8::Local<v8::Object> exports);
} // end namespace JSBinding
"
const rpc_server_wrap_cpp_start = 
"// !!! Generated automatically. Do not edit. !!!
#include \"__js_rpc_server_wrap_bindings.h\"
#include \"__js_rpc_server_bindings.h\"
#include \"__js_bindings.h\"
#include \"ScampServer.h\"
#include <JsUtils.h>

extern std::shared_ptr<JSBinding::RpcServer> g_rpcServer;

namespace JSBinding {
"
const rpc_server_wrap_cpp_end = 
"} // end namespace JSBinding
"