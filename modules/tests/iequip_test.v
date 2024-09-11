module tests

import os
import pref
import builder

fn test_selective_headers_loading() {
	input_dir := os.real_path('modules/tests/iEquip')
	output_dir := os.real_path('test-files/compiled')

	if !os.is_dir(input_dir) || !os.is_file(os.join_path(input_dir, "dubhMonitorEffectScript.psc")) {
		assert false, "invalid input dir ${input_dir}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create a folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ os.real_path('modules/tests/psc_deps') ]
	}

	builder.compile(&prefs)
}