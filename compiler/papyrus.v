module main

import time
import builder
import pref
import pex

// D:\_dev\v_lang\v.exe -cg  run "d:\_projects\papyrus\papyrus.v" 

//-compile-builtin "D:\_projects\papyrus\compiler\builtin" "D:\_projects\papyrus\compiler\modules\p\table"
//-read  "D:\_projects\papyrus\compiler\test-scripts\ABCD.pex"
//-compile -nocache -input "D:\_projects\papyrus\compiler\test-scripts" -output "D:\_projects\papyrus\compiler\test-scripts"
//-compile -nocache -input "D:\_projects\hive-workspace\skymp5-scripts-hive\Source" "D:\_projects\hive-workspace\skymp5-scripts\Source\Scripts" -output "D:\_projects\hive-workspace\skymp-server-lite\data\scripts"

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