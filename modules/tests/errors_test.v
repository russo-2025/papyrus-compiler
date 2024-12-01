import pref
import papyrus.ast
import papyrus.parser
import papyrus.checker
import papyrus.errors

const prefs = pref.Preferences {
	paths: []string{}
	mode: .compile
	backend: .pex
	no_cache: true
	output_mode: .silent
}
	
	
const other_src = 
"Scriptname OtherScript\n"

const parent_src =
"Scriptname CDFG\n"

const src_template = 
"Scriptname ABCD extends CDFG
Function FuncIntArg(int arg)
EndFunction\n"

fn compile(src string) []errors.Error {
	mut table := ast.new_table()
	mut global_scope := &ast.Scope{}
	
	full_src := "${src_template}${src}"

	mut other_file := parser.parse_text("::gen_test.v/other-src::", other_src, mut table, prefs, mut global_scope)
	mut parent_file := parser.parse_text("::gen_test.v/parent::", parent_src, mut table, prefs, mut global_scope)
	mut file := parser.parse_text("::gen_test.v/src::", full_src, mut table, prefs, mut global_scope)

	mut c := checker.new_checker(table, prefs)

	c.check(mut other_file)
	c.check(mut parent_file)
	c.check(mut file)

	return c.errors
}

fn compile_top_stmts(src string) []errors.Error {
	return compile(src)
}

fn compile_stmts(src string) []errors.Error {
	full_src := "Function MyTestFn(string arg1, int arg2, float arg3, bool arg4, ABCD obj, CDFG pobj, int[] int_arr)\n${src}\nEndFunction\n"
	return compile_top_stmts(full_src)
}

fn compile_stmt(src string) []errors.Error {
	return compile_stmts(src)
}

fn compile_expr(src string) []errors.Error {
	return compile_stmt(src)
}

fn test_call_expr() {
	errs := compile_expr('obj.FuncIntArg()')
	assert errs.len == 1
	assert errs[0].message == 'function takes 1 parameters not 0'
}