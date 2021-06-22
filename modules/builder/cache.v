module builder 

import os
import papyrus.ast

struct CacheFile {
pub mut:
	last_mod_time	int
}

fn (mut b Builder) is_outdated(pfile &ast.File) bool {
	if b.pref.no_cache {
		return true
	}
	
	dir := os.dir(os.args[0]) + "//.papyrus//"
	path := dir + pfile.file_name + ".obj"
	
	if os.is_file(path) {
		mut file := os.open(path) or { panic(err) }
		mut cache := CacheFile{}
		file.read_struct(cache) or { panic(err) }
		file.close()
		
		if cache.last_mod_time == pfile.last_mod_time {
			return false
		}
		else {
			cache.last_mod_time = pfile.last_mod_time
			file = os.create(path) or { panic(err) }
			file.write_struct(cache) or { panic(err) }
			file.close()
			return true
		}
	}
	else {
		mut cache := CacheFile{}
		cache.last_mod_time = pfile.last_mod_time
		mut file := os.create(path) or { panic(err) }
		file.write_struct(cache) or { panic(err) }
		file.close()
		return true
	}
}