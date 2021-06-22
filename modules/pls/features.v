module pls

import json

import lsp

fn (mut ls Pls) completion(id int, params string) {
	if Feature.completion !in ls.enabled_features {
		return
	}
	/*completion_params := */json.decode(lsp.CompletionParams, params) or { 
		ls.panic(err.msg)
		ls.send_null(id)
		return
	}

	ls.log_message('completion params: `$params`', .info)
}