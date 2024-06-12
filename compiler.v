module main

import time
import os
import json
import builder
import pref
import pex

//#flag -lucrtd

fn main() {
	prefs := pref.parse_args()

	mut sw := time.new_stopwatch()
	sw.start()

	match prefs.mode {
		.compile {
			builder.compile(prefs)
		}
		.read {
			println("read file: `${prefs.paths[0]}`")
			pex_file := pex.read_from_file(prefs.paths[0])
			println(pex_file.str())
		}
		.disassembly {
			println("disassembly file: `${prefs.paths[0]}` ")
			pex_file := pex.read_from_file(prefs.paths[0])
			os.write_file(prefs.paths[0] + ".txt", pex_file.str()) or { panic(err) }
		}
		.create_dump {
			dump_objects := pex.create_dump_from_pex_dir(prefs.paths[0])
			json_data := json.encode_pretty(dump_objects)
			os.write_file(os.real_path("dump.json"), json_data) or { panic(err) }
		}
	}

	ms := f32(sw.elapsed().microseconds()) / 1000
	println('finish $ms ms')
}