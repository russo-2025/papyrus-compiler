module builder

import os

const (
	builtin_path = os.real_path('./builtin')
	cache_path = os.real_path('./.papyrus')
	//original compiler files
	compiler_exe_path = os.real_path('./Original Compiler/PapyrusCompiler.exe')
	compiler_flags_path = os.real_path('./Original Compiler/TESV_Papyrus_Flags.flg')
)

pub fn get_all_src_files(paths []string) []string {
	mut files := []string{}

	for path in paths {
		files << os.walk_ext(path, ".psc")
	}

	return files
}