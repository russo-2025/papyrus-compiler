import pref
import papyrus.ast
import papyrus.parser
import papyrus.checker
import gen.gen_pex
import pex

const (
	src =
"Scriptname ABCD

Function Foo(int arg1, float arg2) global
	int n = arg1 + arg2
EndFunction

Function Bar(int arg1, float arg2)
	int n = arg1 + arg2
EndFunction
"
)

fn test_build() {
	prefs := pref.Preferences {
		paths: []string{}
		out_dir: []string{}
		mode: .compile
		backend: .pex
		no_cache: true
		crutches_enabled: false
	}
	table := ast.new_table()
	global_scope := &ast.Scope{
		parent: 0
	}

	mut file := parser.parse_text(src, table, prefs, global_scope)

	mut c := checker.new_checker(table, prefs)

	c.check(mut file)

	assert c.errors.len == 0

	pex_file := gen_pex.gen_pex_file(file, table, prefs)
	bytes := pex.write(pex_file)
	out_pex_file := pex.read(bytes)

	//string table
	assert out_pex_file.string_table_count == 27

	//debug info
	assert out_pex_file.has_debug_info == 1
	assert out_pex_file.modification_time == i64(1616261626)

	//user flags
	assert out_pex_file.user_flag_count == 2

	//objests
	assert out_pex_file.object_count == 1

	assert out_pex_file.get_string(out_pex_file.objects[0].name) == "ABCD"
	assert out_pex_file.objects[0].size == 277
	assert out_pex_file.get_string(out_pex_file.objects[0].parent_class_name) == ""
	assert out_pex_file.get_string(out_pex_file.objects[0].docstring) == ""
	assert out_pex_file.objects[0].user_flags == 0
	assert out_pex_file.get_string(out_pex_file.objects[0].default_state_name) == ""
	assert out_pex_file.objects[0].num_variables == 0
	assert out_pex_file.objects[0].num_properties == 0
	assert out_pex_file.objects[0].num_states == 1

	//states
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].name) == ""
	assert out_pex_file.objects[0].states[0].num_functions == 6

	//functions
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[0].name) == "GetState"
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[1].name) == "GotoState"
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[2].name) == "onEndState"
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[3].name) == "onBeginState"

	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[4].name) == "Foo"
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[4].info.return_type) == "None"
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[4].info.docstring) == ""
	assert out_pex_file.objects[0].states[0].functions[4].info.user_flags == 0
	assert out_pex_file.objects[0].states[0].functions[4].info.flags == 0b01
	assert out_pex_file.objects[0].states[0].functions[4].info.num_params == 2
	assert out_pex_file.objects[0].states[0].functions[4].info.num_locals == 3
	assert out_pex_file.objects[0].states[0].functions[4].info.num_instructions == 4

	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[5].name) == "Bar"
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[5].info.return_type) == "None"
	assert out_pex_file.get_string(out_pex_file.objects[0].states[0].functions[5].info.docstring) == ""
	assert out_pex_file.objects[0].states[0].functions[5].info.user_flags == 0
	assert out_pex_file.objects[0].states[0].functions[5].info.flags == 0b00
	assert out_pex_file.objects[0].states[0].functions[5].info.num_params == 2
	assert out_pex_file.objects[0].states[0].functions[5].info.num_locals == 3
	assert out_pex_file.objects[0].states[0].functions[5].info.num_instructions == 4
}