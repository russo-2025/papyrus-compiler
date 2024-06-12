import pref
import papyrus.ast
import papyrus.parser
import papyrus.checker

const (
	prefs = pref.Preferences {
		paths: []string{}
		mode: .compile
		backend: .pex
		no_cache: true
	}

	other_src = 
"Scriptname Other\n"

	parent_src = 
"Scriptname CDFG\n"

	src_template = 
"Scriptname ABCD extends CDFG\n
Function Bar(string arg1, int arg2, float arg3, bool arg4, ABCD obj, CDFG pobj)\n
EndFunction\n"
)

fn test_autocast() {
	full_src := "${src_template}\n"
	mut table := ast.new_table()
	mut global_scope := &ast.Scope{}

	parser.parse_text("::gen_test.v/other-src::", other_src, mut table, prefs, mut global_scope)
	parser.parse_text("::gen_test.v/parent-src::", parent_src, mut table, prefs, mut global_scope)
	mut file := parser.parse_text("::gen_test.v/src::", full_src, mut table, prefs, mut global_scope)

	mut c := checker.new_checker(table, prefs)

	array_typ := table.find_type_idx("Int[]")
	assert array_typ != 0
	object_typ := table.find_type_idx("ABCD")
	assert object_typ != 0
	parent_object_typ := table.find_type_idx("CDFG")
	assert parent_object_typ != 0
	other_object_typ := table.find_type_idx("Other")
	assert parent_object_typ != 0

	//autocast to None
	//assert c.can_autocast(ast.none_type, ast.none_type)
	assert !c.can_autocast(ast.int_type, ast.none_type)
	assert !c.can_autocast(ast.float_type, ast.none_type)
	assert !c.can_autocast(ast.string_type, ast.none_type)
	assert !c.can_autocast(ast.bool_type, ast.none_type)
	assert !c.can_autocast(object_typ, ast.none_type)
	assert !c.can_autocast(array_typ, ast.none_type)

	//autocast to int
	assert !c.can_autocast(ast.none_type, ast.int_type)
	//assert c.can_autocast(ast.int_type, ast.int_type)
	assert !c.can_autocast(ast.float_type, ast.int_type)
	assert !c.can_autocast(ast.string_type, ast.int_type)
	assert !c.can_autocast(ast.bool_type, ast.int_type)
	assert !c.can_autocast(object_typ, ast.int_type)
	assert !c.can_autocast(array_typ, ast.int_type)

	//autocast to float
	assert !c.can_autocast(ast.none_type, ast.float_type)
	assert c.can_autocast(ast.int_type, ast.float_type)
	//assert c.can_autocast(ast.float_type, ast.float_type)
	assert !c.can_autocast(ast.string_type, ast.float_type)
	assert !c.can_autocast(ast.bool_type, ast.float_type)
	assert !c.can_autocast(object_typ, ast.float_type)
	assert !c.can_autocast(array_typ, ast.float_type)

	//autocast to string
	assert c.can_autocast(ast.none_type, ast.string_type)
	assert c.can_autocast(ast.int_type, ast.string_type)
	assert c.can_autocast(ast.float_type, ast.string_type)
	//assert c.can_autocast(ast.string_type, ast.string_type)
	assert c.can_autocast(ast.bool_type, ast.string_type)
	assert c.can_autocast(object_typ, ast.string_type)
	assert c.can_autocast(array_typ, ast.string_type)

	//autocast to bool
	assert c.can_autocast(ast.none_type, ast.bool_type)
	assert c.can_autocast(ast.int_type, ast.bool_type)
	assert c.can_autocast(ast.float_type, ast.bool_type)
	assert c.can_autocast(ast.string_type, ast.bool_type)
	//assert c.can_autocast(ast.bool_type, ast.bool_type)
	assert c.can_autocast(object_typ, ast.bool_type)
	assert c.can_autocast(array_typ, ast.bool_type)

	//autocast to array
	assert c.can_autocast(ast.none_type, array_typ)
	assert !c.can_autocast(ast.int_type, array_typ)
	assert !c.can_autocast(ast.float_type, array_typ)
	assert !c.can_autocast(ast.string_type, array_typ)
	assert !c.can_autocast(ast.bool_type, array_typ)
	assert !c.can_autocast(object_typ, array_typ)
	//assert c.can_autocast(array_typ, array_typ)

	//autocast to object
	assert c.can_autocast(ast.none_type, object_typ)
	assert !c.can_autocast(ast.int_type, object_typ)
	assert !c.can_autocast(ast.float_type, object_typ)
	assert !c.can_autocast(ast.string_type, object_typ)
	assert !c.can_autocast(ast.bool_type, object_typ)
	assert c.can_autocast(object_typ, parent_object_typ)
	assert !c.can_autocast(object_typ, other_object_typ)
	assert !c.can_autocast(array_typ, object_typ)
}

fn test_can_cast() {
	full_src := "${src_template}\n"
	mut table := ast.new_table()
	mut global_scope := &ast.Scope{}

	parser.parse_text("::gen_test.v/other-src::", other_src, mut table, prefs, mut global_scope)
	parser.parse_text("::gen_test.v/parent-src::", parent_src, mut table, prefs, mut global_scope)
	mut file := parser.parse_text("::gen_test.v/src::", full_src, mut table, prefs, mut global_scope)

	mut c := checker.new_checker(table, prefs)

	array_typ := table.find_type_idx("Int[]")
	assert array_typ != 0
	object_typ := table.find_type_idx("ABCD")
	assert object_typ != 0
	parent_object_typ := table.find_type_idx("CDFG")
	assert parent_object_typ != 0
	other_object_typ := table.find_type_idx("Other")
	assert parent_object_typ != 0

	//cast to none
	//assert !c.can_cast(ast.none_type, ast.none_type)
	assert !c.can_cast(ast.int_type, ast.none_type)
	assert !c.can_cast(ast.float_type, ast.none_type)
	assert !c.can_cast(ast.string_type, ast.none_type)
	assert !c.can_cast(ast.bool_type, ast.none_type)
	assert !c.can_cast(object_typ, ast.none_type)
	assert !c.can_cast(array_typ, ast.none_type)
	
	//cast to int
	assert !c.can_cast(ast.none_type, ast.int_type)
	//assert !c.can_cast(ast.int_type, ast.int_type)
	assert c.can_cast(ast.float_type, ast.int_type)
	assert c.can_cast(ast.string_type, ast.int_type)
	assert c.can_cast(ast.bool_type, ast.int_type)
	assert !c.can_cast(object_typ, ast.int_type)
	assert !c.can_cast(array_typ, ast.int_type)

	//cast to float
	assert !c.can_cast(ast.none_type, ast.float_type)
	assert c.can_cast(ast.int_type, ast.float_type)
	//assert !c.can_cast(ast.float_type, ast.float_type)
	assert c.can_cast(ast.string_type, ast.float_type)
	assert c.can_cast(ast.bool_type, ast.float_type)
	assert !c.can_cast(object_typ, ast.float_type)
	assert !c.can_cast(array_typ, ast.float_type)

	//cast to string
	assert c.can_cast(ast.none_type, ast.string_type)
	assert c.can_cast(ast.int_type, ast.string_type)
	assert c.can_cast(ast.float_type, ast.string_type)
	//assert c.can_cast(ast.string_type, ast.string_type)
	assert c.can_cast(ast.bool_type, ast.string_type)
	assert c.can_cast(object_typ, ast.string_type)
	assert c.can_cast(array_typ, ast.string_type)

	//cast to bool
	assert c.can_cast(ast.none_type, ast.bool_type)
	assert c.can_cast(ast.int_type, ast.bool_type)
	assert c.can_cast(ast.float_type, ast.bool_type)
	assert c.can_cast(ast.string_type, ast.bool_type)
	//assert c.can_cast(ast.bool_type, ast.bool_type)
	assert c.can_cast(object_typ, ast.bool_type)
	assert c.can_cast(array_typ, ast.bool_type)

	//cast to object
	assert !c.can_cast(ast.none_type, object_typ)
	assert !c.can_cast(ast.int_type, object_typ)
	assert !c.can_cast(ast.float_type, object_typ)
	assert !c.can_cast(ast.string_type, object_typ)
	assert !c.can_cast(ast.bool_type, object_typ)
	assert c.can_cast(object_typ, parent_object_typ)
	assert c.can_cast(parent_object_typ, object_typ)
	assert !c.can_cast(other_object_typ, object_typ)
	assert !c.can_cast(object_typ, other_object_typ)
	assert !c.can_cast(array_typ, object_typ)

	//cast to array
	assert !c.can_cast(ast.none_type, array_typ)
	assert !c.can_cast(ast.int_type, array_typ)
	assert !c.can_cast(ast.float_type, array_typ)
	assert !c.can_cast(ast.string_type, array_typ)
	assert !c.can_cast(ast.bool_type, array_typ)
	assert !c.can_cast(object_typ, array_typ)
	assert !c.can_cast(table.find_type_idx("float[]"), array_typ)

}

fn test_cast2() {
	full_src := "${src_template}\n"
	mut table := ast.new_table()
	mut global_scope := &ast.Scope{}

	parser.parse_text("::gen_test.v/other-src::", other_src, mut table, prefs, mut global_scope)
	parser.parse_text("::gen_test.v/parent-src::", parent_src, mut table, prefs, mut global_scope)
	mut file := parser.parse_text("::gen_test.v/src::", full_src, mut table, prefs, mut global_scope)

	mut c := checker.new_checker(table, prefs)
	
	typ := table.find_type_idx("ABCD")
	assert typ != 0
	int_array_typ := table.find_type_idx("Int[]")
	assert int_array_typ != 0

	assert !c.valid_type(typ, ast.none_type)
	assert c.can_autocast(ast.none_type, typ)
	
	assert !c.valid_type(int_array_typ, ast.none_type)
	assert c.can_autocast(ast.none_type, int_array_typ)
}