module builder

import os

import pref
import papyrus.ast

struct CacheFile {
pub mut:
	last_mod_time	int
}

fn read_cache(path string) &CacheFile {
	mut file := os.open(path) or { panic(err) }
	mut cache := CacheFile{}
	file.read_struct(cache) or { panic(err) }
	file.close()
	return &cache
}

fn write_cache(path string, cache &CacheFile) {
	mut file := os.create(path) or { panic(err) }
	file.write_struct(cache) or { panic(err) }
	file.close()
}

fn is_outdated(pfile &ast.File, pref &pref.Preferences) bool {
	if pref.no_cache {
		return true
	}
	
	path := os.join_path(cache_path, pfile.file_name + ".obj")
	
	if os.is_file(path) {
		mut cache := read_cache(path)
		
		if cache.last_mod_time == pfile.last_mod_time {
			return false
		}
		else {
			cache.last_mod_time = pfile.last_mod_time
			write_cache(path, cache)
			return true
		}
	}
	else {
		mut cache := CacheFile{}
		cache.last_mod_time = pfile.last_mod_time
		write_cache(path, cache)
		return true
	}
}