import builder
import os
import pref
import pex

fn test_builder() {
	input_dir := os.real_path('test-files/vm-tests')
	output_dir := os.real_path('test-files/compiled')

	file1 := os.join_path(input_dir, "AAATestObject.psc")
	file2 := os.join_path(input_dir, "LatentTest.psc")
	file3 := os.join_path(input_dir, "OpcodesTest.psc")

	if !os.is_file(file1) || !os.is_file(file2) || !os.is_file(file3) {
		assert false, "invalid input files ${file1}, ${file2}, ${file3}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create a folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .pex
		no_cache: true
		crutches_enabled: false
		papyrus_headers_dir: os.real_path('bin/papyrus-headers')
		output_mode: pref.OutputMode.silent
	}

	out_file1 := os.join_path(prefs.output_dir, "AAATestObject.pex")
	out_file2 := os.join_path(prefs.output_dir, "LatentTest.pex")
	out_file3 := os.join_path(prefs.output_dir, "OpcodesTest.pex")

	if os.is_file(out_file1) {
		os.rm(out_file1) or { assert false, "failed to delete file" }
	}
	if os.is_file(out_file2) {
		os.rm(out_file2) or { assert false, "failed to delete file" }
	}
	if os.is_file(out_file3) {
		os.rm(out_file3) or { assert false, "failed to delete file" }
	}

	builder.compile(prefs)

	pex.read_from_file(out_file1)
	pex.read_from_file(out_file2)
	pex.read_from_file(out_file3)
}