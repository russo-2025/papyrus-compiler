module ts_binding_client

import papyrus.ast
import strings
import gen.ts_binding_client.client_util as c_util

fn (mut g Gen) gen_rpc_server() {
	// ---------------------------------------------------
	// H FILE
	g.b_rpc_server_h.writeln(rpc_server_h_start)
	// ---------------------------------------------------
	// CPP FILE
	g.b_rpc_server_cpp.writeln(rpc_server_cpp_start)
	g.b_rpc_server_cpp.writeln(g.create_rpc_headers())
	// ---------------------------------------------------

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		g.each_all_this_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl) {
			g.gen_rpc_server_impl_fn(sym, func)
		})
	})
	
	// ---------------------------------------------------
	// H FILE
	g.b_rpc_server_h.writeln(rpc_server_h_end)
	// ---------------------------------------------------
	// CPP FILE
	g.b_rpc_server_cpp.writeln(rpc_server_cpp_end)
	// ---------------------------------------------------
}
fn (mut g Gen) gen_rpc_server_impl_fn(sym &ast.TypeSymbol, func &ast.FnDecl) {
	fn_name := c_util.get_real_impl_fn_name(sym.name, func.name)


	mut fn_decl_args_list := strings.new_builder(100)

	fn_decl_args_list.write_string("MpActor* actor")

	if !func.is_global {
		fn_decl_args_list.write_string(", ")
		fn_decl_args_list.write_string("uint32_t selfFormId")
	}


/*

	if !func.is_global || func.params.len > 0 {
		fn_decl_args_list.write_string(", ")
	}

	if !func.is_global {
		fn_decl_args_list.write_string("uint32_t selfFormId")
	}*/

	if func.params.len > 0 {
		fn_decl_args_list.write_string(", ")
	}

	for param in func.params {
		param_impl_type_name := c_util.get_impl_type_name(g.table, g.impl_classes, param.typ)
		param_sym := g.table.get_type_symbol(param.typ)

		if param_sym.kind != .script {
			fn_decl_args_list.write_string(param_impl_type_name)
			fn_decl_args_list.write_string(" ")
			fn_decl_args_list.write_string(param.name)
			fn_decl_args_list.write_string(", ")
		}
		else {
			fn_decl_args_list.write_string("uint32_t/*${param_sym.name}*/ ${param.name}FormId, ")
		}
	}

	if func.params.len > 0 {
		// remove last `,`
		fn_decl_args_list.go_back(", ".len)
	}

	full_args := fn_decl_args_list.str()

	// ---------------------------------------------------
	// H FILE
	g.b_rpc_server_h.writeln("\tvoid ${fn_name}(${full_args});")
	// ---------------------------------------------------
	// CPP FILE
	g.b_rpc_server_cpp.writeln("void RpcServer::${fn_name}(${full_args})")
	g.b_rpc_server_cpp.writeln("{")
	g.b_rpc_server_cpp.writeln("\tBuffer buffer{};")
	g.b_rpc_server_cpp.writeln("\tbitsery::Serializer<Writer> ser{ buffer };")
	g.b_rpc_server_cpp.writeln("")

	g.b_rpc_server_cpp.writeln("\tser.value4b(${g.get_rpc_enum_func(sym.name, func.name)});")

	if !func.is_global {
		g.b_rpc_server_cpp.writeln("\tser.value4b(selfFormId);")
		g.b_rpc_server_cpp.writeln("")
	}

	for i in 0..func.params.len {
		param := func.params[i]
		param_sym := g.table.get_type_symbol(param.typ)

		match param_sym.kind {
			.placeholder,
			.none_ {
				panic("invalid type in param ${sym.name}.${func.name}")
			}
			.bool {
				g.b_rpc_server_cpp.writeln("\tser.value1b(${param.name});")
			}
			.int,
			.float {
				g.b_rpc_server_cpp.writeln("\tser.value4b(${param.name});")
			}
			.string {
				g.b_rpc_server_cpp.writeln("\tser.text1b(${param.name}, ${max_string_size_serialization});")
			}
			.array {
				panic("TODO array support")
			}
			.script {
				g.b_rpc_server_cpp.writeln("\tser.value4b(${param.name}FormId != actor->GetFormId() ? ${param.name}FormId : 0x14);")
			}
		}
	}
	
	g.b_rpc_server_cpp.writeln("")
	g.b_rpc_server_cpp.writeln("\tser.adapter().flush();")
	g.b_rpc_server_cpp.writeln("")
	g.b_rpc_server_cpp.writeln("\tspdlog::error(\"send rpc ${fn_name}; actorFormId: {}, vec.size:{}, ser.bytes: {}\", actor->GetFormId(), buffer.size(), ser.adapter().writtenBytesCount());")
	g.b_rpc_server_cpp.writeln("\tSendToClient(actor, buffer);")
	g.b_rpc_server_cpp.writeln("}")
	g.b_rpc_server_cpp.writeln("")
	// ---------------------------------------------------
}

const rpc_server_h_start = 
"// !!! Generated automatically. Do not edit. !!!
#pragma once

#include <vector>
#include <functional>
#include <MpActor.h>
#include <NetworkingInterface.h>
#include \"../messages/SpSnippetMessage.h\"

namespace JSBinding {

class RpcServer {
  public:
	RpcServer() {}
"
const rpc_server_h_end = 
"
  private:
	/*
	uint32_t NextPromiseId() {
		uint32_t res = promiseIndex++;
		return res;
	}
	
	void ResolvePromise(uint32_t promiseId, ) {
	
	}
	*/

    void SendToClient(MpActor* actor, std::vector<uint8_t> data) {
		SpSnippetMessage message = SpSnippetMessage();
		message.data = std::move(data);
		actor->SendToUser(message, true);
    }

	//uint32_t promiseIndex = 0;
	//std::map<uint32_t, std::future<int>> resultPromises;
};

} // end namespace JSBinding
"
const rpc_server_cpp_start = 
"// !!! Generated automatically. Do not edit. !!!
#include \"__js_rpc_server_bindings.h\"
#include <bitsery/bitsery.h>
#include <bitsery/adapter/buffer.h>
#include <bitsery/traits/vector.h>
#include <bitsery/traits/string.h>

namespace JSBinding {

using Buffer = std::vector<uint8_t>;
using Writer = bitsery::OutputBufferAdapter<Buffer>;
using Reader = bitsery::InputBufferAdapter<Buffer>;
"
const rpc_server_cpp_end = 
"
} // end namespace JSBinding
"