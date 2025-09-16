module tests

import os
import pref
import builder

fn test_project_ostim() {
	input_dir := os.real_path(os.join_path("modules", "tests", "OStimSources"))
	output_dir := os.real_path(os.join_path("test-files", "compiled", "OStim"))
	header_dir := os.real_path(os.join_path("modules", "tests", "psc_deps"))
	papyrus_util_dir := os.real_path(os.join_path("modules", "tests", "PapyrusUtilSources"))

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "OStimAddon.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(header_dir) || !os.is_file(os.join_path(header_dir, "Form.psc")) {
		assert false, "invalid header dir ${header_dir}"
	}

	if !os.is_dir(papyrus_util_dir) || !os.is_file(os.join_path(papyrus_util_dir, "PapyrusUtil.psc")) {
		assert false, "invalid papyrus util dir ${papyrus_util_dir}"
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
		header_dirs: [ header_dir, papyrus_util_dir ]
	}

	builder.compile(&prefs)
}