module pref

import os

enum Mods {
	compile
	read
	compilebuiltin
}

pub struct Preferences {
pub mut:
	paths		[]string	//папки для компиляции
	out_dir		[]string	//куда помпилировать
	mode		Mods
	no_cache	bool
}

fn (mut p Preferences) parse_compile_args(args []string) {
	if args.len < 3  {
		error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
	}
	
	p.mode = .compile
	mut i := 1

	if  args[i] == "-nocache" {
		p.no_cache = true
		i++
	}

	if  args[i] == "-input" {
		i++
		
		for i < args.len {
			path := args[i]

			if !os.is_dir(path) {
				error("invalid input path: '$path'")
			}

			p.paths << path

			i++
			if args[i] == "-output" {
				break
			}
		}
	}
	else {
		error("err -input")
	}

	if  args[i] == "-output" {
		i++
		
		for i < args.len {
			if args[i].starts_with("-") {
				break
			}

			path := args[i]

			if !os.is_dir(path) {
				error("invalid output path: '$path'")
			}

			p.out_dir << path

			i++
		}
	}
	else {
		error("err -output")
	}
}

pub fn parse_args() Preferences {
	
	mut p := Preferences{}

	args := os.args[1..]

	match args[0] {
		"-compile" {
			p.parse_compile_args(args)
		}
		"-read" {
			if args.len < 2 {
				error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
			}
			p.mode = .read

			if !os.is_file(args[1]) {
				error("invalid file path: '${args[1]}'")
			}

			p.paths << args[1]
		}
		"-compile-builtin" {
			if args.len < 3 {
				error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
			}
			p.mode = .compilebuiltin

			if os.is_dir(args[1]) {
				p.paths << args[1]
			}
			else {
				error("invalid input path: '${args[1]}'")
			}

			if os.is_dir(args[2]) {
				p.out_dir << args[2]
			}
			else {
				error("invalid output path: '${args[2]}'")
			}
		}
		else {
			error("invalid arguments.\npapyrus.exe -compile <input-path> <output-path>")
		}
	}

	return p
}

fn error(msg string) {
	eprintln(msg)
	eprintln("papyrus.exe -compile <input-path> <output-path>")
	exit(1)
}