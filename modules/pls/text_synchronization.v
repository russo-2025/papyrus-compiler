module pls

import json
import os
import papyrus.parser
//import papyrus.checker
//import papyrus.ast
import pref
import lsp

fn (mut ls Pls) did_change_watched_files(_ int, json_params string) {
	params := json.decode(lsp.DidChangeWatchedFilesParams, json_params) or { 
		ls.panic(err.msg)
		return
	}
	
	for change in params.changes {
		match change.@type {
			1 {
				//проверить находится ли файл в input_dirs
				path := change.uri.path()
				name := os.file_name(path).all_before_last(".psc").to_lower()
				ls.scripts[name] = path
			}
			3 {
				name := os.file_name(change.uri.path()).all_before_last(".psc").to_lower()
				ls.scripts.delete(name)
			}
			else {
				ls.log_message('invalid change type: `${change.@type}`', .warning)
			}
		}
	}
}

fn (mut ls Pls) did_open(_ int, json_params string) {
	did_open_params := json.decode(lsp.DidOpenTextDocumentParams, json_params) or { 
		ls.panic(err.msg)
		return
	}

	if did_open_params.text_document.uri !in ls.files {
		ls.process_file(
			did_open_params.text_document.text, 
			did_open_params.text_document.uri,
		)
	}
}

[manualfree]
fn (mut ls Pls) did_change(_ int, json_params string) {
	did_change_params := json.decode(lsp.DidChangeTextDocumentParams, json_params) or {
		ls.panic(err.msg)
		return
	}
	source := did_change_params.content_changes[0].text
	uri := did_change_params.text_document.uri
	unsafe { ls.sources[uri.str()].free() }
	ls.process_file(source, uri)
}

[manualfree]
fn (mut ls Pls) did_close(_ int, json_params string) {
	params := json.decode(lsp.DidCloseTextDocumentParams, json_params) or { 
		ls.panic(err.msg)
		return
	}

	uri := params.text_document.uri

	unsafe {
		ls.sources[uri].free()
		ls.files[uri].free()
	}
	
	ls.sources.delete(uri)
	ls.files.delete(uri)
	ls.free_table(uri)
}

[manualfree]
fn (mut ls Pls) process_file(source string, uri lsp.DocumentUri) {
	//ls.files[uri].free()
	ls.sources[uri.str()] = source.bytes()
	scope, mut pref := new_scope_and_pref()
	
	pref.paths = ls.input_dirs.clone()
	pref.out_dir = [ ls.root_uri.path() ]

	//ls.free_table(uri)
	table := ls.new_table()
	
	//парсим файл
	pfile := parser.parse_text(source, uri.path(), table, pref, scope)
	//ls.files[uri].free()
	ls.files[uri.str()] = pfile
	
	//ищем импорты
	mut import_scripts := []string{}

	//сначала в таблице типов
	for sym in table.types {
		if sym.kind == .placeholder {
			lname := sym.name.to_lower()
			if lname in ls.scripts {
				import_scripts << ls.scripts[lname]
			}
		}
	}

	//и в среди используемых идентификаторов
	for ident in pfile.used_indents {
		lname := ident.to_lower()
		if lname in ls.scripts {
			import_scripts << ls.scripts[lname]
		}
	}

	ls.log_message('import_scripts: ${import_scripts.str()}', .info)
	parsed_imports := parser.parse_files(import_scripts, table, pref, scope)

	ls.tables[uri.str()] = table
	
	unsafe {
		import_scripts.free()
		parsed_imports.free()
		source.free()
		pref.paths.free()
		pref.out_dir.free()
	}
}

fn (mut ls Pls) update_scripts() {
	for dir in ls.input_dirs {
		paths := pref.should_compile_filtered_files(dir, os.walk_ext(dir, ".psc"))

		for path in paths {
			name := os.file_name(path).all_before_last(".psc").to_lower()
			ls.scripts[name] = path
		}
	}
}