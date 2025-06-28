module main

import time
import os
import json
import builder
import pref
import pex
import papyrus.util

//#flag -lucrtd

fn main() {
	prefs := pref.parse_args()
	
	mut sw := time.new_stopwatch()
	sw.start()

	match prefs.mode {
		.version {
			info := util.collect_info()
			println("Version: ${info.version}")
			println("Commit:  ${info.git_commit}")
			println("Build date:  ${info.build_date}")
			println("Build type:  ${info.build_type}")
			println("Repository: https://github.com/russo-2025/papyrus-compiler")
			exit(0)
		}
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
			output_file_name := prefs.paths[0] + ".txt"
			os.write_file(output_file_name, pex_file.str()) or {
				util.fatal_error("ERROR: failed to write file ${output_file_name}; ${err}")
			}
		}
		.create_dump {
			dump_objects := pex.create_dump_from_pex_dir(prefs.paths[0])
			json_data := json.encode_pretty(dump_objects)
			output_file_name := os.real_path("dump.json")
			os.write_file(output_file_name, json_data) or {
				util.fatal_error("ERROR: failed to write file ${output_file_name}; ${err}")
			}
		}
		.help {
			pref.print_help_info()
		}
	}

	ms := f32(sw.elapsed().microseconds()) / 1000
	println('finish $ms ms')
}