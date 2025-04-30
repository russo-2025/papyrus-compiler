module ts_binding_client

import papyrus.ast

fn (mut g Gen) gen_rpc_server_impl_fn(sym &ast.TypeSymbol, func &ast.FnDecl) {
	/*
	rpc_fn_name := g.get_fn_rpc_impl_name(sym.name, func.name)

	//g.b_rpc_client_cpp.writeln("void ${rpc_fn_name}(bitsery::Deserializer<Reader>& d, std::vector<uint8_t>& resultBuffer)")
	g.b_rpc_client_cpp.writeln("void ${rpc_fn_name}(bitsery::Deserializer<Reader>& d, size_t maxSize)")
	g.b_rpc_client_cpp.writeln("{")

	g.b_rpc_client_cpp.writeln("}")
	g.b_rpc_client_cpp.writeln("")
	*/
}

fn (mut g Gen) gen_rpc_server_start_file() {
	//g.b_rpc_client_cpp.writeln(rpc_client_start_file)
	g.b_rpc_server_h.writeln(rpc_server_h_start)
	g.b_rpc_server_h.writeln(g.create_rpc_headers())
	g.b_rpc_server_cpp.writeln(rpc_server_cpp_start)
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
"
const rpc_server_h_end = 
"
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