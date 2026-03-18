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
		cmd := '"${compiler_exe_path}" "${file}" -quiet -i="${header_dirs}" -o="${b.pref.output_dirs[0]}" -f="${compiler_flags_path}"'
		
		b.print("executing: `${cmd}`")
		
		res := unsafe { os.raw_execute(cmd) }
		
		if res.exit_code == 0 {
			b.print('successfully - ${file}')
		}
		else {
			b.print('failed - ${file}')
			b.print('console output:')
			b.print(res.output)
		}
	}
}