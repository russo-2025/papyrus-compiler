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