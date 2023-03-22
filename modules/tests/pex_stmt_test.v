import papyrus.ast
import papyrus.parser
import papyrus.checker
import pex
import gen.gen_pex
import pref

const (
	prefs = pref.Preferences {
		paths: []string{}
		mode: .compile
		backend: .pex
		no_cache: true
		crutches_enabled: false
	}

	other_src = 
"Scriptname OtherScript
Function Foo()
EndFunction
Function Foz()
EndFunction\n
"

	parent_src =
"Scriptname CDFG

CDFG Property ParentObjAutoProp Auto

CDFG Property ParentObjFullProp
	CDFG Function Get()
		return none
	EndFunction
	Function Set(CDFG value)
	EndFunction
EndProperty

ABCD Function GetChildObj()
	return none
EndFunction

Function ParentFoz(int n1, int n2)
EndFunction\n"

	src_template = 
"Scriptname ABCD extends CDFG

CDFG ObjVar
int myValue = 0
int Property myAutoProp = 123 Auto
int Property myAutoReadProp = 123 AutoReadOnly

Auto State MyAutoState
    Function Foz(int n1, int n2)
        n1 + n2 + 5
    EndFunction
EndState

State MyState
EndState

int Property myPropGet
	int Function Get()
		return 112
	EndFunction
EndProperty

int Property myPropSet
	Function Set(int value)
	EndFunction
EndProperty

int Property myPropFull
	int Function Get()
		return 12
	EndFunction
	Function Set(int value)
	EndFunction
EndProperty

Event OnInit()
EndEvent

Function FuncWithPObjArg(CDFG arg1)
EndFunction

Function FuncWithObjArg(ABCD arg1)
EndFunction

Function FuncWithOptionalObjArg(ABCD arg1 = none)
EndFunction

OtherScript Function GetOtherObject() global
return None
EndFunction

Function Foo(int n1, int n2) global
EndFunction

Function Foz(int n1, int n2)
EndFunction\n"
)

fn compile_top(src string) &pex.PexFile {
	full_src := "${src_template}${src}"
	table := ast.new_table()
	global_scope := &ast.Scope{
		parent: 0
	}
	
	parser.parse_text("::gen_test.v/other::", other_src, table, prefs, global_scope)
	mut parent_file := parser.parse_text("::gen_test.v/parent::", parent_src, table, prefs, global_scope)
	mut file := parser.parse_text("::gen_test.v/src::", full_src, table, prefs, global_scope)

	mut c := checker.new_checker(table, prefs)

	c.check(mut parent_file)
	c.check(mut file)

	assert c.errors.len == 0

	pex_file := gen_pex.gen_pex_file(file, table, prefs)
	bytes := pex.write(pex_file)
	out_pex_file := pex.read(bytes)
	return out_pex_file
}

fn compile(src string) &pex.PexFile {
	full_src := "${src_template}Function Bar(string v, ABCD obj, CDFG pobj, OtherScript obj2, int[] intArray)\n${src}\nEndFunction\n"
	table := ast.new_table()
	global_scope := &ast.Scope{
		parent: 0
	}
	
	parser.parse_text("::gen_test.v/other::", other_src, table, prefs, global_scope)
	mut parent_file := parser.parse_text("::gen_test.v/parent::", parent_src, table, prefs, global_scope)
	mut file := parser.parse_text("::gen_test.v/src::", full_src, table, prefs, global_scope)

	mut c := checker.new_checker(table, prefs)

	c.check(mut parent_file)
	c.check(mut file)

	assert c.errors.len == 0

	pex_file := gen_pex.gen_pex_file(file, table, prefs)
	bytes := pex.write(pex_file)
	out_pex_file := pex.read(bytes)
	return out_pex_file
}

fn get_instructions(pex_file &pex.PexFile) []pex.Instruction {
	func := pex_file.get_function_from_empty_state("ABCD", "Bar") or { panic("function not found") }

	$if false {
		println("")
		for instr in func.info.instructions {
			pex_file.print_instruction(instr, 0)
		}
		println("")
	}

	return func.info.instructions
}


fn test_state_decl_1() {
	//src:		
	//		State MyState1
	//		EndState
	//original:
	//			name: 'mystate1'
    //			functions count: '0'
    //			functions:

	pex_file := compile_top('State MyTestState1
							EndState')

	obj := pex_file.get_object("ABCD") or { panic("object not found") }
	state := pex_file.get_state(obj, "MyTestState1") or { panic("state not found") }

	assert pex_file.get_string(state.name) == "MyTestState1"
	assert state.functions.len == 0
}

fn test_state_decl_2() {
	//src:		
	//		State MyState2
	//			Function Foz(int n1, int n2)
	//				n1 + n2 + 1
	//			EndFunction
	//		EndState
	//original:
	//			name: 'mystate2'
	//			functions count: '1'
	//			functions:
	//			        name: 'Foz'
	//			        typ: 'None'
	//			        doc: ''
	//			        user_flags: 0x0
	//			        flags: 0x00
	//			        flags: ``
	//			        params count: '2'
	//			                Int n1
	//			                Int n2
	//			        locals count: '1'
	//			                Int ::temp0
	//			        instructions count: '2'
	//			                opcode: 'iadd', args: [ident(::temp0), ident(n1), ident(n2)]
	//			                opcode: 'iadd', args: [ident(::temp0), ident(::temp0), integer(1)]

	pex_file := compile_top('State MyTestState2
								Function Foz(int n1, int n2)
									n1 + n2 + 1
								EndFunction
							EndState')

	obj := pex_file.get_object("ABCD") or { panic("object not found") }
	state := pex_file.get_state(obj, "MyTestState2") or { panic("state not found") }

	assert pex_file.get_string(state.name) == "MyTestState2"
	assert state.functions.len == 1

	assert pex_file.get_string(state.functions[0].name) == "Foz"
	assert pex_file.get_string(state.functions[0].info.return_type) == "None"
	assert state.functions[0].info.user_flags == 0
	assert state.functions[0].info.flags == 0

	assert state.functions[0].info.params.len == 2
	assert pex_file.get_string(state.functions[0].info.params[0].name) == "n1"
	assert pex_file.get_string(state.functions[0].info.params[0].typ) == "Int"
	assert pex_file.get_string(state.functions[0].info.params[1].name) == "n2"
	assert pex_file.get_string(state.functions[0].info.params[1].typ) == "Int"

	assert state.functions[0].info.locals.len == 1
	assert pex_file.get_string(state.functions[0].info.locals[0].name) == "::temp0"
	assert pex_file.get_string(state.functions[0].info.locals[0].typ) == "Int"

	assert state.functions[0].info.instructions.len == 2
	assert state.functions[0].info.instructions[0].op == pex.OpCode.iadd
	assert pex_file.get_string(state.functions[0].info.instructions[0].args[0].to_string_id()) == "::temp0"
	assert pex_file.get_string(state.functions[0].info.instructions[0].args[1].to_string_id()) == "n1"
	assert pex_file.get_string(state.functions[0].info.instructions[0].args[2].to_string_id()) == "n2"

	assert state.functions[0].info.instructions[1].op == pex.OpCode.iadd
	assert pex_file.get_string(state.functions[0].info.instructions[1].args[0].to_string_id()) == "::temp0"
	assert pex_file.get_string(state.functions[0].info.instructions[1].args[1].to_string_id()) == "::temp0"
	assert state.functions[0].info.instructions[1].args[2].to_integer() == 1
}

fn test_state_decl_3() {
	//src:		
	//		Auto State MyAutoState
	//			Function Foz(int n1, int n2)
	//				n1 + n2 + 5
	//			EndFunction
	//		EndState
	//original:
	//			name: 'MyAutoState'
	//			functions count: '1'
	//			functions:
	//			        name: 'Foz'
	//			        typ: 'None'
	//			        doc: ''
	//			        user_flags: 0x0
	//			        flags: 0x00
	//			        flags: ``
	//			        params count: '2'
	//			                Int n1
	//			                Int n2
	//			        locals count: '1'
	//			                Int ::temp1
	//			        instructions count: '2'
	//			                opcode: 'iadd', args: [ident(::temp1), ident(n1), ident(n2)]
	//			                opcode: 'iadd', args: [ident(::temp1), ident(::temp1), integer(5)]

	pex_file := compile_top('')

	obj := pex_file.get_object("ABCD") or { panic("object not found") }
	assert pex_file.get_string(obj.auto_state_name) == "MyAutoState"

	state := pex_file.get_state(obj, "MyAutoState") or { panic("state not found") }

	assert pex_file.get_string(state.name) == "MyAutoState"
	assert state.functions.len == 1
	assert pex_file.get_string(state.functions[0].name) == "Foz"
	assert pex_file.get_string(state.functions[0].info.return_type) == "None"
}

fn test_state_decl_4() {
	pex_file := compile_top('
		State ready
			Function ReadyStateFn1()
			EndFunction
		EndState
		
		State Busy
		EndState
		
		State Ready
			Function ReadyStateFn2()
			EndFunction
			Function ReadyStateFn3()
			EndFunction
		EndState

		Function ReadyStateFn1()
		EndFunction
		Function ReadyStateFn2()
		EndFunction
		Function ReadyStateFn3()
		EndFunction')

	obj := pex_file.get_object("ABCD") or { panic("object not found") }
	assert pex_file.get_string(obj.auto_state_name) == "MyAutoState"

	assert obj.states.len == 5
	state := pex_file.get_state(obj, "ready") or { panic("state not found") }

	assert pex_file.get_string(state.name) == "ready"
	assert state.functions.len == 3
	assert pex_file.get_string(state.functions[0].name) == "ReadyStateFn1"
	assert pex_file.get_string(state.functions[1].name) == "ReadyStateFn2"
	assert pex_file.get_string(state.functions[2].name) == "ReadyStateFn3"
}

fn test_object_var_decl_1() {
	pex_file := compile_top('ABCD myTestObjectVar')
	
	var := pex_file.get_var("ABCD", "myTestObjectVar") or { panic("object variable not found") }

	assert pex_file.get_string(var.name) == "myTestObjectVar"
	assert pex_file.get_string(var.type_name) == "ABCD"
	assert var.data.typ == .null
}

fn test_object_var_decl_2() {
	pex_file := compile_top('int myTestObjectVar2 = 10')
	var := pex_file.get_var("ABCD", "myTestObjectVar2") or { panic("object variable not found") }

	assert pex_file.get_string(var.name) == "myTestObjectVar2"
	assert pex_file.get_string(var.type_name) == "Int"
	assert var.data.typ == .integer
	assert var.data.to_integer() == 10
}

fn test_object_var_decl_3() {
	pex_file := compile_top('ABCD[] myTestObjectVar3')
	
	var := pex_file.get_var("ABCD", "myTestObjectVar3") or { panic("object variable not found") }

	assert pex_file.get_string(var.name) == "myTestObjectVar3"
	assert pex_file.get_string(var.type_name) == "ABCD[]"
	assert var.data.typ == .null
}

fn test_object_var_decl_4() {
	pex_file := compile_top('bool waiting')
	
	var := pex_file.get_var("ABCD", "waiting") or { panic("object variable not found") }

	assert pex_file.get_string(var.name) == "waiting"
	assert pex_file.get_string(var.type_name) == "Bool"
	assert var.data.typ == .null
}

fn test_object_var_decl_5() {
	pex_file := compile_top('int waiting')
	
	var := pex_file.get_var("ABCD", "waiting") or { panic("object variable not found") }

	assert pex_file.get_string(var.name) == "waiting"
	assert pex_file.get_string(var.type_name) == "Int"
	assert var.data.typ == .null
}

fn test_object_var_decl_6() {
	pex_file := compile_top('ABCD objVarTest = None')
	
	var := pex_file.get_var("ABCD", "objVarTest") or { panic("object variable not found") }

	assert pex_file.get_string(var.name) == "objVarTest"
	assert pex_file.get_string(var.type_name) == "ABCD"
	assert var.data.typ == .null
}

fn test_object_var_decl_7() {
	pex_file := compile_top('ABCD[] objVarTest = None')
	
	var := pex_file.get_var("ABCD", "objVarTest") or { panic("object variable not found") }

	assert pex_file.get_string(var.name) == "objVarTest"
	assert pex_file.get_string(var.type_name) == "ABCD[]"
	assert var.data.typ == .null
}

fn test_object_var_call_method() {
	// original:
	// opcode: 'callmethod', args: [ident(ParentFoz), ident(ObjVar), ident(::NoneVar), integer(2), integer(123), integer(111)]
	// opcode: 'cast', args: [ident(::temp7), none]
	// opcode: 'assign', args: [ident(ObjVar), ident(::temp7)]

	mut pex_file := compile("
		ObjVar.ParentFoz(123, 111)
		ObjVar = none")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'callmethod', args: [ident(ParentFoz), ident(ObjVar), ident(::NoneVar), integer(2), integer(123), integer(111)]"
		"opcode: 'cast', args: [ident(::temp1), none]"
		"opcode: 'assign', args: [ident(ObjVar), ident(::temp1)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_property_decl_1() {
	//src:		string Property Hello = "Hello world!" Auto
	//original:
	//			variables: 

	//			name: '::Hello_var'
	//			type name: 'String'
	//			user flags: ''
	//			data: string('Hello world!')

	//			properties:

	//			name: 'Hello'
	//			type name: 'String'
	//			doc string: ''
	//			user flags: '0x0'
	//			flags: '0x07'
	//			auto var name: '::Hello_var'

	mut pex_file := compile_top('string Property Hello = "Hello world!" Auto')
	mut prop := pex_file.get_property("ABCD", "Hello") or { panic("property not found") }

	//prop
	assert pex_file.get_string(prop.name) == "Hello"
	assert pex_file.get_string(prop.typ).to_lower() == "string"
	assert prop.user_flags == 0
	assert prop.flags == 0b0111
	assert prop.is_read()
	assert prop.is_write()
	assert prop.is_autovar()
	assert pex_file.get_string(prop.auto_var_name) == "::Hello_var"
	
	mut var := pex_file.get_var("ABCD", "::Hello_var") or {
		assert false, "variable not found"
		panic("variable not found")
	}
	assert pex_file.get_string(var.name) == "::Hello_var"
	assert pex_file.get_string(var.type_name).to_lower() == "string"
	assert var.user_flags == 0
	assert var.data.typ == .str
	assert pex_file.get_string(var.data.to_string_id()) == "Hello world!"
}

fn test_property_decl_2() {
	//src:		string Property Hello = "Hello world!" AutoReadOnly
	//original:
	//			name: 'Hello'
	//			type name: 'String'
	//			doc string: ''
	//			user flags: '0x0'
	//			flags: '0x01'
	//			read handler:
	//					typ: 'String'
	//					doc: ''
	//					user_flags: 0x0
	//					flags: 0x00
	//					flags: ``
	//					params count: '0'
	//					locals count: '0'
	//					instructions count: '1'
	//							opcode: 'ret', args: [string('Hello world!')]

	pex_file := compile_top('string Property Hello2 = "Hello world2!" AutoReadOnly')
	prop := pex_file.get_property("ABCD", "Hello2") or { panic("property not found") }

	//prop
	assert pex_file.get_string(prop.name) == "Hello2"
	assert pex_file.get_string(prop.typ).to_lower() == "string"
	assert prop.user_flags == 0
	assert prop.flags == 0b0001
	assert prop.is_read()

	//prop.prop.read_handler
	assert pex_file.get_string(prop.read_handler.return_type).to_lower() == "string"
	assert pex_file.get_string(prop.read_handler.return_type).to_lower() == "string"
	assert prop.read_handler.user_flags == 0
	assert prop.read_handler.flags == 0
	assert prop.read_handler.params.len == 0
	assert prop.read_handler.locals.len == 0
	assert prop.read_handler.instructions.len == 1
	assert prop.read_handler.instructions[0].op == pex.OpCode.ret
	assert pex_file.get_string(prop.read_handler.instructions[0].args[0].to_string_id()) == "Hello world2!"
}

fn test_property_decl_3() {
	//src:		string Property Hello3 = "Hello world3!" Auto Hidden
	//original:	
	//			name: 'Hello3'
	//			type name: 'String'
	//			doc string: ''
	//			user flags: '0x1'
	//			flags: '0x07'
	//			auto var name: '::Hello3_var'
	
	pex_file := compile_top('string Property Hello3 = "Hello world3!" Auto Hidden')
	prop := pex_file.get_property("ABCD", "Hello3") or { panic("property not found") }

	//prop
	assert pex_file.get_string(prop.name) == "Hello3"
	assert pex_file.get_string(prop.typ).to_lower() == "string"
	assert prop.user_flags == 0b0001
	assert prop.is_hidden()
	assert prop.flags == 0b0111
	assert prop.is_read()
	assert prop.is_write()
	assert prop.is_autovar()
	assert pex_file.get_string(prop.auto_var_name) == "::Hello3_var"

	//var
	var := pex_file.get_var("ABCD", "::Hello3_var") or {
		assert false, "variable not found"
		panic("variable not found")
	}
	assert pex_file.get_string(var.name) == "::Hello3_var"
	assert pex_file.get_string(var.type_name).to_lower() == "string"
	assert var.user_flags == 0
	assert var.data.typ == .str
	assert pex_file.get_string(var.data.to_string_id()) == "Hello world3!"
}

fn test_property_decl_4() {
	//src:		string Property Hello5 = "Hello world!" Auto Conditional
	//original:	
	//			name: 'Hello5'
	//			type name: 'String'
	//			doc string: ''
	//			user flags: '0x0'
	//			flags: '0x07'
	//			auto var name: '::Hello5_var'

	pex_file := compile_top('string Property Hello5 = "Hello world5!" Auto Conditional')
	prop := pex_file.get_property("ABCD", "Hello5") or { panic("property not found") }

	//prop
	assert pex_file.get_string(prop.name) == "Hello5"
	assert pex_file.get_string(prop.typ).to_lower() == "string"
	assert prop.user_flags == 0
	assert prop.flags == 0b0111
	assert prop.is_read()
	assert prop.is_write()
	assert prop.is_autovar()
	assert pex_file.get_string(prop.auto_var_name) == "::Hello5_var"

	//var
	var := pex_file.get_var("ABCD", "::Hello5_var") or {
		assert false, "variable not found"
		panic("variable not found")
	}
	assert pex_file.get_string(var.name) == "::Hello5_var"
	assert pex_file.get_string(var.type_name).to_lower() == "string"
	assert var.user_flags == 0b0010
	assert var.is_conditional()
	assert var.data.typ == .str
	assert pex_file.get_string(var.data.to_string_id()) == "Hello world5!"
}

fn test_property_decl_5() {
	//src:		
	//		int Property Hello6
	//		    Function Set(int value)
	//		        myValue = value
	//		    EndFunction
	//		    int Function Get()
	//		        return myValue
	//		    EndFunction
	//		EndProperty
	//original:
	//			name: 'Hello6'
	//			type name: 'Int'
	//			doc string: ''
	//			user flags: '0x0'
	//			flags: '0x03'
	//			read handler:
	//			        typ: 'Int'
	//			        doc: ''
	//			        user_flags: 0x0
	//			        flags: 0x00
	//			        flags: ``
	//			        params count: '0'
	//			        locals count: '0'
	//			        instructions count: '1'
	//			                opcode: 'ret', args: [ident(myValue)]
	//			write handler:
	//			        typ: 'None'
	//			        doc: ''
	//			        user_flags: 0x0
	//			        flags: 0x00
	//			        flags: ``
	//			        params count: '1'
	//			                Int value
	//			        locals count: '0'
	//			        instructions count: '1'
	//			                opcode: 'assign', args: [ident(myValue), ident(value)]

	pex_file := compile_top('int Property Hello6
								Function Set(int value)
									myValue = value
								EndFunction
								int Function Get()
									return myValue
								EndFunction
							EndProperty')
	prop := pex_file.get_property("ABCD", "Hello6") or { panic("property not found") }

	//prop
	assert pex_file.get_string(prop.name) == "Hello6"
	assert pex_file.get_string(prop.typ).to_lower() == "int"
	assert prop.user_flags == 0
	assert prop.flags == 0b0011
	assert prop.is_read()
	assert prop.is_write()

	//prop.prop.read_handler
	assert pex_file.get_string(prop.read_handler.return_type).to_lower() == "int"
	assert prop.read_handler.user_flags == 0
	assert prop.read_handler.flags == 0
	assert prop.read_handler.params.len == 0
	assert prop.read_handler.locals.len == 0
	assert prop.read_handler.instructions.len == 1
	assert prop.read_handler.instructions[0].op == pex.OpCode.ret
	assert pex_file.get_string(prop.read_handler.instructions[0].args[0].to_string_id()) == "myValue"

	//prop.prop.write_handler
	assert pex_file.get_string(prop.write_handler.return_type).to_lower() == "none"
	assert prop.write_handler.user_flags == 0
	assert prop.write_handler.flags == 0
	assert prop.write_handler.params.len == 1
	assert pex_file.get_string(prop.write_handler.params[0].name) == "value"
	assert pex_file.get_string(prop.write_handler.params[0].typ).to_lower() == "int"
	assert prop.write_handler.locals.len == 0
	assert prop.write_handler.instructions.len == 1
	assert prop.write_handler.instructions[0].op == pex.OpCode.assign
	assert pex_file.get_string(prop.write_handler.instructions[0].args[0].to_string_id()) == "myValue"
	assert pex_file.get_string(prop.write_handler.instructions[0].args[1].to_string_id()) == "value"
}

fn test_property_decl_6() {
	//src:
	//		int Property Hello7
	//		    Function Set(int value)
	//		        myValue = value
	//		    EndFunction
	//		EndProperty
	//original:	
	//			name: 'Hello7'
	//			type name: 'Int'
	//			doc string: ''
	//			user flags: '0x0'
	//			flags: '0x02'
	//			write handler:
	//			        typ: 'None'
	//			        doc: ''
	//			        user_flags: 0x0
	//			        flags: 0x00
	//			        flags: ``
	//			        params count: '1'
	//			                Int value
	//			        locals count: '0'
	//			        instructions count: '1'
	//			                opcode: 'assign', args: [ident(myValue), ident(value)]

	pex_file := compile_top('int Property Hello7
								Function Set(int value)
									myValue = value
								EndFunction
							EndProperty')
	prop := pex_file.get_property("ABCD", "Hello7") or { panic("property not found") }

	//prop
	assert pex_file.get_string(prop.name) == "Hello7"
	assert pex_file.get_string(prop.typ).to_lower() == "int"
	assert prop.user_flags == 0
	assert prop.flags == 0b0010
	assert prop.is_write()

	//prop.prop.write_handler
	assert pex_file.get_string(prop.write_handler.return_type).to_lower() == "none"
	assert prop.write_handler.user_flags == 0
	assert prop.write_handler.flags == 0
	assert prop.write_handler.params.len == 1
	assert pex_file.get_string(prop.write_handler.params[0].name) == "value"
	assert pex_file.get_string(prop.write_handler.params[0].typ).to_lower() == "int"
	assert prop.write_handler.locals.len == 0
	assert prop.write_handler.instructions.len == 1
	assert prop.write_handler.instructions[0].op == pex.OpCode.assign
	assert pex_file.get_string(prop.write_handler.instructions[0].args[0].to_string_id()) == "myValue"
	assert pex_file.get_string(prop.write_handler.instructions[0].args[1].to_string_id()) == "value"
}

fn test_property_decl_7() {
	//src:
	//		int Property Hello8
	//		    int Function Get()
	//		        return myValue
	//		    EndFunction
	//		EndProperty
	//original:	
	//			name: 'Hello8'
	//			type name: 'Int'
	//			doc string: ''
	//			user flags: '0x0'
	//			flags: '0x01'
	//			read handler:
	//			        typ: 'Int'
	//			        doc: ''
	//			        user_flags: 0x0
	//			        flags: 0x00
	//			        flags: ``
	//			        params count: '0'
	//			        locals count: '0'
	//			        instructions count: '1'
	//			                opcode: 'ret', args: [ident(myValue)]

	pex_file := compile_top('int Property Hello8
								int Function Get()
									return myValue
								EndFunction
							EndProperty')
	prop := pex_file.get_property("ABCD", "Hello8") or { panic("property not found") }

	//prop
	assert pex_file.get_string(prop.name) == "Hello8"
	assert pex_file.get_string(prop.typ).to_lower() == "int"
	assert prop.user_flags == 0
	assert prop.flags == 0b0001
	assert prop.is_read()

	//prop.prop.read_handler
	assert pex_file.get_string(prop.read_handler.return_type).to_lower() == "int"
	assert prop.read_handler.user_flags == 0
	assert prop.read_handler.flags == 0
	assert prop.read_handler.params.len == 0
	assert prop.read_handler.locals.len == 0
	assert prop.read_handler.instructions.len == 1
	assert prop.read_handler.instructions[0].op == pex.OpCode.ret
	assert pex_file.get_string(prop.read_handler.instructions[0].args[0].to_string_id()) == "myValue"
}

fn test_property_decl_8() {
	mut pex_file := compile_top('int Property Hello Auto')
	mut prop := pex_file.get_property("ABCD", "Hello") or { panic("property not found") }

	//prop
	assert pex_file.get_string(prop.name) == "Hello"
	assert pex_file.get_string(prop.typ).to_lower() == "int"
	assert prop.user_flags == 0
	assert prop.flags == 0b0111
	assert prop.is_read()
	assert prop.is_write()
	assert prop.is_autovar()
	assert pex_file.get_string(prop.auto_var_name) == "::Hello_var"
	
	mut var := pex_file.get_var("ABCD", "::Hello_var") or {
		assert false, "variable not found"
		panic("variable not found")
	}
	assert pex_file.get_string(var.name) == "::Hello_var"
	assert pex_file.get_string(var.type_name).to_lower() == "int"
	assert var.user_flags == 0
	assert var.data.typ == .null
}

fn test_property_decl_9() {
	mut pex_file := compile_top('ABCD Property Hello = None Auto')
	mut prop := pex_file.get_property("ABCD", "Hello") or { panic("property not found") }

	//prop
	assert pex_file.get_string(prop.name) == "Hello"
	assert pex_file.get_string(prop.typ).to_lower() == "abcd"
	assert prop.user_flags == 0
	assert prop.flags == 0b0111
	assert prop.is_read()
	assert prop.is_write()
	assert prop.is_autovar()
	assert pex_file.get_string(prop.auto_var_name) == "::Hello_var"
	
	mut var := pex_file.get_var("ABCD", "::Hello_var") or {
		assert false, "variable not found"
		panic("variable not found")
	}
	assert pex_file.get_string(var.name) == "::Hello_var"
	assert pex_file.get_string(var.type_name).to_lower() == "abcd"
	assert var.user_flags == 0
	assert var.data.typ == .null
}

fn test_property_decl_10() {
	mut pex_file := compile_top('ABCD[] Property Hello = None Auto')
	mut prop := pex_file.get_property("ABCD", "Hello") or { panic("property not found") }

	//prop
	assert pex_file.get_string(prop.name) == "Hello"
	assert pex_file.get_string(prop.typ).to_lower() == "abcd[]"
	assert prop.user_flags == 0
	assert prop.flags == 0b0111
	assert prop.is_read()
	assert prop.is_write()
	assert prop.is_autovar()
	assert pex_file.get_string(prop.auto_var_name) == "::Hello_var"
	
	mut var := pex_file.get_var("ABCD", "::Hello_var") or {
		assert false, "variable not found"
		panic("variable not found")
	}
	assert pex_file.get_string(var.name) == "::Hello_var"
	assert pex_file.get_string(var.type_name).to_lower() == "abcd[]"
	assert var.user_flags == 0
	assert var.data.typ == .null
}

fn test_property_get_infix() {
	//src:			myAutoProp + 4
	//original:		opcode: 'iadd', args: [ident(::temp2), ident(::myAutoProp_var), integer(4)]
   
	mut pex_file := compile("myAutoProp + 4")
	mut ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.iadd
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "::temp0"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "::myAutoProp_var"
	assert ins[0].args[2].to_integer() == 4

	//src:			obj.myAutoProp + 14
	//original:		opcode: 'propget', args: [ident(myAutoProp), ident(obj), ident(::temp2)]
    //				opcode: 'iadd', args: [ident(::temp2), ident(::temp2), integer(14)]
   
	pex_file = compile("obj.myAutoProp + 14")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.propget
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "myAutoProp"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "obj"
	assert pex_file.get_string(ins[0].args[2].to_string_id()) == "::temp0"

	assert ins[1].op == pex.OpCode.iadd
	assert pex_file.get_string(ins[1].args[0].to_string_id()) == "::temp0"
	assert pex_file.get_string(ins[1].args[1].to_string_id()) == "::temp0"
	assert ins[1].args[2].to_integer() == 14
}

fn test_property_get_call_method() {
	// original:
	// opcode: 'callmethod', args: [ident(ParentFoz), ident(::ParentObjAutoProp_var), ident(::NoneVar), integer(2), integer(123), integer(111)]
	// opcode: 'cast', args: [ident(::temp7), none]
	// opcode: 'assign', args: [ident(::ParentObjAutoProp_var), ident(::temp7)]
	
	mut pex_file := compile("
		ParentObjAutoProp.ParentFoz(123, 111)
		ParentObjAutoProp = none")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'callmethod', args: [ident(ParentFoz), ident(::ParentObjAutoProp_var), ident(::NoneVar), integer(2), integer(123), integer(111)]"
		"opcode: 'cast', args: [ident(::temp1), none]"
		"opcode: 'assign', args: [ident(::ParentObjAutoProp_var), ident(::temp1)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_property_get_call_method2() {
	// original:
	// opcode: 'propget', args: [ident(ParentObjFullProp), ident(self), ident(::temp7)]
	// opcode: 'callmethod', args: [ident(ParentFoz), ident(::temp7), ident(::NoneVar), integer(2), integer(123), integer(111)]
	// opcode: 'cast', args: [ident(::temp8), none]
	// opcode: 'assign', args: [ident(::temp7), ident(::temp8)]
	// opcode: 'propset', args: [ident(ParentObjFullProp), ident(self), ident(::temp7)]
	
	mut pex_file := compile("
		ParentObjFullProp.ParentFoz(123, 111)
		ParentObjFullProp = none")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'propget', args: [ident(ParentObjFullProp), ident(self), ident(::temp1)]"
		"opcode: 'callmethod', args: [ident(ParentFoz), ident(::temp1), ident(::NoneVar), integer(2), integer(123), integer(111)]"
		"opcode: 'cast', args: [ident(::temp1), none]"
		"opcode: 'propset', args: [ident(ParentObjFullProp), ident(self), ident(::temp1)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_static_call() {
	//src:			Foo(11, 12)
	//original:		opcode: 'callstatic', args: [ident(ABCD), ident(Foo), ident(::NoneVar), integer(2), integer(11), integer(12)]

	mut pex_file := compile("Foo(11, 12)")
	mut ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callstatic
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "ABCD"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "Foo"
	assert pex_file.get_string(ins[0].args[2].to_string_id()) == "::NoneVar"
	assert ins[0].args[3].to_integer() == 2 // number of additional arguments
	assert ins[0].args[4].to_integer() == 11
	assert ins[0].args[5].to_integer() == 12

	//src:			ABCD.Foo(13, 14)
	//original:		opcode: 'callstatic', args: [ident(ABCD), ident(Foo), ident(::NoneVar), integer(2), integer(13), integer(14)]

	pex_file = compile("ABCD.Foo(13, 14)")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callstatic
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "ABCD"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "Foo"
	assert pex_file.get_string(ins[0].args[2].to_string_id()) == "::NoneVar"
	assert ins[0].args[3].to_integer() == 2 // number of additional arguments
	assert ins[0].args[4].to_integer() == 13
	assert ins[0].args[5].to_integer() == 14
}

fn test_method_call() {
	//src:			Foz(15, 16)
	//original:		opcode: 'callmethod', args: [ident(Foz), ident(self), ident(::NoneVar), integer(2), integer(15), integer(16)]

	mut pex_file := compile("Foz(15, 16)")
	mut ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "Foz"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "self"
	assert pex_file.get_string(ins[0].args[2].to_string_id()) == "::NoneVar"
	assert ins[0].args[3].to_integer() == 2 // number of additional arguments
	assert ins[0].args[4].to_integer() == 15
	assert ins[0].args[5].to_integer() == 16

	//src:			self.Foz(17, 18)
	//original:		opcode: 'callmethod', args: [ident(Foz), ident(self), ident(::NoneVar), integer(2), integer(17), integer(18)]

	pex_file = compile("self.Foz(17, 18)")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "Foz"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "self"
	assert pex_file.get_string(ins[0].args[2].to_string_id()) == "::NoneVar"
	assert ins[0].args[3].to_integer() == 2 // number of additional arguments
	assert ins[0].args[4].to_integer() == 17
	assert ins[0].args[5].to_integer() == 18

	//src:			obj.Foz(25, 26)
	//original:		opcode: 'callmethod', args: [ident(Foz), ident(obj), ident(::NoneVar), integer(2), integer(25), integer(26)]

	pex_file = compile("obj.Foz(25, 26)")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "Foz"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "obj"
	assert pex_file.get_string(ins[0].args[2].to_string_id()) == "::NoneVar"
	assert ins[0].args[3].to_integer() == 2 // number of additional arguments
	assert ins[0].args[4].to_integer() == 25
	assert ins[0].args[5].to_integer() == 26

	//src:			ABCD[] x = new ABCD[5]
	//				x[1].Foz(25, 26)
	//original:		opcode: 'array_create', args: [ident(::temp0), integer(5)]
	//				opcode: 'assign', args: [ident(x), ident(::temp0)]
	//				opcode: 'array_getelement', args: [ident(::temp1), ident(x), integer(1)]
	//				opcode: 'callmethod', args: [ident(Foz), ident(::temp1), ident(::NoneVar), integer(2), integer(25), integer(26)]
	//my:			opcode: 'array_create', args: [ident(::temp2), integer(5)]
	//				opcode: 'assign', args: [ident(x), ident(::temp2)]
	//				opcode: 'array_getelement', args: [ident(::temp3), ident(x), integer(1)]
	//				opcode: 'callmethod', args: [ident(Foz), ident(::temp3), ident(::NoneVar), integer(2), integer(25), integer(26)]
	
	pex_file = compile(
		"ABCD[] x = new ABCD[5]\n" +
		"x[1].Foz(25, 26)"
	)
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.array_create
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "::temp1"
	assert ins[0].args[1].to_integer() == 5

	assert ins[1].op == pex.OpCode.assign
	assert pex_file.get_string(ins[1].args[0].to_string_id()) == "x"
	assert pex_file.get_string(ins[1].args[1].to_string_id()) == "::temp1"

	assert ins[2].op == pex.OpCode.array_getelement
	assert pex_file.get_string(ins[2].args[0].to_string_id()) == "::temp3"
	assert pex_file.get_string(ins[2].args[1].to_string_id()) == "x"
	assert ins[2].args[2].to_integer() == 1

	assert ins[3].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[3].args[0].to_string_id()) == "Foz"
	assert pex_file.get_string(ins[3].args[1].to_string_id()) == "::temp3"
	assert pex_file.get_string(ins[3].args[2].to_string_id()) == "::NoneVar"
	assert ins[3].args[3].to_integer() == 2 // number of additional arguments
	assert ins[3].args[4].to_integer() == 25
	assert ins[3].args[5].to_integer() == 26
}

fn test_parent_method_call() {
	//src:			ParentFoz(19, 20)
	//original:		opcode: 'callmethod', args: [ident(ParentFoz), ident(self), ident(::NoneVar), integer(2), integer(19), integer(20)]

	mut pex_file := compile("ParentFoz(19, 20)")
	mut ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "ParentFoz"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "self"
	assert pex_file.get_string(ins[0].args[2].to_string_id()) == "::NoneVar"
	assert ins[0].args[3].to_integer() == 2 // number of additional arguments
	assert ins[0].args[4].to_integer() == 19
	assert ins[0].args[5].to_integer() == 20

	//src:			Parent.ParentFoz(21, 22)
	//original:		opcode: 'callparent', args: [ident(ParentFoz), ident(::NoneVar), integer(2), integer(21), integer(22)]

	pex_file = compile("Parent.ParentFoz(21, 22)")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callparent
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "ParentFoz"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "::NoneVar"
	assert ins[0].args[2].to_integer() == 2 // number of additional arguments
	assert ins[0].args[3].to_integer() == 21
	assert ins[0].args[4].to_integer() == 22

	//src:			obj.ParentFoz(23, 24)
	//original:		opcode: 'callmethod', args: [ident(ParentFoz), ident(obj), ident(::NoneVar), integer(2), integer(23), integer(24)]

	pex_file = compile("obj.ParentFoz(23, 24)")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "ParentFoz"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "obj"
	assert pex_file.get_string(ins[0].args[2].to_string_id()) == "::NoneVar"
	assert ins[0].args[3].to_integer() == 2 // number of additional arguments
	assert ins[0].args[4].to_integer() == 23
	assert ins[0].args[5].to_integer() == 24
}

fn test_call_event() {
	//src: 			OnInit()
	//original:		opcode: 'callmethod', args: [ident(OnInit), ident(self), ident(::NoneVar), integer(0)]
	//my:			opcode: 'callmethod', args: [ident(OnInit), ident(self), ident(::NoneVar), integer(0)]

	pex_file := compile("OnInit()")
	ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "OnInit"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "self"
	assert pex_file.get_string(ins[0].args[2].to_string_id()) == "::NoneVar"
	assert ins[0].args[3].to_integer() == 0 // number of additional arguments
}

fn test_assign_base_types() {
	// original:
	// opcode: 'cast', args: [ident(::temp7), string('foo 123')]
	// opcode: 'assign', args: [ident(Var1), ident(::temp7)]
	// opcode: 'assign', args: [ident(Var2), boolean(01)]
	// opcode: 'cast', args: [ident(::temp7), none]
	// opcode: 'assign', args: [ident(Var3), ident(::temp7)]
	// opcode: 'assign', args: [ident(Var4), integer(123)]
	// opcode: 'assign', args: [ident(Var5), float(1.1674)]
	// opcode: 'cast', args: [ident(::temp8), integer(117)]
	// opcode: 'assign', args: [ident(Var6), ident(::temp8)]
	// opcode: 'assign', args: [ident(Var7), string('foo 123')]
	// opcode: 'cast', args: [ident(::temp9), boolean(01)]
	// opcode: 'assign', args: [ident(Var8), ident(::temp9)]
	// opcode: 'cast', args: [ident(::temp9), none]
	// opcode: 'assign', args: [ident(Var9), ident(::temp9)]
	// opcode: 'cast', args: [ident(::temp9), integer(123)]
	// opcode: 'assign', args: [ident(Var10), ident(::temp9)]

	mut pex_file := compile("
		Bool Var1 = \"foo 123\"
		Bool Var2 = True
		Bool Var3 = None
		Int Var4 = 123
		Float Var5 = 1.1674
		Float Var6 = 117
		String Var7 = \"foo 123\"
		String Var8 = True
		String Var9 = None
		String Var10 = 123")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'cast', args: [ident(::temp1), string('foo 123')]"
		"opcode: 'assign', args: [ident(Var1), ident(::temp1)]"
		"opcode: 'assign', args: [ident(Var2), boolean(01)]"
		"opcode: 'cast', args: [ident(::temp1), none]"
		"opcode: 'assign', args: [ident(Var3), ident(::temp1)]"
		"opcode: 'assign', args: [ident(Var4), integer(123)]"
		"opcode: 'assign', args: [ident(Var5), float(1.1674)]"
		"opcode: 'cast', args: [ident(::temp7), integer(117)]"
		"opcode: 'assign', args: [ident(Var6), ident(::temp7)]"
		"opcode: 'assign', args: [ident(Var7), string('foo 123')]"
		"opcode: 'cast', args: [ident(::temp10), boolean(01)]"
		"opcode: 'assign', args: [ident(Var8), ident(::temp10)]"
		"opcode: 'cast', args: [ident(::temp10), none]"
		"opcode: 'assign', args: [ident(Var9), ident(::temp10)]"
		"opcode: 'cast', args: [ident(::temp10), integer(123)]"
		"opcode: 'assign', args: [ident(Var10), ident(::temp10)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_assign_array() {
	// original:
	// opcode: 'cast', args: [ident(::temp7), none]
	// opcode: 'assign', args: [ident(myArray1), ident(::temp7)]
	// opcode: 'array_create', args: [ident(::temp7), integer(7)]
	// opcode: 'assign', args: [ident(myArray2), ident(::temp7)]
	
	mut pex_file := compile("
		ABCD[] myArray1 = none
		ABCD[] myArray2 = new ABCD[7]")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'cast', args: [ident(::temp1), none]"
		"opcode: 'assign', args: [ident(myArray1), ident(::temp1)]"
		"opcode: 'array_create', args: [ident(::temp1), integer(7)]"
		"opcode: 'assign', args: [ident(myArray2), ident(::temp1)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_assign_obj() {
	// original:
	// opcode: 'cast', args: [ident(::temp7), none]
	// opcode: 'assign', args: [ident(var1), ident(::temp7)]
	// opcode: 'assign', args: [ident(var2), ident(obj)]
	// opcode: 'cast', args: [ident(::temp7), ident(obj2)]
	// opcode: 'assign', args: [ident(var3), ident(::temp7)]
	// opcode: 'cast', args: [ident(::temp8), ident(obj)]
	// opcode: 'assign', args: [ident(var4), ident(::temp8)]

	mut pex_file := compile("
	ABCD var1 = none
    ABCD var2 = obj
    ABCD var3 = obj2 as ABCD
    CDFG var4 = obj")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'cast', args: [ident(::temp1), none]"
		"opcode: 'assign', args: [ident(var1), ident(::temp1)]"
		"opcode: 'assign', args: [ident(var2), ident(obj)]"
		"opcode: 'cast', args: [ident(::temp1), ident(obj2)]"
		"opcode: 'assign', args: [ident(var3), ident(::temp1)]"
		"opcode: 'cast', args: [ident(::temp5), ident(obj)]"
		"opcode: 'assign', args: [ident(var4), ident(::temp5)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_property_assign() {
	//src:			myAutoProp = 5
	//original:		opcode: 'assign', args: [ident(::myAutoProp_var), integer(5)]
   
	mut pex_file := compile("myAutoProp = 5")
	mut ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.assign
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "::myAutoProp_var"
	assert ins[0].args[1].to_integer() == 5

	//src:			obj.myAutoProp = 15
	//original:		opcode: 'assign', args: [ident(::temp2), integer(15)]
	//				opcode: 'propset', args: [ident(myAutoProp), ident(obj), ident(::temp2)]
   
	pex_file = compile("obj.myAutoProp = 15")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.propset
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "myAutoProp"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "obj"
	assert ins[0].args[2].to_integer() == 15
}

fn test_new_array() {
	// original: 
	// opcode: 'array_create', args: [ident(::temp7), integer(14)]
	// opcode: 'assign', args: [ident(intVar), ident(::temp7)]

	mut pex_file := compile("Int[] intVar = new Int[14]")
	mut ins := get_instructions(pex_file)
	
	//ins 1
	assert ins[0].op == pex.OpCode.array_create

	assert ins[0].args[0].typ == .identifier
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "::temp1"
	
	assert ins[0].args[1].typ == .integer
	assert ins[0].args[1].to_integer() == 14
	
	//ins 2
	assert ins[1].op == pex.OpCode.assign

	assert ins[1].args[0].typ == .identifier
	assert pex_file.get_string(ins[1].args[0].to_string_id()) == "intVar"

	assert ins[1].args[1].typ == .identifier
	assert pex_file.get_string(ins[1].args[1].to_string_id()) == "::temp1"
}

fn test_array_length() {
	// original:
	// opcode: 'array_length', args: [ident(::temp7), ident(intVar)]
	// opcode: 'assign', args: [ident(len), ident(::temp7)]

	mut pex_file := compile("Int[] intVar\nint len = intVar.Length")
	mut ins := get_instructions(pex_file)

	//ins 1
	assert ins[0].op == pex.OpCode.array_length

	assert ins[0].args[0].typ == .identifier
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "::temp2"

	assert ins[0].args[1].typ == .identifier
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "intVar"

	//ins 2
	assert ins[1].op == pex.OpCode.assign

	assert ins[1].args[0].typ == .identifier
	assert pex_file.get_string(ins[1].args[0].to_string_id()) == "len"

	assert ins[1].args[1].typ == .identifier
	assert pex_file.get_string(ins[1].args[1].to_string_id()) == "::temp2"
}

fn test_array_find() {
	// original:
	// opcode: 'cast', args: [ident(::temp7), none]
	// opcode: 'assign', args: [ident(myArray), ident(::temp7)]
	// opcode: 'cast', args: [ident(::temp8), none]
	// opcode: 'array_findelement', args: [ident(myArray), ident(::temp9), ident(::temp8), integer(0)]
	// opcode: 'assign', args: [ident(myIndex1), ident(::temp9)]
	// opcode: 'array_findelement', args: [ident(myArray), ident(::temp9), ident(obj), integer(1)]
	// opcode: 'assign', args: [ident(myIndex2), ident(::temp9)]

	mut pex_file := compile("
		ABCD[] myArray = none
		int myIndex1 = myArray.Find(none)
		int myIndex2 = myArray.Find(obj, 1)")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'cast', args: [ident(::temp1), none]"
		"opcode: 'assign', args: [ident(myArray), ident(::temp1)]"
		"opcode: 'cast', args: [ident(::temp4), none]"
		"opcode: 'array_findelement', args: [ident(myArray), ident(::temp3), ident(::temp4), integer(0)]"
		"opcode: 'assign', args: [ident(myIndex1), ident(::temp3)]"
		"opcode: 'array_findelement', args: [ident(myArray), ident(::temp3), ident(obj), integer(1)]"
		"opcode: 'assign', args: [ident(myIndex2), ident(::temp3)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_array_rfind() {
	// original:
	// opcode: 'cast', args: [ident(::temp7), none]
	// opcode: 'assign', args: [ident(myArray), ident(::temp7)]
	// opcode: 'cast', args: [ident(::temp8), none]
	// opcode: 'array_rfindelement', args: [ident(myArray), ident(::temp9), ident(::temp8), integer(-1)]
	// opcode: 'assign', args: [ident(myIndex1), ident(::temp9)]
	// opcode: 'array_rfindelement', args: [ident(myArray), ident(::temp9), ident(obj), integer(6)]
	// opcode: 'assign', args: [ident(myIndex2), ident(::temp9)]

	mut pex_file := compile("
		ABCD[] myArray = none
		int myIndex1 = myArray.RFind(none)
		int myIndex2 = myArray.RFind(obj, 6)")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'cast', args: [ident(::temp1), none]"
		"opcode: 'assign', args: [ident(myArray), ident(::temp1)]"
		"opcode: 'cast', args: [ident(::temp4), none]"
		"opcode: 'array_rfindelement', args: [ident(myArray), ident(::temp3), ident(::temp4), integer(-1)]"
		"opcode: 'assign', args: [ident(myIndex1), ident(::temp3)]"
		"opcode: 'array_rfindelement', args: [ident(myArray), ident(::temp3), ident(obj), integer(6)]"
		"opcode: 'assign', args: [ident(myIndex2), ident(::temp3)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}

}

fn test_array_get_element() {
	//	original:
	// opcode: 'cast', args: [ident(::temp7), none]
	// opcode: 'assign', args: [ident(myArray), ident(::temp7)]
	// opcode: 'array_getelement', args: [ident(::temp8), ident(myArray), integer(0)]
	// opcode: 'assign', args: [ident(Var), ident(::temp8)]
	// opcode: 'cast', args: [ident(::temp9), none]
	// opcode: 'assign', args: [ident(myArray2), ident(::temp9)]
	// opcode: 'array_getelement', args: [ident(::temp10), ident(myArray2), integer(0)]
	// opcode: 'assign', args: [ident(Var2), ident(::temp10)]
	
	mut pex_file := compile("
		ABCD[] myArray = none
		ABCD Var = myArray[0]
		String[] myArray2 = none
		String Var2 = myArray2[0]")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'cast', args: [ident(::temp1), none]"
		"opcode: 'assign', args: [ident(myArray), ident(::temp1)]"
		"opcode: 'array_getelement', args: [ident(::temp3), ident(myArray), integer(0)]"
		"opcode: 'assign', args: [ident(Var), ident(::temp3)]"
		"opcode: 'cast', args: [ident(::temp5), none]"
		"opcode: 'assign', args: [ident(myArray2), ident(::temp5)]"
		"opcode: 'array_getelement', args: [ident(::temp7), ident(myArray2), integer(0)]"
		"opcode: 'assign', args: [ident(Var2), ident(::temp7)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_array_set_element() {
	// original:
	// opcode: 'cast', args: [ident(::temp7), none]
	// opcode: 'assign', args: [ident(myArray), ident(::temp7)]
	// opcode: 'cast', args: [ident(::temp9), none]
	// opcode: 'assign', args: [ident(::temp8), ident(::temp9)]
	// opcode: 'array_setelement', args: [ident(myArray), integer(0), ident(::temp8)]
	// opcode: 'assign', args: [ident(::temp9), ident(obj)]
	// opcode: 'array_setelement', args: [ident(myArray), integer(0), ident(::temp9)]
	// opcode: 'cast', args: [ident(::temp10), none]
	// opcode: 'assign', args: [ident(myArray2), ident(::temp10)]
	// opcode: 'assign', args: [ident(::temp11), string('sadqw')]
	// opcode: 'array_setelement', args: [ident(myArray2), integer(0), ident(::temp11)]
	// opcode: 'cast', args: [ident(::temp12), integer(123)]
	// opcode: 'assign', args: [ident(::temp11), ident(::temp12)]
	// opcode: 'array_setelement', args: [ident(myArray2), integer(0), ident(::temp11)]

	mut pex_file := compile("
		ABCD[] myArray = none
		myArray[0] = none
		myArray[0] = obj
		String[] myArray2 = none
		myArray2[0] = \"sadqw\"
		myArray2[0] = 123")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'cast', args: [ident(::temp1), none]"
		"opcode: 'assign', args: [ident(myArray), ident(::temp1)]"
		"opcode: 'cast', args: [ident(::temp2), none]"
		//"opcode: 'assign', args: [ident(::temp8), ident(::temp9)]"
		"opcode: 'array_setelement', args: [ident(myArray), integer(0), ident(::temp2)]"
		//"opcode: 'assign', args: [ident(::temp9), ident(obj)]"
		"opcode: 'array_setelement', args: [ident(myArray), integer(0), ident(obj)]"
		"opcode: 'cast', args: [ident(::temp4), none]"
		"opcode: 'assign', args: [ident(myArray2), ident(::temp4)]"
		//"opcode: 'assign', args: [ident(::temp11), string('sadqw')]"
		"opcode: 'array_setelement', args: [ident(myArray2), integer(0), string('sadqw')]"
		"opcode: 'cast', args: [ident(::temp5), integer(123)]"
		//"opcode: 'assign', args: [ident(::temp11), ident(::temp12)]"
		"opcode: 'array_setelement', args: [ident(myArray2), integer(0), ident(::temp5)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_array_str_concat() {
	//	original:
	// opcode: 'strcat', args: [ident(::temp7), string('Hello '), string('World')]
    // opcode: 'assign', args: [ident(myStr), ident(::temp7)]

	mut pex_file := compile("string myStr = \"Hello \" + \"World\"")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'strcat', args: [ident(::temp1), string('Hello '), string('World')]"
    	"opcode: 'assign', args: [ident(myStr), ident(::temp1)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_if() {
	// original:
	// opcode: 'assign', args: [ident(val), integer(1)]
	// opcode: 'cmp_gt', args: [ident(::temp7), ident(val), integer(0)]
	// opcode: 'jmpf', args: [ident(::temp7), integer(3)]
	// opcode: 'assign', args: [ident(val), integer(3)]
	// opcode: 'jmp', args: [integer(5)]
	// opcode: 'jmpf', args: [boolean(01), integer(3)]
	// opcode: 'assign', args: [ident(val), integer(4)]
	// opcode: 'jmp', args: [integer(2)]
	// opcode: 'assign', args: [ident(val), integer(5)]
	
	mut pex_file := compile("
		int val = 1
		if val > 0
			val = 3
		ElseIf (true)
			val = 4
		Else
			val = 5
		EndIf")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'assign', args: [ident(val), integer(1)]"
		"opcode: 'cmp_gt', args: [ident(::temp1), ident(val), integer(0)]"
		"opcode: 'jmpf', args: [ident(::temp1), integer(3)]"
		"opcode: 'assign', args: [ident(val), integer(3)]"
		"opcode: 'jmp', args: [integer(5)]"
		"opcode: 'jmpf', args: [boolean(01), integer(3)]"
		"opcode: 'assign', args: [ident(val), integer(4)]"
		"opcode: 'jmp', args: [integer(2)]"
		"opcode: 'assign', args: [ident(val), integer(5)]"
	]
	
	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_while() {
	// original:
	// opcode: 'assign', args: [ident(val), integer(1)]
	// opcode: 'iadd', args: [ident(::temp7), integer(131), integer(125)]
	// opcode: 'cmp_gt', args: [ident(::temp8), ident(::temp7), integer(1)]
	// opcode: 'jmpf', args: [ident(::temp8), integer(3)]
	// opcode: 'assign', args: [ident(val), integer(4)]
	// opcode: 'jmp', args: [integer(-4)]
	
	mut pex_file := compile("
		int val = 1
		While (131 + 125) > 1
			val = 4
		EndWhile")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'assign', args: [ident(val), integer(1)]"
		"opcode: 'iadd', args: [ident(::temp1), integer(131), integer(125)]"
		"opcode: 'cmp_gt', args: [ident(::temp2), ident(::temp1), integer(1)]"
		"opcode: 'jmpf', args: [ident(::temp2), integer(3)]"
		"opcode: 'assign', args: [ident(val), integer(4)]"
		"opcode: 'jmp', args: [integer(-4)]"
	]
	
	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_while2() {
	// original:
	// opcode: 'assign', args: [ident(val), integer(1)]
    // opcode: 'iadd', args: [ident(::temp7), integer(131), integer(125)]
    // opcode: 'cmp_gt', args: [ident(::temp8), ident(::temp7), integer(1)]
    // opcode: 'jmpf', args: [ident(::temp8), integer(12)]
    // opcode: 'assign', args: [ident(val2), integer(1)]
    // opcode: 'cmp_gt', args: [ident(::temp9), ident(val2), integer(0)]
    // opcode: 'jmpf', args: [ident(::temp9), integer(3)]
    // opcode: 'assign', args: [ident(val2), integer(3)]
    // opcode: 'jmp', args: [integer(5)]
    // opcode: 'jmpf', args: [boolean(01), integer(3)]
    // opcode: 'assign', args: [ident(val2), integer(4)]
    // opcode: 'jmp', args: [integer(2)]
    // opcode: 'assign', args: [ident(val2), integer(5)]
    // opcode: 'assign', args: [ident(val), integer(5)]
    // opcode: 'jmp', args: [integer(-13)]
	
	mut pex_file := compile("
		int val = 1
		While (131 + 125) > 1
			int val2 = 1
			if val2 > 0
				val2 = 3
			ElseIf (true)
				val2 = 4
			Else
				val2 = 5
			EndIf
			val = 5
		EndWhile")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'assign', args: [ident(val), integer(1)]"
        "opcode: 'iadd', args: [ident(::temp1), integer(131), integer(125)]"
        "opcode: 'cmp_gt', args: [ident(::temp2), ident(::temp1), integer(1)]"
        "opcode: 'jmpf', args: [ident(::temp2), integer(12)]"
        "opcode: 'assign', args: [ident(val2), integer(1)]"
        "opcode: 'cmp_gt', args: [ident(::temp2), ident(val2), integer(0)]"
        "opcode: 'jmpf', args: [ident(::temp2), integer(3)]"
        "opcode: 'assign', args: [ident(val2), integer(3)]"
        "opcode: 'jmp', args: [integer(5)]"
        "opcode: 'jmpf', args: [boolean(01), integer(3)]"
        "opcode: 'assign', args: [ident(val2), integer(4)]"
        "opcode: 'jmp', args: [integer(2)]"
        "opcode: 'assign', args: [ident(val2), integer(5)]"
        "opcode: 'assign', args: [ident(val), integer(5)]"
        "opcode: 'jmp', args: [integer(-13)]"
	]

	assert ins.len == expected.len
	
	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_call() {
	mut pex_file := compile("obj2.Foz()")
	mut ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert ins[0].args.len == 4
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "Foz"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "obj2"
	assert pex_file.get_string(ins[0].args[2].to_string_id()) == "::NoneVar"
	assert ins[0].args[3].to_integer() == 0 // number of additional arguments
	
	pex_file = compile("obj2.Foo()")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert ins[0].args.len == 4
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "Foo"
	assert pex_file.get_string(ins[0].args[1].to_string_id()) == "obj2"
	assert pex_file.get_string(ins[0].args[2].to_string_id()) == "::NoneVar"
	assert ins[0].args[3].to_integer() == 0 // number of additional arguments

	pex_file = compile("GetOtherObject().Foo()")
	ins = get_instructions(pex_file)

	assert ins.len == 2
	assert ins[0].op == pex.OpCode.callstatic
	assert ins[1].op == pex.OpCode.callmethod
	assert ins[1].args.len == 4
	assert pex_file.get_string(ins[1].args[0].to_string_id()) == "Foo"
	assert pex_file.get_string(ins[1].args[1].to_string_id()) == "::temp1"
	assert pex_file.get_string(ins[1].args[2].to_string_id()) == "::NoneVar"
	assert ins[1].args[3].to_integer() == 0 // number of additional arguments

	pex_file = compile("GetOtherObject().Foz()")
	ins = get_instructions(pex_file)

	assert ins.len == 2
	assert ins[0].op == pex.OpCode.callstatic
	assert ins[1].op == pex.OpCode.callmethod
	assert ins[1].args.len == 4
	assert pex_file.get_string(ins[1].args[0].to_string_id()) == "Foz"
	assert pex_file.get_string(ins[1].args[1].to_string_id()) == "::temp1"
	assert pex_file.get_string(ins[1].args[2].to_string_id()) == "::NoneVar"
	assert ins[1].args[3].to_integer() == 0 // number of additional arguments
}

fn test_call_cast() {
	// original:
	//opcode: 'cast', args: [ident(::temp7), ident(obj)]
	//opcode: 'callmethod', args: [ident(FuncWithPObjArg), ident(self), ident(::NoneVar), integer(1), ident(::temp7)]
	//opcode: 'callmethod', args: [ident(FuncWithObjArg), ident(self), ident(::NoneVar), integer(1), ident(obj)]
	//opcode: 'cast', args: [ident(::temp8), none]
	//opcode: 'callmethod', args: [ident(FuncWithObjArg), ident(self), ident(::NoneVar), integer(1), ident(::temp8)]
	//opcode: 'callmethod', args: [ident(FuncWithOptionalObjArg), ident(self), ident(::NoneVar), integer(1), ident(obj)]
	//opcode: 'cast', args: [ident(::temp8), none]
	//opcode: 'callmethod', args: [ident(FuncWithOptionalObjArg), ident(self), ident(::NoneVar), integer(1), ident(::temp8)]
	//opcode: 'callmethod', args: [ident(FuncWithOptionalObjArg), ident(self), ident(::NoneVar), integer(1), none]
	
	mut pex_file := compile("
		FuncWithPObjArg(obj)
		FuncWithObjArg(obj)
		FuncWithObjArg(none)
		FuncWithOptionalObjArg(obj)
		FuncWithOptionalObjArg(none)
		FuncWithOptionalObjArg()")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'cast', args: [ident(::temp1), ident(obj)]"
		"opcode: 'callmethod', args: [ident(FuncWithPObjArg), ident(self), ident(::NoneVar), integer(1), ident(::temp1)]"
		"opcode: 'callmethod', args: [ident(FuncWithObjArg), ident(self), ident(::NoneVar), integer(1), ident(obj)]"
		"opcode: 'cast', args: [ident(::temp2), none]"
		"opcode: 'callmethod', args: [ident(FuncWithObjArg), ident(self), ident(::NoneVar), integer(1), ident(::temp2)]"
		"opcode: 'callmethod', args: [ident(FuncWithOptionalObjArg), ident(self), ident(::NoneVar), integer(1), ident(obj)]"
		"opcode: 'cast', args: [ident(::temp2), none]"
		"opcode: 'callmethod', args: [ident(FuncWithOptionalObjArg), ident(self), ident(::NoneVar), integer(1), ident(::temp2)]"
		"opcode: 'callmethod', args: [ident(FuncWithOptionalObjArg), ident(self), ident(::NoneVar), integer(1), none]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_free_temp_var() {
	// original:
	// opcode: 'callmethod', args: [ident(GetChildObj), ident(obj), ident(::temp7), integer(0)]
	// opcode: 'callmethod', args: [ident(GetChildObj), ident(pobj), ident(::temp8), integer(0)]
	// opcode: 'callmethod', args: [ident(FuncWithObjArg), ident(::temp7), ident(::NoneVar), integer(1), ident(::temp8)]
	
	mut pex_file := compile("obj.GetChildObj().FuncWithObjArg(pobj.GetChildObj())")

	mut ins := get_instructions(pex_file)

	expected := [
		"opcode: 'callmethod', args: [ident(GetChildObj), ident(obj), ident(::temp1), integer(0)]"
		"opcode: 'callmethod', args: [ident(GetChildObj), ident(pobj), ident(::temp2), integer(0)]"
		"opcode: 'callmethod', args: [ident(FuncWithObjArg), ident(::temp1), ident(::NoneVar), integer(1), ident(::temp2)]"
	]

	assert ins.len == expected.len

	for i in 0 .. expected.len {
		assert ins[i].to_string(pex_file) == expected[i]
	}
}

fn test_foo() { // ???
	pex_file := compile("int n = 1 + 2")
	ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.iadd
	assert pex_file.get_string(ins[0].args[0].to_string_id()) == "::temp1"
	assert ins[0].args[1].to_integer() == 1
	assert ins[0].args[2].to_integer() == 2
	
	assert ins[1].op == pex.OpCode.assign
	assert pex_file.get_string(ins[1].args[0].to_string_id()) == "n"
	assert pex_file.get_string(ins[1].args[1].to_string_id()) == "::temp1"
}