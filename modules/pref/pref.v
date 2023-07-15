module pref

import os

pub enum OutputMode {
	stdout
	silent
}

pub enum Backend {
	pex
	original // use a vanilla compiler to compile files
}

pub enum RunMode {
	compile
	read
	disassembly
	create_dump
}

[heap]
pub struct Preferences {
pub mut:
	paths				[]string	// folders with files to compile
	output_dir			string		// folder for output files
	mode				RunMode = .compile
	backend				Backend = .pex
	no_cache			bool
	papyrus_headers_dir	string = os.real_path('./papyrus-headers')
	output_mode			OutputMode = .stdout
	is_verbose			bool
	use_threads			bool
}

fn (mut p Preferences) parse_compile_args(args []string) {
	p.mode = .compile
	p.backend = .pex

	if args.len < 3  {
		error("invalid number of arguments")
	}

	mut i := 0

	for i < args.len {
		match args[i] {
			"-i",
			"-input" {
				i++
				
				for i < args.len {
					if args[i].starts_with("-") {
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

				if p.output_dir != "" {
					error("output folder is already specified")
				}

				path := os.real_path(args[i])

				if !os.is_dir(path) {
					error("invalid output dir: '$path'")
				}

				p.output_dir = path
				i++
			}
			"-h",
			"-headers-dir" {
				i++
				
				path := os.real_path(args[i])

				if !os.is_dir(path) {
					error("invalid headers dir: '$path'")
				}

				p.papyrus_headers_dir = path
				i++
			}
			"-nocache" {
				p.no_cache = true
				i++
			}
			"-original" {
				p.backend = .original
				i++
			}
			"-verbose" {
				p.is_verbose = true
				i++
			}
			"-use-threads" {
				p.use_threads = true
				i++
			}
			"-silent" {
				p.output_mode = .silent
				i++
			}
			else {
				error("invalid argument `${args[i]}`")
			}
		}
	}
}

pub fn parse_args() Preferences {
	mut p := Preferences{}

	args := os.args[1..]

	if args.len == 0 {
		help()
		exit(0)
	}

	match args[0] {
		"help" {
			if args.len > 1 {
				if args[1] == "compile" || args[1] == "read" {
					help_command(args[1])
				}
			}

			help()
		}
		"-compile", // outdated
		"compile" {
			p.mode = .compile
			p.parse_compile_args(args[1..])
		}
		"read" {
			if args.len < 2 {
				error("invalid number of arguments")
			}

			p.mode = .read
			p.paths << os.real_path(args[1])
		}
		"disassembly" {
			if args.len < 2 {
				error("invalid number of arguments")
			}

			p.mode = .disassembly
			p.paths << os.real_path(args[1])
		}
		"create-dump" {
			if args.len < 2 {
				error("invalid number of arguments")
			}

			p.mode = .create_dump
			p.paths << os.real_path(args[1])
		}
		else {
			if args[0].starts_with("-") {
				p.mode = .compile
				p.parse_compile_args(args)
			}
			else {
				error("unknown command: `${args[0]}`")
			}
		}
	}

	return p
}

fn error(msg string) {
	eprintln(msg)
	exit(1)
}

fn help() {
	println("Papyrus language compiler")
	println("")
	println("Usage:")
	println("")
	println("	papyrus <command> [arguments]")
	println("")
	println("The commands are:")
	println("")
	println("		compile")
	println("			compile papyrus files")
	println("")
	println("		read")
	println("			converts pex file into a readable format and outputs it to console")
	println("")
	println("		disassembly")
	println("			converts pex file into a readable format and writes result to file")
	println("")
	println("		create-dump")
	println("			...")
	println("")
	println("")
	println("Use \"papyrus help <command>\" for more information about a command.")
	exit(0)
}

fn help_command(command string) {
	match command {
		"compile" {
			println("Arguments:")
			println("")
			println("		-i")
			println("			folder with files(*.psc) to compile")
			println("")
			println("		-o")
			println("			folder for compiled files(*.pex)")
			println("")
			println("		-h")
			println("			folder with header files")
			println("")
			println("		-nocache")
			println("			compile all files, regardless of the modification date")
			println("")
			println("		-original")
			println("			compile using a vanilla compiler")
			println("")
			println("		-silent")
			println("			disable output of messages and errors to console")
			println("")
			println("		-verbose")
			println("			...")
			println("")
			println("		-use-threads")
			println("			use threads to generate files")
			println("")
		}
		"read" {
			println("")
			println("papyrus read \"path/to/file.pex\"")
		}
		"disassembly" {
			println("")
			println("papyrus disassembly \"path/to/file.pex\"")
		}
		else {
		}
	}

	exit(0)
}