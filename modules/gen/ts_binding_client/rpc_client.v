module ts_binding_client

import papyrus.ast
import strings
import gen.ts_binding_client.client_util as c_util

fn (mut g Gen) gen_rpc_client() {
	//start file
	g.b_rpc_client_cpp.writeln(rpc_client_cpp_start_file)

	g.each_all_files(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File) {
		g.each_all_this_fns(sym, fn(mut g Gen, sym &ast.TypeSymbol, func &ast.FnDecl){
			g.gen_rpc_clint_impl_fn(sym, func)
			//g.gen_rpc_server_impl_fn(sym, func)
		})
	})

	//end file
	g.b_rpc_client_cpp.writeln(rpc_client_run_snippet_start)
	
	g.each_files_fns(fn(mut g Gen, sym &ast.TypeSymbol, file &ast.File, func &ast.FnDecl) {
		g.b_rpc_client_cpp.writeln("\tcase ${g.get_rpc_enum_func(sym.name, func.name)}:")
		//g.b_rpc_client_cpp.writeln("\t\t${g.get_fn_rpc_impl_name(sym.name, func.name)}(des, resultBuffer);")
		g.b_rpc_client_cpp.writeln("\t\t${c_util.get_fn_rpc_impl_name(sym.name, func.name)}(des, maxSize);")
		g.b_rpc_client_cpp.writeln("\t\tbreak;")
	})

	g.b_rpc_client_cpp.writeln(rpc_client_run_snippet_end)
	g.b_rpc_client_cpp.writeln("}; // end namespace JSBinding")
}

fn (mut g Gen) gen_rpc_clint_impl_fn(sym &ast.TypeSymbol, func &ast.FnDecl) {
	rpc_fn_name := c_util.get_fn_rpc_impl_name(sym.name, func.name)
	obj_type := g.table.find_type_idx(sym.name)

	//g.b_rpc_client_cpp.writeln("void ${rpc_fn_name}(bitsery::Deserializer<Reader>& d, std::vector<uint8_t>& resultBuffer)")
	g.b_rpc_client_cpp.writeln("void ${rpc_fn_name}(bitsery::Deserializer<Reader>& d, size_t maxSize)")
	g.b_rpc_client_cpp.writeln("{")

	mut call_args_list := ""

	impl_fn_name := c_util.get_fn_impl_name(sym.name, func.name)

	call_args_list += impl_fn_name

	if !func.is_global || func.params.len > 0 {
		call_args_list += ", "
	}

	if !func.is_global {
		g.b_rpc_client_cpp.writeln("\tuint32_t selfFormId = 0;")
		g.b_rpc_client_cpp.writeln("\td.value4b(selfFormId);")
		g.b_rpc_client_cpp.writeln("\t${c_util.get_impl_type_name(g.table, g.impl_classes, obj_type)} self = RE::TESForm::LookupByID<${c_util.get_impl_obj_type_name(g.table, g.impl_classes, obj_type)}>(selfFormId);")
		g.b_rpc_client_cpp.writeln("")
		g.b_rpc_client_cpp.writeln("\tif(!self)")
		g.b_rpc_client_cpp.writeln("\t{")
		g.b_rpc_client_cpp.writeln("\t\tERR_AND_THROW(\"Invalid self\");")
		g.b_rpc_client_cpp.writeln("\t}")
		g.b_rpc_client_cpp.writeln("")

		call_args_list += "self"

		if func.params.len >= 1 {
			call_args_list += ", "
		}
	}

	for i in 0..func.params.len {
		param := func.params[i]
		param_sym := g.table.get_type_symbol(param.typ)
		param_impl_type_name := c_util.get_impl_type_name(g.table, g.impl_classes, param.typ)
		
		
		g.b_rpc_client_cpp.writeln("\t// read arg ${i + 1}")
		g.b_rpc_client_cpp.writeln("\t${param_impl_type_name} ${param.name};")

		match param_sym.kind {
			.placeholder,
			.none_ {
				panic("invalid type in param ${sym.name}.${func.name}")
			}
			.bool {
				g.b_rpc_client_cpp.writeln("\td.value1b(${param.name});")
			}
			.int,
			.float {
				g.b_rpc_client_cpp.writeln("\td.value4b(${param.name});")
			}
			.string {
				//g.b_rpc_client_cpp.writeln("\t${param.name}.reserve(maxSize);")
				g.b_rpc_client_cpp.writeln("\td.text1b(${param.name}, ${max_string_size_serialization});")
			}
			.array {
				panic("TODO array support")
			}
			.script {
				param_impl_obj_type_name := c_util.get_impl_obj_type_name(g.table, g.impl_classes, param.typ)
				g.b_rpc_client_cpp.writeln("\tuint32_t ${param.name}_id;")
				g.b_rpc_client_cpp.writeln("\td.value4b(${param.name}_id);")
				g.b_rpc_client_cpp.writeln("\t${param.name} = RE::TESForm::LookupByID<${param_impl_obj_type_name}>(${param.name}_id);")
			}
		}
		g.b_rpc_client_cpp.writeln("")

		

		call_args_list += param.name

		if i != func.params.len - 1 {
			call_args_list += ", "
		}
	}
	
	g.b_rpc_client_cpp.write_string("\t")
	
	/*
	if func.return_type != ast.none_type {
		return_type_name := g.get_impl_type_name(func.return_type)
		g.b_rpc_client_cpp.write_string("${return_type_name} res = ")
	}*/

	if !func.is_global {
		g.b_rpc_client_cpp.write_string("ThreadCommunicator::GetSingleton()->ExecuteGameFunction(${call_args_list})")
	}
	else {
		g.b_rpc_client_cpp.write_string("ThreadCommunicator::GetSingleton()->ExecuteGameFunction(${call_args_list})")
	}

	g.b_rpc_client_cpp.writeln(";")
	/*
	if func.return_type != ast.none_type {
		g.b_rpc_client_cpp.writeln(".get();")
	}
	
	g.b_rpc_client_cpp.writeln("")
	g.b_rpc_client_cpp.writeln("\tbitsery::Serializer<Writer> ser{resultBuffer};")
	if func.return_type != ast.none_type {
		// return result???
  		g.b_rpc_client_cpp.writeln("\tser.value4b(res);")
	}
    g.b_rpc_client_cpp.writeln("\tser.adapter().flush();")
	*/
	g.b_rpc_client_cpp.writeln("}")
	g.b_rpc_client_cpp.writeln("")
}

fn (mut g Gen) get_rpc_enum_func(obj_name string, func_name string) string {
	return "PapyrusFunction::${c_util.get_fn_impl_name(obj_name, func_name)}"
}

fn (mut g Gen) create_rpc_headers() string {
	mut b := strings.new_builder(300)
	b.writeln("enum class PapyrusFunction : uint32_t")
	b.writeln("{")
	b.writeln("\tInvalid = 0,")

	mut b_ptr := &b
	g.each_files_fns(fn[mut b_ptr](mut g Gen, sym &ast.TypeSymbol, file &ast.File, func &ast.FnDecl) {
		b_ptr.writeln("\t${c_util.get_fn_impl_name(sym.name, func.name)},")
	})

	b.writeln("};")

	b.writeln(h_rpc_client_text)

	return b.str()
}

const rpc_client_cpp_start_file = 
"// !!! Generated automatically. Do not edit. !!!

#include \"__js_bindings.h\"
#include \"../ThreadCommunicator.h\"
#include <bitsery/bitsery.h>
#include <bitsery/adapter/buffer.h>
#include <bitsery/traits/vector.h>
#include <bitsery/traits/string.h>

namespace JSBinding {

using Buffer = std::vector<uint8_t>;
using Writer = bitsery::OutputBufferAdapter<Buffer>;
using Reader = bitsery::InputBufferAdapter<Buffer>;
"

const h_rpc_client_text = 
"
struct RpcPacket
{
    std::vector<uint8_t> data;
    
    RpcPacket(std::vector<uint8_t>&& buffer) : data(std::move(buffer)) {}
};"

const rpc_client_run_snippet_start = 
"void HandleSpSnippet(RpcPacket packet)
{
	bitsery::Deserializer<Reader> des{packet.data.begin(), packet.data.size()};
	size_t maxSize = packet.data.size();

	PapyrusFunction func = PapyrusFunction::Invalid;
	des.value4b(func);

	if (des.adapter().error() != bitsery::ReaderError::NoError)
	{
		ERR_AND_THROW(\"ERROR deserializer\");
	}

	//std::vector<uint8_t> resultBuffer;

	switch (func)
	{
	case PapyrusFunction::Invalid:
		ERR_AND_THROW(\"invalid function\");
		break;"

const rpc_client_run_snippet_end = 
"	default:
		ERR_AND_THROW(\"invalid function\");
		break;
	}

    if (des.adapter().error() != bitsery::ReaderError::NoError) {
        ERR_AND_THROW(\"ERROR deserializer\")
    }
    
    //return RpcPacket(packet.request_id, std::move(resultBuffer));
}"

const max_string_size_serialization = int(400)