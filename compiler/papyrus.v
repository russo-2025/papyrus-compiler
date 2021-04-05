module main

import time
import builder
import pref
import pex

/*
не работает:
	- вызов функций с заданными через равно опциональными параметрами. ac.EquipItem(tool, abSilent = true)
	- keyword parent
	- states
	- properties
*/

fn main() {
	prefs := pref.parse_args()

	mut sw := time.new_stopwatch({})
	sw.start()

	match prefs.mode {
		.compile {
			builder.compile(prefs)
		}
		.read {
			pex.read(prefs.paths[0])
		}
		.compilebuiltin {
			builder.compile_builtin_files(prefs)
		}
	}

	ms := f32(sw.elapsed().microseconds()) / 1000
	println('finish $ms ms')
}