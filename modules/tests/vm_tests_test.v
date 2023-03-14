import builder
import os
import pref

const (
	prefs = pref.Preferences {
		paths: [ os.real_path('test-files/vm-tests') ]
		output_dir: os.real_path('test-files/compiled')
		mode: .compile
		backend: .pex
		no_cache: true
		crutches_enabled: false
		papyrus_headers_dir: os.real_path('bin/papyrus-headers')
		output_mode: pref.OutputMode.silent
	}
)

fn test_builder() {
	if !os.is_dir(prefs.output_dir) {
		os.mkdir(prefs.output_dir, os.MkdirParams{}) or { panic(err) }
	}

	builder.compile(prefs)
}