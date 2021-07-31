module builder

import os

import pref

const (
	builtin_path = os.real_path('./builtin')
	cache_path = os.real_path('./.papyrus')
	compiler_exe_path = os.real_path('./Original Compiler/PapyrusCompiler.exe')
	compiler_flags_path = os.real_path('./Original Compiler/TESV_Papyrus_Flags.flg')
)

pub fn compile(pref &pref.Preferences) {
	if pref.backend == .original {
		compile_original(pref)
		return
	}

	match pref.backend {
		.pex {
			compile_pex(pref)
		}
		else {}
	}
}

fn get_all_src_files(paths []string) []string {
	mut files := []string{}

	for path in paths {
		files << os.walk_ext(path, ".psc")
	}

	return files
}