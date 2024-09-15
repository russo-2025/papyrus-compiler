module tests

import os
import pref
import builder

const loaded_objects = ["testselectiveloading", "testselectiveloadingparent", 
	"utility", "objectreference", "game", "form"] // used in src

const placeholder_objects = ["actor", "textureset", "keyword", "magiceffect", 
	"enchantment"] // used in headers

fn test_selective_headers_loading() {
	src_file := os.real_path(os.join_path("modules", "tests", "psc", "TestSelectiveLoading.psc"))
	output_dir := os.real_path(os.join_path("test-files", "compiled"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))

	if !os.is_file(src_file) {
		assert false, "invalid input file ${src_file}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ src_file ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir ]
	}

	mut b := builder.new_builder(&prefs)
	b.run()

	for obj_name in loaded_objects {
		if sym := b.table.find_type(obj_name) {
			assert sym.kind == .script, obj_name
		}
	}

	/*
	// нужно проверить все ли необходимые типы загружены.
	// есть те типы которые могут быть placeholder, но они не нужны??????????????????????????????????????????????
	for obj_name in placeholder_objects {
		if sym := b.table.find_type(obj_name) {
			assert sym.kind == .placeholder, obj_name
		}
	}
	*/
}