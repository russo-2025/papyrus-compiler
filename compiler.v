module main

import time
import builder
import pref
import pex

fn main() {
	prefs := pref.parse_args()

	mut sw := time.new_stopwatch()
	sw.start()

	match prefs.mode {
		.compile {
			builder.compile(prefs)
		}
		.read {
			pex_file := pex.read_from_file(prefs.paths[0])
			pex_file.print()
		}
	}

	ms := f32(sw.elapsed().microseconds()) / 1000
	println('finish $ms ms')
}