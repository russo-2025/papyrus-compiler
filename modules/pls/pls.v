module pls

import papyrus.ast
import pref

import jsonrpc
import lsp
import lsp.log

import json
import os

pub enum Feature {
	diagnostics
	formatting
	document_symbol
	workspace_symbol
	signature_help
	completion
	hover
	folding_range
	definition
}

// feature_from_str returns the Feature-enum value equivalent of the given string.
// used internally for Vls.set_features method only.
fn feature_from_str(feature_name string) ?Feature {
	match feature_name {
		'diagnostics' { return Feature.diagnostics }
		'formatting' { return Feature.formatting }
		'document_symbol' { return Feature.document_symbol }
		'workspace_symbol' { return Feature.workspace_symbol }
		'signature_help' { return Feature.signature_help }
		'completion' { return Feature.completion }
		'hover' { return Feature.hover }
		'folding_range' { return Feature.folding_range }
		'definition' { return Feature.definition }
		else { return error('feature "$feature_name" not found') }
	}
}

const (
	compiler_path =  "D:\\_projects\\papyrus\\compiler\bin\\papyrus.exe"
	builtin_path  = os.join_path('D:\\_projects\\papyrus\\compiler', 'builtin')
)

pub const (
	default_features_list = [
		Feature.completion,
	]
)

interface ReceiveSender {
	debug bool
	send(data string)
	receive() ?string
}

pub enum ServerStatus {
	off
	initialized
	shutdown
}

struct Pls {
mut:
	base_table			&ast.Table
	status				ServerStatus = .off
	logger				log.Logger
	debug				bool
	root_uri			lsp.DocumentUri
	enabled_features	[]Feature = default_features_list
	capabilities		lsp.ServerCapabilities
	panic_count			int

	files				map[string]&ast.File
	sources				map[string][]byte
	tables				map[string]&ast.Table
	
	scripts				map[string]string
	input_dirs			[]string
pub mut:
	io					ReceiveSender
}

pub fn new(io ReceiveSender) Pls {
	mut tbl := ast.new_table()

	return Pls{
		io: io
		base_table: tbl
		debug: io.debug
		logger: log.new(.text)
	}
}

pub fn (mut ls Pls) start_loop() {
	for {
		payload := ls.io.receive() or { continue }
		ls.dispatch(payload)
	}
}

pub fn (mut ls Pls) dispatch(payload string) {
	request := json.decode(jsonrpc.Request, payload) or {
		ls.send(new_error(jsonrpc.parse_error))
		return
	} 
	
	if request.id == -2 {
		ls.logger.notification(payload, .send)
		ls.logger.notification(payload, .receive)
	} else {
		ls.logger.request(payload, .send)
		ls.logger.request(payload, .receive)
	}
	
	ls.log_message('request: ${request.str()}', .info)

	//println(request)

	if ls.status == .initialized {
		match request.method {
			'initialized' {}
			'shutdown' {
				ls.exit()
			}
			'exit' {}
			
			'textDocument/didOpen' { ls.did_open(request.id, request.params) }
			//'textDocument/didChange' { ls.did_change(request.id, request.params) }
			'textDocument/didClose' { ls.did_close(request.id, request.params) }
			
			'workspace/didChangeWatchedFiles' { ls.did_change_watched_files(request.id, request.params) }
			
			'textDocument/completion' { ls.completion(request.id, request.params) }
			
			else {}
		}
	}
	else {
		match request.method {
			'initialize' {
				ls.initialize(request.id, request.params)
			}
			'initialized' {
				ls.initialized()
			}
			'exit' {
				ls.exit()
			}
			else {
				err_type := if ls.status == .shutdown {
					jsonrpc.invalid_request
				} else {
					jsonrpc.server_not_initialized
				}

				ls.send(new_error(err_type))
			}
		}
	}
}

// new_table returns a new table based on the existing data of base_table
fn (ls &Pls) new_table() &ast.Table {
	mut tbl := &ast.Table{
		types: ls.base_table.types.clone()
	}
	
	tbl.type_idxs = ls.base_table.type_idxs.clone()
	tbl.fns = ls.base_table.fns.clone()
	tbl.fields = ls.base_table.fields.clone()
	tbl.modules = ls.base_table.modules.clone()
	tbl.panic_handler = table_panic_handler
	tbl.panic_userdata = ls

	return tbl
}

// new_scope_and_pref returns a new instance of scope and pref based on the given lookup paths
fn new_scope_and_pref() (&ast.Scope, &pref.Preferences) {
	scope := &ast.Scope{
		parent: 0
	}
	prefs := &pref.Preferences{
		mode: .compile
		no_cache: true
	}

	return scope, prefs
}

// log_path returns the combined path of the workspace's root URI and the log file name.
fn (ls Pls) log_path() string {
	return os.join_path(ls.root_uri.path(), 'pls.log')
}

// set_features enables or disables a language feature. emits an error if not found
pub fn (mut ls Pls) set_features(features []string, enable bool) ? {
	for feature_name in features {
		feature_val := feature_from_str(feature_name) ?
		if feature_val !in ls.enabled_features && !enable {
			return error('feature "$feature_name" is already disabled')
		} else if feature_val in ls.enabled_features && enable {
			return error('feature "$feature_name" is already enabled')
		} else if feature_val !in ls.enabled_features && enable {
			ls.enabled_features << feature_val
		} else {
			mut idx := -1
			for i, f in ls.enabled_features {
				if f == feature_val {
					idx = i
					break
				}
			}
			ls.enabled_features.delete(idx)
		}
	}
}

fn (mut ls Pls) send<T>(data T) {
	str := json.encode(data)
	ls.logger.response(str, .send)
	ls.io.send(str)
	// See line 113 for the explanation
	ls.logger.response(str, .receive)
}

fn (mut ls Pls) notify<T>(data T) {
	str := json.encode(data)
	ls.logger.notification(str, .send)
	ls.io.send(str)
	// See line 113 for the explanation
	ls.logger.notification(str, .receive)
}

// send_null sends a null result to the client
fn (mut ls Pls) send_null(id int) {
	str := '{"jsonrpc":"2.0","id":$id,"result":null}'
	ls.logger.response(str, .send)
	ls.io.send(str)
	ls.logger.response(str, .receive)
}

fn (mut ls Pls) free_table(uri string) {
	if uri in ls.tables {
		unsafe {
			ls.tables[uri].free()
		}
		ls.tables.delete(uri)
	}
}

// table_panic_handler handles the error behavior of the table. replaces panic.
fn table_panic_handler(t &ast.Table, message string) {
	mut ls := &Pls(t.panic_userdata)
	ls.panic(message)
}

// panic generates a log report and exits the language server.
fn (mut ls Pls) panic(message string) {
	ls.panic_count++

	// NB: Would 2 be enough to exit? 
	if ls.panic_count == 2 {
		log_path := ls.log_path()
		ls.logger.set_logpath(log_path)
		ls.show_message(
			'PLS Panic: ${message}. Log saved to ${os.real_path(log_path)}.', 
			.error,
		)
		ls.logger.close()
		ls.exit()
	} else {
		ls.log_message('PLS: An error occurred. Message: $message', .error)
	}
}

[inline]
fn new_error(code int) jsonrpc.Response2<string> {
	return jsonrpc.Response2<string>{
		error: jsonrpc.new_response_error(code)
	}
}