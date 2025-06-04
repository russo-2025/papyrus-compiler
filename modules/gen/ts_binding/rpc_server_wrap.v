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

		g.b_rpc_server_wrap_cpp.writeln("Napi::Value ${fn_name}(const Napi::CallbackInfo& info)")
		g.b_rpc_server_wrap_cpp.writeln("{")
		g.b_rpc_server_wrap_cpp.writeln("\ttry")
		g.b_rpc_server_wrap_cpp.writeln("\t{")

		mut args_offset := 1
		g.b_rpc_server_wrap_cpp.writeln("\t\tMpActor* playerActor = GetFormPtr<MpActor>(${s_util.gen_bind_class_name("Actor")}::ToVMValue(info[0]));")
		g.b_rpc_server_wrap_cpp.writeln("\t\tif(!playerActor)")
		g.b_rpc_server_wrap_cpp.writeln("\t\t{")
		g.b_rpc_server_wrap_cpp.writeln("\t\t\tthrow std::runtime_error(\"invalid playerActor\");")
		g.b_rpc_server_wrap_cpp.writeln("\t\t}")
		g.b_rpc_server_wrap_cpp.writeln("")
		call_args.write_string("playerActor")

		if !func.is_global || (func.is_global && func.params.len != 0) {
			call_args.write_string(", ")
		}
		
		if !func.is_global {
			g.b_rpc_server_wrap_cpp.writeln("\t\tuint32_t selfFormId = NapiHelper::ExtractUInt32(info[1], \"selfFormId\");")
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
						g.b_rpc_server_wrap_cpp.writeln("\t\tbool ${param.name} = NapiHelper::ExtractBoolean(info[${i}], \"${param.name}\");")
					}
					.int {
						g.b_rpc_server_wrap_cpp.writeln("\t\tint32_t ${param.name} = NapiHelper::ExtractInt32(info[${i}], \"${param.name}\");")
					}
					.float {
						g.b_rpc_server_wrap_cpp.writeln("\t\tdouble ${param.name} = NapiHelper::ExtractDouble(info[${i}], \"${param.name}\");")
					}
					.string {
						g.b_rpc_server_wrap_cpp.writeln("\t\tstd::string ${param.name} = NapiHelper::ExtractString(info[${i}], \"${param.name}\");")
					}
					.array {
						panic("TODO array support")
					}
					.script {
						g.b_rpc_server_wrap_cpp.writeln("\t\tuint32_t ${param.name} = NapiHelper::ExtractUInt32(info[${i}], \"${param.name}\");")
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
						g.b_rpc_server_wrap_cpp.writeln("\t\tbool ${param.name} = NapiHelper::ExtractOptionalBoolean(info[${i}], ${default_value}, \"${param.name}\");")
					}
					.int {
						g.b_rpc_server_wrap_cpp.writeln("\t\tint32_t ${param.name} = NapiHelper::ExtractOptionalInt32(info[${i}], ${default_value}, \"${param.name}\");")
					}
					.float {
						g.b_rpc_server_wrap_cpp.writeln("\t\tdouble ${param.name} = NapiHelper::ExtractOptionalFloat(info[${i}], ${default_value}, \"${param.name}\");")
					}
					.string {
						g.b_rpc_server_wrap_cpp.writeln("\t\tstd::string ${param.name} = NapiHelper::ExtractOptionalString(info[${i}], ${default_value}, \"${param.name}\");")
					}
					.array {
						panic("TODO array support")
					}
					.script {
						g.b_rpc_server_wrap_cpp.writeln("\t\tuint32_t ${param.name} = NapiHelper::ExtractUInt32Optional(info[${i}], 0, \"${param.name}\");")
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
		g.b_rpc_server_wrap_cpp.writeln("\t\tspdlog::error((std::string)e.what());")
		g.b_rpc_server_wrap_cpp.writeln("\t\tthrow Napi::Error::New(info.Env(), (std::string)e.what());")
		g.b_rpc_server_wrap_cpp.writeln("\t}")
		g.b_rpc_server_wrap_cpp.writeln("")
		g.b_rpc_server_wrap_cpp.writeln("\treturn info.Env().Undefined();")
		g.b_rpc_server_wrap_cpp.writeln("}")
		g.b_rpc_server_wrap_cpp.writeln("")
	})
}

fn (mut g Gen) gen_rpc_server_wrap_register_func() {
	g.b_rpc_server_wrap_cpp.writeln("void RegisterSpSnippet(Napi::Env env, Napi::Object exports)")
	g.b_rpc_server_wrap_cpp.writeln("{")
	g.b_rpc_server_wrap_cpp.writeln("\tauto spSnippet = Napi::Object::New(env);")
	g.each_files_fns(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File, func &ast.FnDecl) {
		fn_name := c_util.get_real_impl_fn_name(sym.name, func.name)
		g.b_rpc_server_wrap_cpp.writeln("\tspSnippet.Set(\"${fn_name}\", Napi::Function::New(env, ${fn_name}));")
	})
	g.b_rpc_server_wrap_cpp.writeln("\texports.Set(\"SpSnippet\", spSnippet);")
	g.b_rpc_server_wrap_cpp.writeln("}")
	g.b_rpc_server_wrap_cpp.writeln("")
}

const rpc_server_wrap_h_start = 
"// !!! Generated automatically. Do not edit. !!!
#pragma once
#include <napi.h>
#include \"NapiHelper.h\"

namespace JSBinding {
"
const rpc_server_wrap_h_end = 
"
void RegisterSpSnippet(Napi::Env env, Napi::Object exports);
} // end namespace JSBinding
"
const rpc_server_wrap_cpp_start = 
"// !!! Generated automatically. Do not edit. !!!
#include \"__js_rpc_server_wrap_bindings.h\"
#include \"__js_rpc_server_bindings.h\"
#include \"__js_bindings.h\"

extern std::shared_ptr<JSBinding::RpcServer> g_rpcServer;

namespace JSBinding {
"
const rpc_server_wrap_cpp_end = 
"} // end namespace JSBinding
"