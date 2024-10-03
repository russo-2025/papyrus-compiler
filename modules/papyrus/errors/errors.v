module errors

import papyrus.token

pub enum Reporter {
	scanner
	parser
	checker
	builder
	gen
}

pub struct Error {
pub:
	message   string
	file_path string
	pos       token.Position
	backtrace string
	reporter  Reporter
}

pub struct Warning {
pub:
	message   string
	file_path string
	pos       token.Position
	reporter  Reporter
}

pub struct CompilerMessage {
pub:
	message   string
	file_path string
	pos       token.Position
	reporter  Reporter
}

pub const msg_invalid_output_path = "Error: Invalid path specified for the -o flag. Please provide a valid directory path where compiled files should be saved.";
pub const msg_invalid_input_path = "Error: Invalid path specified for the -i flag. Please provide a valid directory or file path containing the .psc scripts to compile.";
pub const msg_invalid_headers_path = "Error: Invalid path specified for the -h flag. Please provide a valid directory path containing header/import .psc files.";
pub const msg_duplicate_input_flag = "Error: Duplicate -i flag detected with the same path. Please ensure each -i flag points to a unique directory or file."
pub const msg_duplicate_output_flag = "Error: The -o flag has already been specified. Please provide only one output directory.";
pub const msg_missing_input = "Error: Missing mandatory -i flag. Please specify the directory or file containing .psc scripts to compile.";
pub const msg_missing_output = "Error: Missing mandatory -o flag. Please specify the directory where compiled .pex files should be saved.";
//TODO
pub const msg_wrong_number_of_arguments = "Error: Incorrect number of arguments for the command. Please refer to the documentation for the correct usage.";
//TODO
pub const msg_missing_or_incorrect_argument = "Error: Missing or incorrect argument. Please check the syntax of your command.";
pub const msg_missing_or_incorrect_command = "Error: Invalid command. Please use one of the following commands: compile, read, disassembly, create-dump, help.";
pub const msg_invalid_path_disassembly = "Error: Invalid path specified for the disassembly command. Please provide a valid file path for the .pex file.";
pub const msg_invalid_path_read = "Error: Invalid path specified for the read command. Please provide a valid file path for the .pex file.";
pub const msg_invalid_path_create_dump = "Error: Invalid path specified for create-dump. Please provide a valid directory path containing .pex files.";

