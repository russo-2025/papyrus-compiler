module ts_binding_client

import papyrus.ast

fn (mut g Gen) gen_rpc_server_impl_fn(sym &ast.TypeSymbol, func &ast.FnDecl) {
	fn_name := g.get_real_impl_fn_name(sym.name, func.name)


	mut fn_decl_args_list := ""

	fn_decl_args_list += "MpActor* actor, uint32_t targetFormId"

	if func.params.len > 0 {
		fn_decl_args_list += ", "
	}

	g.b_rpc_server_cpp.writeln("void RpcServer::${fn_name}(${fn_decl_args_list})")
	g.b_rpc_server_cpp.writeln("{")
	g.b_rpc_server_cpp.writeln("}")
	g.b_rpc_server_cpp.writeln("")


	g.b_rpc_server_h.writeln("\tvoid ${fn_name}(${fn_decl_args_list});");
	
}

fn (mut g Gen) gen_rpc_server_start_file() {
	//g.b_rpc_client_cpp.writeln(rpc_client_start_file)
	g.b_rpc_server_h.writeln(rpc_server_h_start)
	g.b_rpc_server_cpp.writeln(rpc_server_cpp_start)
	g.b_rpc_server_cpp.writeln(g.create_rpc_headers())
}

fn (mut g Gen) gen_rpc_server_end_file() {
	g.b_rpc_server_h.writeln(rpc_server_h_end)
	g.b_rpc_server_cpp.writeln(rpc_server_cpp_end)
	/*
	g.b_rpc_client_cpp.writeln(rpc_client_run_snippet_start)
	
	g.each_files_fns(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File, func &ast.FnDecl) {
		g.b_rpc_client_cpp.writeln("\tcase PapyrusFunction::${g.get_fn_impl_name(sym.name, func.name)}:")
		//g.b_rpc_client_cpp.writeln("\t\t${g.get_fn_rpc_impl_name(sym.name, func.name)}(des, resultBuffer);")
		g.b_rpc_client_cpp.writeln("\t\t${g.get_fn_rpc_impl_name(sym.name, func.name)}(des, maxSize);")
		g.b_rpc_client_cpp.writeln("\t\tbreak;")
	})

	g.b_rpc_client_cpp.writeln(rpc_client_run_snippet_end)
	g.b_rpc_client_cpp.writeln("}; // end namespace JSBinding")
	*/
}

const rpc_server_h_start = 
"// !!! Generated automatically. Do not edit. !!!
#pragma once

#include <vector>

namespace JSBinding {

class RpcServer {
  public:
	typedef std::function<void(MpActor* actor, Networking::PacketData data, size_t size)> SendFn;
    
	RpcServer(SendFn _sendFn) : sendFn(_sendFn) {}
	/*
    void Form_GetFormId(MpActor* actor, VarValue selfFormId) {
        //...serialization

        SendToClient(userId, std::vector data);
    }
   
   */
"
const rpc_server_h_end = 
"
  private:
    void SendToClient(MpActor* actor, std::vector<uint8> data) {
		sendFn(actor, data.data(), data.size());
    }

    SendFn sendFn;
}

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