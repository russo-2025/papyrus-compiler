module pref

import os

const (
	builtin_path = os.real_path('./builtin')
)

pub enum Backend {
	pex
	original
}

pub enum RunMode {
	compile
	read
}

[heap]
pub struct Preferences {
pub mut:
	paths				[]string	//папки с файлами для компиляции
	out_dir				[]string	//папки для результата
	mode				RunMode = .compile
	backend				Backend = .pex
	no_cache			bool
	crutches_enabled	bool
	builtin_path		string = builtin_path
}

fn (mut p Preferences) parse_compile_args(args []string) {
	p.mode = .compile
	p.backend = .pex

	if args.len < 3  {
		error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
	}

	mut i := 1

	for i < args.len {
		match args[i] {
			"-i",
			"-input" {
				i++
				
				for i < args.len {
					if args[i].starts_with("-") {
						i--
						break
					}

					path := os.real_path(args[i])
					
					if !os.is_dir(path) {
						error("invalid input path: '$path'")
					}

					if path in p.paths {
						error("path already exists: '$path'")
					}

					p.paths << path

					i++
				}
			}
			"-o",
			"-output" {
				i++
				
				for i < args.len {
					if args[i].starts_with("-") {
						i--
						break
					}

					path := os.real_path(args[i])

					if !os.is_dir(path) {
						error("invalid output path: '$path'")
					}

					if path in p.out_dir {
						error("path already exists: '$path'")
					}

					p.out_dir << path

					i++
				}
			}
			"-nocache" {
				p.no_cache = true
			}
			"-crutches" {
				p.crutches_enabled = true
			}
			"-original" {
				p.backend = .original
			}
			else {
				error("invalid argument `${args[i]}`")
			}
		}

		i++
	}
}

pub fn parse_args() Preferences {
	
	mut p := Preferences{}

	if os.args.len <= 1 {
		error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
	}

	args := os.args[1..]

	match args[0] {
		"-compile" {
			p.mode = .compile
			p.parse_compile_args(args)
		}
		"-read" {
			if args.len < 2 {
				error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
			}

			p.mode = .read
			p.paths << os.real_path(args[1])
		}
		else {
			error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
		}
	}

	return p
}

pub fn should_compile_filtered_files(dir string, files_ []string) []string {
	mut files := files_.clone()
	files.sort()

	mut all_v_files := []string{}

	for file in files {
		if !file.ends_with('.psc') {
			continue
		}

		all_v_files << os.join_path(dir, os.file_name(file))
	}

	return all_v_files
}

fn error(msg string) {
	eprintln(msg)
	eprintln("papyrus.exe -compile <input-path> <output-path>")
	exit(1)
}