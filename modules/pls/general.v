module pls

import json
import os
import runtime
import v.vmod

import lsp
import jsonrpc

const (
	completion_trigger_characters       = ['=', '.', ':', '{', ',', '(', ' ']
	signature_help_trigger_characters   = ['(']
	signature_help_retrigger_characters = [',', ' ']
)

struct ProjectConfig {
	input []string
	output []string
}

fn (mut ls Pls) initialize(id int, params string) {
	// NB: Just to be sure just in case the panic happens
	// inside the base table.
	ls.base_table.panic_handler = table_panic_handler
	ls.base_table.panic_userdata = ls

	initialize_params := json.decode(lsp.InitializeParams, params) or {
		ls.panic(err.msg)
		ls.send_null(id)
		return
	}
	
	// TODO: configure capabilities based on client support
	// ls.client_capabilities = initialize_params.capabilities
	ls.capabilities = lsp.ServerCapabilities{
		text_document_sync: 1
		completion_provider: lsp.CompletionOptions{
			resolve_provider: false
		}
		workspace_symbol_provider: Feature.workspace_symbol in ls.enabled_features
		document_symbol_provider: Feature.document_symbol in ls.enabled_features
		document_formatting_provider: Feature.formatting in ls.enabled_features
		hover_provider: Feature.hover in ls.enabled_features
		folding_range_provider: Feature.folding_range in ls.enabled_features
		definition_provider: Feature.definition in ls.enabled_features
	}

	if Feature.completion in ls.enabled_features {
		ls.capabilities.completion_provider.trigger_characters = completion_trigger_characters
	}

	if Feature.signature_help in ls.enabled_features {
		ls.capabilities.signature_help_provider = lsp.SignatureHelpOptions{
			trigger_characters: signature_help_trigger_characters
			retrigger_characters: signature_help_retrigger_characters
		}
	}

	result := jsonrpc.Response<lsp.InitializeResult>{
		id: id
		result: lsp.InitializeResult{
			capabilities: ls.capabilities
		}
	}

	// only files are supported right now
	ls.root_uri = initialize_params.root_uri

	// set up logger set to the workspace path
	ls.setup_logger(initialize_params.trace, initialize_params.client_info)

	ls.send(result)
}

fn (mut ls Pls) initialized() {
	ls.log_message('Root path: `${ls.root_uri.path()}`', .info)
	ls.status = .initialized
	ls.load_project_file()
	ls.update_scripts()
}

fn (mut ls Pls) load_project_file() {
	json_cfg := os.read_file(os.join_path(ls.root_uri.path(), "papyrus-project.json")) or { panic(err.msg) } // =(
	cfg := json.decode(ProjectConfig, json_cfg) or { panic(err.msg) }
	ls.input_dirs = cfg.input
	ls.input_dirs << builtin_path
}

fn (mut ls Pls) setup_logger(trace string, client_info lsp.ClientInfo) {
	meta := vmod.decode(@VMOD_FILE) or { vmod.Manifest{} }
	mut arch := 32
	if runtime.is_64bit() {
		arch += 32
	}

	// Create the file either in debug mode or when the client trace is set to verbose.
	if ls.debug || (!ls.debug && trace == 'verbose') {
		ls.log_message('Log path: `${ls.log_path()}`', .info)
		log_path := ls.log_path()
		os.rm(log_path) or {}
		ls.logger.set_logpath(log_path)
	}
	
	// print important info for reporting
	ls.log_message('PLS Version: $meta.version, OS: $os.user_os() $arch', .info)
	if client_info.name.len != 0 {
		ls.log_message('Client / Editor: $client_info.name $client_info.version', .info)
	} else {
		ls.log_message('Client / Editor: Unknown', .info)
	}
}

// exit stops the process
fn (mut ls Pls) exit() {
	// saves the log into the disk
	ls.logger.close()

	// move exit to shutdown for now
	// == .shutdown => 0
	// != .shutdown => 1
	unsafe {
		for key, _ in ls.tables {
			ls.free_table(key)
		}
		
		ls.base_table.free()
	}
	exit(int(ls.status != .shutdown))
}