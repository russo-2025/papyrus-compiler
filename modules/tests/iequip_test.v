module tests

import os
import pref
import builder

fn test_selective_headers_loading() {
	input_dir := os.real_path(os.join_path("modules", "tests", "iEquip"))
	output_dir := os.real_path(os.join_path("test-files", "compiled"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "dubhMonitorEffectScript.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create output folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ header_dir ]
	}

	builder.compile(&prefs)
}