import papyrus.ast
import papyrus.parser
import papyrus.checker
import pex
import gen_pex
import pref

fn compile(src string) &pex.PexFile {
	parent_src :=
		"Scriptname CDFG\n" +
		"Function ParentFoz(int n1, int n2)\n" +
		"EndFunction"

	full_src :=
		"Scriptname ABCD extends CDFG\n" +
		"Function Foo(int n1, int n2) global\n" +
		"EndFunction\n" +
		"Function Foz(int n1, int n2)\n" +
		"EndFunction\n" +
		"Function Bar(string v, ABCD obj)\n" +
		"$src\n" +
		"EndFunction\n"

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
	
	mut parent_file := parser.parse_text(parent_src, table, prefs, global_scope)
	mut file := parser.parse_text(full_src, table, prefs, global_scope)

	mut c := checker.new_checker(table, prefs)

	c.check(mut parent_file)
	c.check(mut file)

	assert c.errors.len == 0

	pex_file := gen_pex.gen_pex_file(file, table, prefs)
	return pex_file
}

fn get_instructions(pex_file &pex.PexFile) []pex.Instruction {
	func := pex_file.find_function("ABCD", "Bar") or { panic("function not found") }

	$if false {
		println("")
		for instr in func.info.instructions {
			pex_file.print_instruction(instr, 0)
		}
		println("")
	}

	return func.info.instructions
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