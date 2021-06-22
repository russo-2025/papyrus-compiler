module lsp

import os
import net.urllib

type DocumentUri = string

pub fn (du DocumentUri) dir() string {
	return os.dir(du)
}

pub fn (du DocumentUri) path() string {
	mut p := if du.starts_with('file://') { du.all_after('file://') } else { '' }
	
	if p.starts_with('/') {
		p = p.all_after('/')
	}

	p = urllib.path_unescape(p) or { p }

	return p
}

pub fn document_uri_from_path(path string) DocumentUri {
	return if !path.starts_with('file://') { 'file://' + path } else { path }
}

pub struct NotificationMessage {
	method string
	params string [raw]
}

// // method: $/cancelRequest
pub struct CancelParams {
	id int
}

pub struct Command {
	title     string
	command   string
	arguments []string
}

pub struct DocumentFilter {
	language string
	scheme   string
	pattern  string
}

pub struct TextDocumentRegistrationOptions {
	document_selector []DocumentFilter [json: documentSelector]
}
