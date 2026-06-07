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

	// debug function entries: GetState, GotoState, onEndState, onBeginState, Foo, Bar
	assert out_pex_file.functions.len == 6
	// auto-generated functions have no line number entries (matches original compiler behaviour)
	assert out_pex_file.functions[0].instruction_line_numbers.len == 0 // GetState
	assert out_pex_file.functions[1].instruction_line_numbers.len == 0 // GotoState
	assert out_pex_file.functions[2].instruction_line_numbers.len == 0 // onEndState
	assert out_pex_file.functions[3].instruction_line_numbers.len == 0 // onBeginState
	// Foo: 3 instructions (cast + iadd + assign), all on line 4 of the source
	assert out_pex_file.functions[4].instruction_line_numbers.len == 3
	assert out_pex_file.functions[4].instruction_line_numbers[0] == 4
	assert out_pex_file.functions[4].instruction_line_numbers[1] == 4
	assert out_pex_file.functions[4].instruction_line_numbers[2] == 4
	// Bar: same shape as Foo, body on line 8 of the source
	assert out_pex_file.functions[5].instruction_line_numbers.len == 3
	assert out_pex_file.functions[5].instruction_line_numbers[0] == 8
	assert out_pex_file.functions[5].instruction_line_numbers[1] == 8
	assert out_pex_file.functions[5].instruction_line_numbers[2] == 8

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

fn test_debug_info() {
	debug_src :=
"Scriptname Foo

int Property Value
	int Function Get()
		Return 42
	EndFunction
	Function Set(int n)
	EndFunction
EndProperty

Function Linear(int a, float b) global
	int x = a + b as int
	int y = x + 1
	int z = y * 2
EndFunction

int Function IfElse(int a) global
	int result = 0
	if a > 0
		result = 1
	else
		result = -1
	endIf
	Return result
EndFunction

int Function WhileLoop(int n) global
	int i = 0
	int sum = 0
	while i < n
		sum = sum + i
		i = i + 1
	endWhile
	Return sum
EndFunction

Function PropertyOps()
	int old = Value
	Value = old + 1
EndFunction
"

	mut prefs := pref.Preferences {
		paths: []string{}
		mode: .compile
		backend: .pex
		no_cache: true
		output_mode: .silent
	}
	mut table := ast.new_table()
	mut global_scope := &ast.Scope{}

	mut file := parser.parse_text("::debug_info_test.v::", debug_src, mut table, prefs, mut global_scope)

	mut c := checker.new_checker(table, prefs)
	c.check(mut file)
	assert c.errors.len == 0

	mut pex_file := gen_pex.gen_pex_file(mut file, mut table, prefs)
	bytes := pex.write(mut pex_file)
	out_pex_file := pex.read(bytes)

	// debug info enabled
	assert out_pex_file.has_debug_info == 1

	// expected functions in debug info: GetState, GotoState, onEndState, onBeginState,
	// Value(getter), Value(setter), Linear, IfElse, WhileLoop, PropertyOps
	assert out_pex_file.functions.len == 10

	// auto-generated entries
	assert out_pex_file.get_string(out_pex_file.functions[0].function_name) == "GetState"
	assert out_pex_file.functions[0].function_type == .method
	assert out_pex_file.get_string(out_pex_file.functions[1].function_name) == "GotoState"
	assert out_pex_file.functions[1].function_type == .method
	assert out_pex_file.get_string(out_pex_file.functions[2].function_name) == "onEndState"
	assert out_pex_file.functions[2].function_type == .method
	assert out_pex_file.get_string(out_pex_file.functions[3].function_name) == "onBeginState"
	assert out_pex_file.functions[3].function_type == .method

	// property accessors must use the property name ("Value"), not the function name ("Get"/"Set")
	assert out_pex_file.get_string(out_pex_file.functions[4].function_name) == "Value"
	assert out_pex_file.functions[4].function_type == .getter
	assert out_pex_file.get_string(out_pex_file.functions[5].function_name) == "Value"
	assert out_pex_file.functions[5].function_type == .setter

	// user methods
	assert out_pex_file.get_string(out_pex_file.functions[6].function_name) == "Linear"
	assert out_pex_file.functions[6].function_type == .method
	assert out_pex_file.get_string(out_pex_file.functions[7].function_name) == "IfElse"
	assert out_pex_file.functions[7].function_type == .method
	assert out_pex_file.get_string(out_pex_file.functions[8].function_name) == "WhileLoop"
	assert out_pex_file.functions[8].function_type == .method
	assert out_pex_file.get_string(out_pex_file.functions[9].function_name) == "PropertyOps"
	assert out_pex_file.functions[9].function_type == .method

	// 1-based line numbers for the getter body (source line 5: "Return 42")
	value_getter := out_pex_file.functions[4]
	assert value_getter.instruction_line_numbers.len == 1
	assert value_getter.instruction_line_numbers[0] == 5

	// setter has empty body
	value_setter := out_pex_file.functions[5]
	assert value_setter.instruction_line_numbers.len == 0

	// Linear: 7 instructions on lines 12,12,12,13,13,14,14 of the source
	linear_dbg := out_pex_file.functions[6]
	assert linear_dbg.instruction_line_numbers.len == 7
	assert linear_dbg.instruction_line_numbers[0] == 12
	assert linear_dbg.instruction_line_numbers[1] == 12
	assert linear_dbg.instruction_line_numbers[2] == 12
	assert linear_dbg.instruction_line_numbers[3] == 13
	assert linear_dbg.instruction_line_numbers[4] == 13
	assert linear_dbg.instruction_line_numbers[5] == 14
	assert linear_dbg.instruction_line_numbers[6] == 14

	// IfElse: 7 instructions on lines 18,19,19,20,20,22,24 of the source
	ifelse_dbg := out_pex_file.functions[7]
	assert ifelse_dbg.instruction_line_numbers.len == 7
	assert ifelse_dbg.instruction_line_numbers[0] == 18
	assert ifelse_dbg.instruction_line_numbers[1] == 19
	assert ifelse_dbg.instruction_line_numbers[2] == 19
	assert ifelse_dbg.instruction_line_numbers[3] == 20
	assert ifelse_dbg.instruction_line_numbers[4] == 20
	assert ifelse_dbg.instruction_line_numbers[5] == 22
	assert ifelse_dbg.instruction_line_numbers[6] == 24

	// WhileLoop: 10 instructions on lines 28,29,30,30,31,31,32,32,32,34 of the source
	while_dbg := out_pex_file.functions[8]
	assert while_dbg.instruction_line_numbers.len == 10
	assert while_dbg.instruction_line_numbers[0] == 28
	assert while_dbg.instruction_line_numbers[1] == 29
	assert while_dbg.instruction_line_numbers[2] == 30
	assert while_dbg.instruction_line_numbers[3] == 30
	assert while_dbg.instruction_line_numbers[4] == 31
	assert while_dbg.instruction_line_numbers[5] == 31
	assert while_dbg.instruction_line_numbers[6] == 32
	assert while_dbg.instruction_line_numbers[7] == 32
	assert while_dbg.instruction_line_numbers[8] == 32
	assert while_dbg.instruction_line_numbers[9] == 34

	// PropertyOps: 4 instructions on lines 38,38,39,39 of the source
	prop_ops_dbg := out_pex_file.functions[9]
	assert prop_ops_dbg.instruction_line_numbers.len == 4
	assert prop_ops_dbg.instruction_line_numbers[0] == 38
	assert prop_ops_dbg.instruction_line_numbers[1] == 38
	assert prop_ops_dbg.instruction_line_numbers[2] == 39
	assert prop_ops_dbg.instruction_line_numbers[3] == 39
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