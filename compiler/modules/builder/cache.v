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













/*
import papyrus.ast
import os

struct Cache {
	mod_time map[string]int

	file	os.File
}

fn (mut c Cache) set_mod_time(path string, time int) {
	c.mod_time[path] = time
}

fn (mut c Cache) get_mod_time(path string) int {
	return c.mod_time[path]
}

fn (mut c Cache) init() {
	cache_file_path := os.dir(os.args[0]) + "\\cache.obj"
	
	if os.is_file(cache_file_path) {
		c.file = os.open(cache_file_path) or { panic(err) }
	}
	else {
		c.file = os.create(cache_file_path) or { panic(err) }
	}

	c.mod_time = c.file.read_raw<map[string]int>()
}

fn (mut c Cache) save() {

	c.file.write_struct(c.mod_time) or { panic(err) }
	c.file.close()
}
*/








/*
fn (b Builder) save(pfile ast.File) {
	cache_file_path := os.dir(os.args[0]) + "\\cache\\" + pfile.file_name + ".obj"
	/*if os.is_file(cache_file_path) {

	}*/
/*
	println(cache_file_path)
	mut file := os.create(cache_file_path) or { panic(err) }
	file.write_struct(pfile.stmts) or { panic(err) }
	file.close()
*/
}*/