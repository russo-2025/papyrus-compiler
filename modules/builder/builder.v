module builder

import os

import pref

const (
	builtin_path = os.real_path('./builtin')
	cache_path = os.real_path('./.papyrus')
	compiler_exe_path = os.real_path('./Original Compiler/PapyrusCompiler.exe')
	compiler_flags_path = os.real_path('./Original Compiler/TESV_Papyrus_Flags.flg')
)

fn get_all_src_files(paths []string) []string {
	mut files := []string{}

	for path in paths {
		files << os.walk_ext(path, ".psc")
	}

	return files
}

pub fn compile(pref &pref.Preferences) {
	match pref.backend {
		.pex {
			compile_pex(pref)
		}
		.original {
			compile_original(pref)
		}
	}
}