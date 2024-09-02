module tests

import os
import pref
import builder

fn test_selective_headers_loading() {
	src_file := os.real_path('modules/tests/psc/TestSelectiveLoading.psc')
	output_dir := os.real_path('test-files/compiled')

	if !os.is_file(src_file) {
		assert false, "invalid input file ${src_file}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create a folder" }
	}

	prefs := pref.Preferences {
		paths: [ src_file ]
		output_dir: output_dir
		mode: .compile
		backend: .check
		no_cache: true
		header_dirs: [ os.real_path('bin/papyrus-headers') ]
		//output_mode: pref.OutputMode.silent
	}

	builder.compile(&prefs)
}