module pref

import os
import papyrus.errors

pub enum OutputMode {
	stdout
	silent
}

pub enum Backend {
	pex
	check
	original // use a vanilla compiler to compile files
}

pub enum RunMode {
	compile
	read
	disassembly
	create_dump
	help
}

@[heap]
pub struct Preferences {
pub mut:
	paths				[]string	// folders with files to compile
	output_dir			string		// folder for output files
	mode				RunMode = .compile
	backend				Backend = .pex
	no_cache			bool
	header_dirs			[]string = []
	output_mode			OutputMode = .stdout
	is_verbose			bool
	use_threads			bool
	stats_enabled		bool
}

fn (mut p Preferences) parse_compile_args(args []string) {
	p.mode = .compile
	p.backend = .pex

	if args.len < 3  {
		error("invalid number of arguments") // TODO???
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

					if !os.is_dir(path) && (!os.is_file(path) || os.file_ext(path).to_lower() != ".psc") {
						error(errors.msg_invalid_input_path) // path
					}

					if path in p.paths {
						error(errors.msg_duplicate_input_flag) // path
					}

					p.paths << path

					i++
				}
			}
			"-o",
			"-output" {
				i++

				if p.output_dir != "" {
					error(errors.msg_duplicate_output_flag) // path
				}

				path := os.real_path(args[i])

				if !os.is_dir(path) {
					error(errors.msg_invalid_output_path) // path
				}

				p.output_dir = path
				i++
			}
			"-h",
			"-headers-dir" {
				i++
				
				path := os.real_path(args[i])

				if !os.is_dir(path) {
					error(errors.msg_invalid_headers_path) // path
				}
				
				p.header_dirs << path
				i++
			}
			"-check" {
				p.backend = .check
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
			"-stats" {
				p.stats_enabled = true
				i++
			}
			else {
				error(errors.msg_missing_or_incorrect_argument) // args[i]
			}
		}
	}

	if p.paths.len <= 0 {
		error(errors.msg_missing_input)
	}

	if p.output_dir == "" {
		error(errors.msg_missing_output)
	}
}

pub fn parse_args() Preferences {
	mut p := Preferences{}

	args := os.args[1..]

	if args.len == 0 {
		p.mode = .help
		return p
	}

	match args[0] {
		"help" {
			p.mode = .help
		}
		"compile" {
			p.mode = .compile
			p.parse_compile_args(args[1..])
		}
		"read" {
			if args.len < 2 {
				error(errors.msg_wrong_number_of_arguments)
			}

			p.mode = .read
			
			path := os.real_path(args[1])

			if !os.is_file(path) || os.file_ext(path).to_lower() != ".pex" {
				error(errors.msg_invalid_path_read) //
			}

			p.paths << path
		}
		"disassembly" {
			if args.len < 2 {
				error(errors.msg_wrong_number_of_arguments)
			}

			p.mode = .disassembly
			
			path := os.real_path(args[1])

			if !os.is_file(path) || os.file_ext(path).to_lower() != ".pex" {
				error(errors.msg_invalid_path_disassembly) //
			}

			p.paths << path
		}
		"create-dump" {
			if args.len < 2 {
				error(errors.msg_wrong_number_of_arguments)
			}

			p.mode = .create_dump
			
			path := os.real_path(args[1])

			if !os.is_dir(path) {
				error(errors.msg_invalid_path_create_dump) //
			}

			p.paths << path
		}
		else {
			if args[0].starts_with("-") {
				p.mode = .compile
				p.parse_compile_args(args)
			}
			else {
				error(errors.msg_missing_or_incorrect_command) // args[0]
			}
		}
	}

	return p
}

@[noreturn]
fn error(msg string) {
	eprintln(msg)
	eprintln("Use \"papyrus help\" for more information.")
	exit(1)
}

@[noreturn]
pub fn print_help_info() {
	println(msg_help_command)
	exit(0)
}

const msg_help_command = 'papyrus compiler help

Usage:
  papyrus <command> [arguments]

Commands:
  compile       Compiles files with the `.psc` extension into the binary `.pex` format.
  read          Reads and disassembles a `.pex` file, outputting its contents in a human-readable format to the console.
  disassembly   Reads and disassembles a `.pex` file, saving its contents in a human-readable format to a text file.
  create-dump   Creates a `dump.json` file containing information about `.pex` files located in the specified directory.
  help          Displays a list of available commands and their descriptions.

Arguments for the "compile" command:
  -i, -input        Specify the directory with .psc files or a .psc file to compile.
  -o, -output       Specify the directory where the compiled .pex files will be placed.
  -h, -headers-dir  Specify the directory with .psc header/import files that will be analyzed by the compiler but not compiled.
  -nocache          Ignore the cache and force compilation of all files.
  -original         Use the original Papyrus compiler for compilation.
  -stats            Save statistics on compiled files to .md files (number of function calls, inheritances, files).
  -check            Check the syntax of .psc files without generating .pex files.

Examples:
  Compile all scripts in a directory, ignoring the cache:
    papyrus compile -nocache -i "D:\\Steam\\steamapps\\common\\Skyrim Special Edition\\Data\\Scripts\\Source" -o "../test-files/compiled/skyrimSources"

  Compile all scripts in a directory:
    papyrus compile -i "../../RH-workspace/scripts" -o "../../RH-workspace/compiled"

  Compile scripts using header/import files:
    papyrus compile -nocache -h "D:\\Steam\\steamapps\\common\\Skyrim Special Edition\\Data\\Scripts\\Source" -i "../test-files/compiler" -o "../test-files/compiled"

  Read a compiled .pex file:
    papyrus read "../test-files/compiled/ABCD.pex"

  Create a JSON dump of .pex files:
    papyrus create-dump "../folder_with_pex_files"'