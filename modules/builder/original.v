module builder

import os

//https://www.creationkit.com/index.php?title=Papyrus_Compiler_Reference

@[inline]
fn (mut b Builder) compile_original() {
	mut header_dirs := ""

	for path in b.pref.header_dirs {
		header_dirs += '${path}' + ";"
	}

	header_dirs = header_dirs[..header_dirs.len-1]
	
	for file in b.files {
		cmd := '"${compiler_exe_path}" "${file}" -quiet -i="${header_dirs}" -o="${b.pref.output_dir}" -f="${compiler_flags_path}"'
		res := unsafe { os.raw_execute(cmd) }
		
		if res.exit_code == 0 {
			println('successfully - ${file}')
		}
		else {
			println('failed - ${file}')
			println('console output:')
			println(res.output)
		}
	}
}