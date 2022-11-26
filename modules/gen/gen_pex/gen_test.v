import papyrus.ast
import papyrus.parser
import papyrus.checker
import pex
import gen_pex
import pref

const (
	prefs = pref.Preferences {
		paths: []string{}
		out_dir: []string{}
		mode: .compile
		backend: .pex
		no_cache: true
		crutches_enabled: false
	}

	parent_src =
		"Scriptname CDFG\n" +

		"Function ParentFoz(int n1, int n2)\n" +
		"EndFunction"

	src_template = 
"Scriptname ABCD extends CDFG

Auto State MyAutoState
    Function Foz(int n1, int n2)
        n1 + n2 + 5
    EndFunction
EndState

State MyState
EndState

int myValue = 0

int Property myAutoProp = 123 Auto
int Property myAutoReadProp = 123 AutoReadOnly

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
	full_src := "${src_template}Function Bar(string v, ABCD obj)\n${src}\nEndFunction\n"
	table := ast.new_table()
	global_scope := &ast.Scope{
		parent: 0
	}
	
	mut parent_file := parser.parse_text("::gen_test.v/parent::", parent_src, table, prefs, global_scope)
	mut file := parser.parse_text("::gen_test.v/src::", full_src, table, prefs, global_scope)

	mut c := checker.new_checker(table, prefs)

	c.check(mut parent_file)
	c.check(mut file)

	assert c.errors.len == 0

	pex_file := gen_pex.gen_pex_file(file, table, prefs)
	return pex_file
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

fn test_object_var_1() {
	pex_file := compile_top('ABCD myTestObjectVar')
	
	var := pex_file.get_var("ABCD", "myTestObjectVar") or { panic("object variable not found") }

	assert pex_file.get_string(var.name) == "myTestObjectVar"
	assert pex_file.get_string(var.type_name) == "ABCD"
	assert var.data.typ == 0
}

fn test_object_var_2() {
	pex_file := compile_top('int myTestObjectVar2 = 10')
	var := pex_file.get_var("ABCD", "myTestObjectVar2") or { panic("object variable not found") }

	assert pex_file.get_string(var.name) == "myTestObjectVar2"
	assert pex_file.get_string(var.type_name) == "Int"
	assert var.data.typ == 3
	assert var.data.integer == 10
}

fn test_object_var_3() {
	pex_file := compile_top('ABCD[] myTestObjectVar3')
	
	var := pex_file.get_var("ABCD", "myTestObjectVar3") or { panic("object variable not found") }

	assert pex_file.get_string(var.name) == "myTestObjectVar3"
	assert pex_file.get_string(var.type_name) == "ABCD[]"
	assert var.data.typ == 0
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
	assert pex_file.get_string(state.functions[0].info.instructions[0].args[0].string_id) == "::temp0"
	assert pex_file.get_string(state.functions[0].info.instructions[0].args[1].string_id) == "n1"
	assert pex_file.get_string(state.functions[0].info.instructions[0].args[2].string_id) == "n2"

	assert state.functions[0].info.instructions[1].op == pex.OpCode.iadd
	assert pex_file.get_string(state.functions[0].info.instructions[1].args[0].string_id) == "::temp0"
	assert pex_file.get_string(state.functions[0].info.instructions[1].args[1].string_id) == "::temp0"
	assert state.functions[0].info.instructions[1].args[2].integer == 1
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
	assert pex_file.get_string(obj.default_state_name) == "MyAutoState"

	state := pex_file.get_state(obj, "MyAutoState") or { panic("state not found") }

	assert pex_file.get_string(state.name) == "MyAutoState"
	assert state.functions.len == 1
	assert pex_file.get_string(state.functions[0].name) == "Foz"
	assert pex_file.get_string(state.functions[0].info.return_type) == "None"
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
	assert pex_file.get_string(prop.auto_var_name) == "::Hello_var"
	
	mut var := pex_file.get_var("ABCD", "::Hello_var") or {
		assert false, "variable not found"
		panic("variable not found")
	}
	assert pex_file.get_string(var.name) == "::Hello_var"
	assert pex_file.get_string(var.type_name).to_lower() == "string"
	assert var.user_flags == 0
	assert var.data.typ == 2
	assert pex_file.get_string(var.data.string_id) == "Hello world!"
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

	//prop.prop.read_handler
	assert pex_file.get_string(prop.read_handler.return_type).to_lower() == "string"
	assert pex_file.get_string(prop.read_handler.return_type).to_lower() == "string"
	assert prop.read_handler.user_flags == 0
	assert prop.read_handler.flags == 0
	assert prop.read_handler.params.len == 0
	assert prop.read_handler.locals.len == 0
	assert prop.read_handler.instructions.len == 1
	assert prop.read_handler.instructions[0].op == pex.OpCode.ret
	assert pex_file.get_string(prop.read_handler.instructions[0].args[0].string_id) == "Hello world2!"
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
	assert prop.user_flags == 1
	assert prop.flags == 0b0111
	assert pex_file.get_string(prop.auto_var_name) == "::Hello3_var"

	//var
	var := pex_file.get_var("ABCD", "::Hello3_var") or {
		assert false, "variable not found"
		panic("variable not found")
	}
	assert pex_file.get_string(var.name) == "::Hello3_var"
	assert pex_file.get_string(var.type_name).to_lower() == "string"
	assert var.user_flags == 0
	assert var.data.typ == 2
	assert pex_file.get_string(var.data.string_id) == "Hello world3!"
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
	assert pex_file.get_string(prop.auto_var_name) == "::Hello5_var"

	//var
	var := pex_file.get_var("ABCD", "::Hello5_var") or {
		assert false, "variable not found"
		panic("variable not found")
	}
	assert pex_file.get_string(var.name) == "::Hello5_var"
	assert pex_file.get_string(var.type_name).to_lower() == "string"
	assert var.user_flags == 0
	assert var.data.typ == 2
	assert pex_file.get_string(var.data.string_id) == "Hello world5!"
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

	//prop.prop.read_handler
	assert pex_file.get_string(prop.read_handler.return_type).to_lower() == "int"
	assert prop.read_handler.user_flags == 0
	assert prop.read_handler.flags == 0
	assert prop.read_handler.params.len == 0
	assert prop.read_handler.locals.len == 0
	assert prop.read_handler.instructions.len == 1
	assert prop.read_handler.instructions[0].op == pex.OpCode.ret
	assert pex_file.get_string(prop.read_handler.instructions[0].args[0].string_id) == "myValue"

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
	assert pex_file.get_string(prop.write_handler.instructions[0].args[0].string_id) == "myValue"
	assert pex_file.get_string(prop.write_handler.instructions[0].args[1].string_id) == "value"
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
	assert pex_file.get_string(prop.write_handler.instructions[0].args[0].string_id) == "myValue"
	assert pex_file.get_string(prop.write_handler.instructions[0].args[1].string_id) == "value"
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

	//prop.prop.read_handler
	assert pex_file.get_string(prop.read_handler.return_type).to_lower() == "int"
	assert prop.read_handler.user_flags == 0
	assert prop.read_handler.flags == 0
	assert prop.read_handler.params.len == 0
	assert prop.read_handler.locals.len == 0
	assert prop.read_handler.instructions.len == 1
	assert prop.read_handler.instructions[0].op == pex.OpCode.ret
	assert pex_file.get_string(prop.read_handler.instructions[0].args[0].string_id) == "myValue"
}

fn test_static_call() {
	//src:			Foo(11, 12)
	//original:		opcode: 'callstatic', args: [ident(ABCD), ident(Foo), ident(::NoneVar), integer(2), integer(11), integer(12)]

	mut pex_file := compile("Foo(11, 12)")
	mut ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callstatic
	assert pex_file.get_string(ins[0].args[0].string_id) == "ABCD"
	assert pex_file.get_string(ins[0].args[1].string_id) == "Foo"
	assert pex_file.get_string(ins[0].args[2].string_id) == "::NoneVar"
	assert ins[0].args[3].integer == 2
	assert ins[0].args[4].integer == 11
	assert ins[0].args[5].integer == 12

	//src:			ABCD.Foo(13, 14)
	//original:		opcode: 'callstatic', args: [ident(ABCD), ident(Foo), ident(::NoneVar), integer(2), integer(13), integer(14)]

	pex_file = compile("ABCD.Foo(13, 14)")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callstatic
	assert pex_file.get_string(ins[0].args[0].string_id) == "ABCD"
	assert pex_file.get_string(ins[0].args[1].string_id) == "Foo"
	assert pex_file.get_string(ins[0].args[2].string_id) == "::NoneVar"
	assert ins[0].args[3].integer == 2
	assert ins[0].args[4].integer == 13
	assert ins[0].args[5].integer == 14
}

fn test_method_call() {
	//src:			Foz(15, 16)
	//original:		opcode: 'callmethod', args: [ident(Foz), ident(self), ident(::NoneVar), integer(2), integer(15), integer(16)]

	mut pex_file := compile("Foz(15, 16)")
	mut ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].string_id) == "Foz"
	assert pex_file.get_string(ins[0].args[1].string_id) == "self"
	assert pex_file.get_string(ins[0].args[2].string_id) == "::NoneVar"
	assert ins[0].args[3].integer == 2
	assert ins[0].args[4].integer == 15
	assert ins[0].args[5].integer == 16

	//src:			self.Foz(17, 18)
	//original:		opcode: 'callmethod', args: [ident(Foz), ident(self), ident(::NoneVar), integer(2), integer(17), integer(18)]

	pex_file = compile("self.Foz(17, 18)")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].string_id) == "Foz"
	assert pex_file.get_string(ins[0].args[1].string_id) == "self"
	assert pex_file.get_string(ins[0].args[2].string_id) == "::NoneVar"
	assert ins[0].args[3].integer == 2
	assert ins[0].args[4].integer == 17
	assert ins[0].args[5].integer == 18

	//src:			obj.Foz(25, 26)
	//original:		opcode: 'callmethod', args: [ident(Foz), ident(obj), ident(::NoneVar), integer(2), integer(25), integer(26)]

	pex_file = compile("obj.Foz(25, 26)")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].string_id) == "Foz"
	assert pex_file.get_string(ins[0].args[1].string_id) == "obj"
	assert pex_file.get_string(ins[0].args[2].string_id) == "::NoneVar"
	assert ins[0].args[3].integer == 2
	assert ins[0].args[4].integer == 25
	assert ins[0].args[5].integer == 26

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
	assert pex_file.get_string(ins[0].args[0].string_id) == "::temp1"
	assert ins[0].args[1].integer == 5

	assert ins[1].op == pex.OpCode.assign
	assert pex_file.get_string(ins[1].args[0].string_id) == "x"
	assert pex_file.get_string(ins[1].args[1].string_id) == "::temp1"

	assert ins[2].op == pex.OpCode.array_getelement
	assert pex_file.get_string(ins[2].args[0].string_id) == "::temp3"
	assert pex_file.get_string(ins[2].args[1].string_id) == "x"
	assert ins[2].args[2].integer == 1

	assert ins[3].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[3].args[0].string_id) == "Foz"
	assert pex_file.get_string(ins[3].args[1].string_id) == "::temp3"
	assert pex_file.get_string(ins[3].args[2].string_id) == "::NoneVar"
	assert ins[3].args[3].integer == 2
	assert ins[3].args[4].integer == 25
	assert ins[3].args[5].integer == 26
}

fn test_parent_method_call() {
	//src:			ParentFoz(19, 20)
	//original:		opcode: 'callmethod', args: [ident(ParentFoz), ident(self), ident(::NoneVar), integer(2), integer(19), integer(20)]

	mut pex_file := compile("ParentFoz(19, 20)")
	mut ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].string_id) == "ParentFoz"
	assert pex_file.get_string(ins[0].args[1].string_id) == "self"
	assert pex_file.get_string(ins[0].args[2].string_id) == "::NoneVar"
	assert ins[0].args[3].integer == 2
	assert ins[0].args[4].integer == 19
	assert ins[0].args[5].integer == 20

	//src:			Parent.ParentFoz(21, 22)
	//original:		opcode: 'callparent', args: [ident(ParentFoz), ident(::NoneVar), integer(2), integer(21), integer(22)]

	pex_file = compile("Parent.ParentFoz(21, 22)")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callparent
	assert pex_file.get_string(ins[0].args[0].string_id) == "ParentFoz"
	assert pex_file.get_string(ins[0].args[1].string_id) == "::NoneVar"
	assert ins[0].args[2].integer == 2
	assert ins[0].args[3].integer == 21
	assert ins[0].args[4].integer == 22

	//src:			obj.ParentFoz(23, 24)
	//original:		opcode: 'callmethod', args: [ident(ParentFoz), ident(obj), ident(::NoneVar), integer(2), integer(23), integer(24)]

	pex_file = compile("obj.ParentFoz(23, 24)")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].string_id) == "ParentFoz"
	assert pex_file.get_string(ins[0].args[1].string_id) == "obj"
	assert pex_file.get_string(ins[0].args[2].string_id) == "::NoneVar"
	assert ins[0].args[3].integer == 2
	assert ins[0].args[4].integer == 23
	assert ins[0].args[5].integer == 24
}

fn test_call_event() {
	//src: 			OnInit()
	//original:		opcode: 'callmethod', args: [ident(OnInit), ident(self), ident(::NoneVar), integer(0)]
	//my:			opcode: 'callmethod', args: [ident(OnInit), ident(self), ident(::NoneVar), integer(0)]

	pex_file := compile("OnInit()")
	ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.callmethod
	assert pex_file.get_string(ins[0].args[0].string_id) == "OnInit"
	assert pex_file.get_string(ins[0].args[1].string_id) == "self"
	assert pex_file.get_string(ins[0].args[2].string_id) == "::NoneVar"
	assert ins[0].args[3].integer == 0
}

fn test_property_assign() {
	//src:			myAutoProp = 5
	//original:		opcode: 'assign', args: [ident(::myAutoProp_var), integer(5)]
   
	mut pex_file := compile("myAutoProp = 5")
	mut ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.assign
	assert pex_file.get_string(ins[0].args[0].string_id) == "::myAutoProp_var"
	assert ins[0].args[1].integer == 5

	//src:			obj.myAutoProp = 15
	//original:		opcode: 'assign', args: [ident(::temp2), integer(15)]
	//				opcode: 'propset', args: [ident(myAutoProp), ident(obj), ident(::temp2)]
   
	pex_file = compile("obj.myAutoProp = 15")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.propset
	assert pex_file.get_string(ins[0].args[0].string_id) == "myAutoProp"
	assert pex_file.get_string(ins[0].args[1].string_id) == "obj"
	assert ins[0].args[2].integer == 15
}

fn test_property_get() {
	//src:			myAutoProp + 4
	//original:		opcode: 'iadd', args: [ident(::temp2), ident(::myAutoProp_var), integer(4)]
   
	mut pex_file := compile("myAutoProp + 4")
	mut ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.iadd
	assert pex_file.get_string(ins[0].args[0].string_id) == "::temp0"
	assert pex_file.get_string(ins[0].args[1].string_id) == "::myAutoProp_var"
	assert ins[0].args[2].integer == 4

	//src:			obj.myAutoProp + 14
	//original:		opcode: 'propget', args: [ident(myAutoProp), ident(obj), ident(::temp2)]
    //				opcode: 'iadd', args: [ident(::temp2), ident(::temp2), integer(14)]
   
	pex_file = compile("obj.myAutoProp + 14")
	ins = get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.propget
	assert pex_file.get_string(ins[0].args[0].string_id) == "myAutoProp"
	assert pex_file.get_string(ins[0].args[1].string_id) == "obj"
	assert pex_file.get_string(ins[0].args[2].string_id) == "::temp0"

	assert ins[1].op == pex.OpCode.iadd
	assert pex_file.get_string(ins[1].args[0].string_id) == "::temp0"
	assert pex_file.get_string(ins[1].args[1].string_id) == "::temp0"
	assert ins[1].args[2].integer == 14
}

fn test_foo() {
	pex_file := compile("int n = 1 + 2")
	ins := get_instructions(pex_file)

	assert ins[0].op == pex.OpCode.iadd
	assert pex_file.get_string(ins[0].args[0].string_id) == "::temp1"
	assert ins[0].args[1].integer == 1
	assert ins[0].args[2].integer == 2
	
	assert ins[1].op == pex.OpCode.assign
	assert pex_file.get_string(ins[1].args[0].string_id) == "n"
	assert pex_file.get_string(ins[1].args[1].string_id) == "::temp1"
}