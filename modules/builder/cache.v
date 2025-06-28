module builder

import os

import pref
import papyrus.ast
import papyrus.util

struct CacheFile {
pub mut:
	last_mod_time	i64
}

fn read_cache(path string) &CacheFile {
	mut file := os.open(path) or {
		util.fatal_error("failed to open file: ${err}")
	}

	mut cache := CacheFile{}
	file.read_struct(mut cache) or {
		util.fatal_error("failed to read file: ${err}")
	}
	file.close()
	return &cache
}

fn write_cache(path string, cache &CacheFile) {
	mut file := os.create(path) or {
		util.fatal_error("failed to create file: ${err}")
	}

	file.write_struct(cache) or {
		util.fatal_error("failed to write file: ${err}")
	}

	file.close()
}

fn is_outdated(pfile &ast.File, prefs &pref.Preferences) bool {
	if prefs.no_cache {
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