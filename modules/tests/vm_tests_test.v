import builder
import os
import pref
import pex

fn test_builder() {
	input_dir := os.real_path('test-files/vm-tests')
	output_dir := os.real_path('test-files/compiled')

	file1 := os.join_path(input_dir, "AAATestObject.psc")
	file2 := os.join_path(input_dir, "LatentTest.psc")
	file3 := os.join_path(input_dir, "OpcodesTest.psc")

	if !os.is_file(file1) || !os.is_file(file2) || !os.is_file(file3) {
		assert false, "invalid input files ${file1}, ${file2}, ${file3}"
	}

	if !os.is_dir(output_dir) {
		os.mkdir(output_dir, os.MkdirParams{}) or { assert false, "failed to create a folder" }
	}

	prefs := pref.Preferences {
		paths: [ input_dir ]
		output_dir: output_dir
		mode: .compile
		backend: .pex
		no_cache: true
		header_dirs: [ os.real_path('bin/papyrus-headers') ]
		output_mode: pref.OutputMode.silent
	}

	out_file1 := os.join_path(prefs.output_dir, "AAATestObject.pex")
	out_file2 := os.join_path(prefs.output_dir, "LatentTest.pex")
	out_file3 := os.join_path(prefs.output_dir, "OpcodesTest.pex")

	if os.is_file(out_file1) {
		os.rm(out_file1) or { assert false, "failed to delete file" }
	}
	if os.is_file(out_file2) {
		os.rm(out_file2) or { assert false, "failed to delete file" }
	}
	if os.is_file(out_file3) {
		os.rm(out_file3) or { assert false, "failed to delete file" }
	}

	builder.compile(&prefs)

	pex1 := pex.read_from_file(out_file1)
	assert pex1.src_file_name == "AAATestObject.psc"
	assert pex1.string_table.len == 29
	assert pex1.objects.len == 1
	assert pex1.get_string(pex1.objects[0].name) == "AAATestObject"
	assert pex1.objects[0].size == 231
	assert pex1.objects[0].variables.len == 1
	assert pex1.objects[0].properties.len == 1
	assert pex1.objects[0].states.len == 1
	assert pex1.get_string(pex1.objects[0].states[0].name) == ""
	assert pex1.objects[0].states[0].functions.len == 5
	pex1_string_table := [ "GetState" , "GotoState" , "onEndState" , "onBeginState" , "ReturbBackValue"]
	for func in pex1.objects[0].states[0].functions {
		assert pex1.get_string(func.name) in pex1_string_table
	}

	pex2 := pex.read_from_file(out_file2)
	assert pex2.src_file_name == "LatentTest.psc"
	println("=================================================")
	println(pex2.string_table)
	println("=================================================")
	assert pex2.string_table.len == 35
	assert pex2.objects.len == 1
	assert pex2.get_string(pex2.objects[0].name) == "LatentTest"
	assert pex2.objects[0].size == 427
	assert pex2.objects[0].variables.len == 0
	assert pex2.objects[0].properties.len == 0
	assert pex2.objects[0].states.len == 1
	assert pex2.get_string(pex2.objects[0].states[0].name) == ""
	assert pex2.objects[0].states[0].functions.len == 11
	pex2_string_table := [ "GetState", "GotoState", "onEndState", "onBeginState", "LatentFunc", "NonLatentFunc", "LatentAdd", "LatentDouble", "Main", "Main2", "Main3" ]
	for func in pex2.objects[0].states[0].functions {
		assert pex2.get_string(func.name) in pex2_string_table
	}

	pex3 := pex.read_from_file(out_file3)
	assert pex3.src_file_name == "OpcodesTest.psc"
	assert pex3.string_table.len == 219
	assert pex3.objects.len == 1
	assert pex3.get_string(pex3.objects[0].name) == "OpcodesTest"
	assert pex3.objects[0].size == 8503
	assert pex3.objects[0].variables.len == 21
	assert pex3.objects[0].properties.len == 2
	assert pex3.objects[0].states.len == 3
	assert pex3.get_string(pex3.objects[0].states[0].name) == ""
	assert pex3.objects[0].states[0].functions.len == 29
	pex3_string_table := [ "GetState", "GotoState", "Assert", "Print", "TestFunction", "OnBeginState", "OnEndState", "Main", 
	"Foo", "Bar", "IdentifierResolutionTest", "StateTest", "FactorialTest", "IntTest", "FloatTest", 
	"StringTest", "OperatorsTest", "ReturnTest", "AssignTest", "WhileTest", "ArrayTest", "IfTest", 
	"CastTest", "CallParentTest", "PropertyTest", "returnValue", "Factorial", "strcat", "ifAndElse" ]
	for func in pex3.objects[0].states[0].functions {
		assert pex3.get_string(func.name) in pex3_string_table
	}
}