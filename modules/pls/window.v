module pls

import lsp
import jsonrpc

// log_message sends a window/logMessage notification to the client
fn (mut ls Pls) log_message(message string, typ lsp.MessageType) {
	ls.notify(jsonrpc.NotificationMessage<lsp.LogMessageParams>{
		method: 'window/logMessage'
		params: lsp.LogMessageParams{
			@type: typ
			message: message
		}
	})
}

// show_message sends a window/showMessage notification to the client
fn (mut ls Pls) show_message(message string, typ lsp.MessageType) {
	ls.notify(jsonrpc.NotificationMessage<lsp.ShowMessageParams>{
		method: 'window/showMessage'
		params: lsp.ShowMessageParams{
			@type: typ
			message: message
		}
	})
}