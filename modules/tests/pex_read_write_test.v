import pref
import papyrus.ast
import papyrus.parser
import papyrus.checker
import gen.gen_pex
import pex

const src =
"Scriptname ABCD

Function Foo(int arg1, float arg2) global
	int n = arg1 + arg2 as int
EndFunction

Function Bar(int arg1, float arg2)
	int n = arg1 + arg2 as int
EndFunction
"

fn test_build() {
	mut prefs := pref.Preferences {
		paths: []string{}
		mode: .compile
		backend: .pex
		no_cache: true
		output_mode: .silent
	}
	mut table := ast.new_table()
	mut global_scope := &ast.Scope{}

	mut file := parser.parse_text("::rw_text.v::", src, mut table, prefs, mut global_scope)

	mut c := checker.new_checker(table, prefs)

	c.check(mut file)

	assert c.errors.len == 0

	mut pex_file := gen_pex.gen_pex_file(mut file, mut table, prefs)
	bytes := pex.write(mut pex_file)
	assert bytes.len > 0
	out_pex_file := pex.read(bytes)

	//string table
	assert out_pex_file.string_table.len == 26

	//debug info
	assert out_pex_file.has_debug_info == 1
	assert out_pex_file.modification_time > 0

	// debug function entries: GetState, GotoState, Foo, Bar
	assert out_pex_file.functions.len == 4
	// auto-generated functions have placeholder zero line numbers
	assert out_pex_file.functions[0].instruction_line_numbers.len == 1 // GetState: 1 instruction
	assert out_pex_file.functions[1].instruction_line_numbers.len == 3 // GotoState: 3 instructions
	// Foo: 3 instructions (cast + iadd + assign), all on line 4 of the source (scanner reports 3)
	assert out_pex_file.functions[2].instruction_line_numbers.len == 3
	assert out_pex_file.functions[2].instruction_line_numbers[0] == 3
	assert out_pex_file.functions[2].instruction_line_numbers[1] == 3
	assert out_pex_file.functions[2].instruction_line_numbers[2] == 3
	// Bar: same shape as Foo, body on line 8 of the source (scanner reports 7)
	assert out_pex_file.functions[3].instruction_line_numbers.len == 3
	assert out_pex_file.functions[3].instruction_line_numbers[0] == 7
	assert out_pex_file.functions[3].instruction_line_numbers[1] == 7
	assert out_pex_file.functions[3].instruction_line_numbers[2] == 7

	//user flags
	assert out_pex_file.user_flags.len == 2

	//objests
	assert out_pex_file.objects.len == 1

	assert out_pex_file.get_string(out_pex_file.objects[0].name) == "ABCD"
	assert out_pex_file.objects[0].size == 255
	assert out_pex_file.get_string(out_pex_file.objects[0].parent_class_name) == ""
	assert out_pex_file.get_string(out_pex_file.objects[0].docstring) == ""
	assert out_pex_file.objects[0].user_flags == 0
	assert out_pex_file.get_string(out_pex_file.objects[0].auto_state_name) == pex.empty_state_name
	assert out_pex_file.objects[0].variables.len == 0
	assert out_pex_file.objects[0].properties.len == 0
	assert out_pex_file.objects[0].states.len == 1

	//states
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].name) == pex.empty_state_name
	assert out_pex_file.objects[0].states[0].functions.len == 6

	//functions
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[0].name) == "GetState"
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[1].name) == "GotoState"
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[2].name) == "onEndState"
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[3].name) == "onBeginState"

	foo_fn := out_pex_file.objects[0].states[0].functions[4]

	assert out_pex_file.get_string(foo_fn.name) == "Foo"
	assert out_pex_file.get_string(foo_fn.info.return_type) == "None"
	assert out_pex_file.get_string(foo_fn.info.docstring) == ""
	assert foo_fn.info.user_flags == 0
	assert foo_fn.info.flags == 0b01
	assert foo_fn.info.params.len == 2
	assert foo_fn.info.locals.len == 2
	assert foo_fn.info.instructions.len == 3

	bar_fn := out_pex_file.objects[0].states[0].functions[5]

	assert out_pex_file.get_string(bar_fn.name) == "Bar"
	assert out_pex_file.get_string(bar_fn.info.return_type) == "None"
	assert out_pex_file.get_string(bar_fn.info.docstring) == ""
	assert bar_fn.info.user_flags == 0
	assert bar_fn.info.flags == 0b00
	assert bar_fn.info.params.len == 2
	assert bar_fn.info.locals.len == 2
	assert bar_fn.info.instructions.len == 3
}

fn test_build_no_debug_info() {
	mut no_debug_prefs := pref.Preferences {
		paths: []string{}
		mode: .compile
		backend: .pex
		no_cache: true
		output_mode: .silent
		debug_info: false
	}
	mut table2 := ast.new_table()
	mut global_scope2 := &ast.Scope{}

	mut file2 := parser.parse_text("::rw_nodebug.v::", src, mut table2, no_debug_prefs, mut global_scope2)

	mut c2 := checker.new_checker(table2, no_debug_prefs)
	c2.check(mut file2)
	assert c2.errors.len == 0

	mut pex_file2 := gen_pex.gen_pex_file(mut file2, mut table2, no_debug_prefs)
	bytes2 := pex.write(mut pex_file2)
	assert bytes2.len > 0
	out_pex_file2 := pex.read(bytes2)

	assert out_pex_file2.has_debug_info == 0
	assert out_pex_file2.functions.len == 0
}