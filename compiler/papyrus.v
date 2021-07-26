module main

import time
import builder
import pref
import pex

/*
не работает:
	- вызов функций с заданными через равно опциональными параметрами. ac.EquipItem(tool, abSilent = true)
	- keyword parent
	- object states
*/

fn main() {

	prefs := pref.parse_args()

	mut sw := time.new_stopwatch({})
	sw.start()

	match prefs.mode {
		.compile_original {
			builder.compile_original(prefs)
		}
		.compile {
			builder.compile(prefs)
		}
		.read {
			pex.read(prefs)
		}
	}

	ms := f32(sw.elapsed().microseconds()) / 1000
	println('finish $ms ms')
}