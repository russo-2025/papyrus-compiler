import pref

import papyrus.ast
import papyrus.parser
import papyrus.checker
import gen.gen_pex
import papyrus.vm

const prefs = pref.Preferences {
	paths: []string{}
	mode: .compile
	backend: .pex
	no_cache: true
}

fn vm_init(src_file string) &vm.ExecutionContext {
	mut table := ast.new_table()
	mut global_scope := &ast.Scope{}

	mut ast_file := parser.parse_text("::gen_test.v/src::", src_file, mut table, prefs, mut global_scope)
	mut c := checker.new_checker(table, prefs)
	c.check(mut ast_file)
	assert c.errors.len == 0
	mut pex_file := gen_pex.gen_pex_file(mut ast_file, mut table, prefs)

	//eprintln(pex_file.str())
	mut ctx := vm.create_context()
	ctx.load_pex_file(pex_file)
	return ctx
}

fn test_call_global() {
	src_file := 'Scriptname ABCD

	Float Function Sum(int n1, float n2, float n3) global
	return (n1 + n2 as int + n3 as int) as float 
	EndFunction

	Int Function PexInstructionTest(int n1, int n2) global
		Sum(11, 12 as Float, Sum(10, 20 as Float, 30.0))
		Sum(11, 12 as Float, Sum(10, 20 as Float, 30.0))
		Sum(11, 12 as Float, Sum(10, 20 as Float, 30.0))
		return Sum(11, 12 as Float, Sum(10, 20 as Float, 30.0)) as int
	EndFunction'

	mut ctx := vm_init(src_file)

	vres := ctx.call_static("ABCD", "PexInstructionTest", [ ctx.create_int(22), ctx.create_int(23)]) or {
		panic("fn not found")
	}
	res := vres.get[i32]()
	assert res == 83
}

fn test_call_method() {
	src_file := 'Scriptname ABCD

	Int Function Sum(int n1, int n2)
		return n1 + n2
	EndFunction

	Int Function Sum10(int n1, int n2)
		return 10 + Sum(n1, n2)
	EndFunction'
	
	mut ctx := vm_init(src_file)

	script := ctx.find_script("ABCD") or { panic("script not found") }
	self := ctx.create_object_value(script)
	result_value := ctx.call_method(self, "Sum10", [ ctx.create_int(12), ctx.create_int(32)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == (10 + 12 + 32)

	// TODO parent call
	// keyword parent call
	// keyword self call
}

fn test_prefix() {
	src_file := 'Scriptname ABCD

	float Function NegTestFloat(float n1)
		return -n1
	EndFunction

	Int Function NegTestInt(int n1)
		return -n1
	EndFunction

	Int Function NotTest(int n1, int n2)
		if !(n1 > n2)
			return 15
		EndIf

		return -2
	EndFunction'

	mut ctx := vm_init(src_file)

	script := ctx.find_script("ABCD") or { panic("script not found") }
	self := ctx.create_object_value(script)
	
	mut result_value := ctx.call_method(self, "NotTest", [ ctx.create_int(3), ctx.create_int(4)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 15

	result_value = ctx.call_method(self, "NotTest", [ ctx.create_int(4), ctx.create_int(3)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == -2

	// neg
	
	result_value = ctx.call_method(self, "NegTestInt", [ ctx.create_int(3)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == -3
	
	result_value = ctx.call_method(self, "NegTestFloat", [ ctx.create_float(15.0)]) or {
		panic("method not found")
	}
	assert result_value.get[f32]() == -15.0
}

fn test_math() {
	src_file := 'Scriptname ABCD

	Int Function MathTest1(int n1, int n2, int n3, int n4)
		return (n1 + n2 - n3) / n4
	EndFunction

	Int Function MathTest2()
		int var1 = 3 + 4
		int var2 = var1 - 1
		int var3 = var2 / 3
		If var3 == 2
			return var1
		EndIf

		return -1
	EndFunction'

	mut ctx := vm_init(src_file)

	script := ctx.find_script("ABCD") or { panic("script not found") }
	self := ctx.create_object_value(script)
	
	mut result_value := ctx.call_method(self, "MathTest1", [ ctx.create_int(3), ctx.create_int(4), ctx.create_int(1), ctx.create_int(3) ]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 2

	result_value = ctx.call_method(self, "MathTest2", []) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 7
}

fn test_if_return() {
	src_file := 'Scriptname ABCD

	Int Function IfGt(int n)
		If n > 2
			return 10
		EndIf

		return 0
	EndFunction

	Int Function IfGe(int n)
		If n >= 2
			return 11
		EndIf

		return 0
	EndFunction

	Int Function IfLt(int n)
		If n < 3
			return 12
		EndIf

		return 0
	EndFunction

	Int Function IfLe(int n)
		If n <= 3
			return 13
		EndIf

		return 0
	EndFunction

	Int Function IfEq(int n)
		If n == 5
			return 9
		EndIf

		return 12
	EndFunction'

	mut ctx := vm_init(src_file)

	script := ctx.find_script("ABCD") or { panic("script not found") }
	self := ctx.create_object_value(script)
	// >
	mut result_value := ctx.call_method(self, "IfGt", [ ctx.create_int(2)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 0

	result_value = ctx.call_method(self, "IfGt", [ ctx.create_int(4)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 10

	// >=
	result_value = ctx.call_method(self, "IfGe", [ ctx.create_int(1)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 0

	result_value = ctx.call_method(self, "IfGe", [ ctx.create_int(2)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 11

	result_value = ctx.call_method(self, "IfGe", [ ctx.create_int(3)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 11

	// <
	result_value = ctx.call_method(self, "IfLt", [ ctx.create_int(3)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 0

	result_value = ctx.call_method(self, "IfLt", [ ctx.create_int(2)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 12

	// <=
	result_value = ctx.call_method(self, "IfLe", [ ctx.create_int(4)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 0
	result_value = ctx.call_method(self, "IfLe", [ ctx.create_int(3)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 13

	result_value = ctx.call_method(self, "IfLe", [ ctx.create_int(2)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 13

	// ==
	result_value = ctx.call_method(self, "IfEq", [ ctx.create_int(2)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 12

	result_value = ctx.call_method(self, "IfEq", [ ctx.create_int(5)]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 9
}

fn test_fibonacci() {
	src_file := 'Scriptname ABCD

	Int Function FibStatic(int n) Global
		If (n <= 1)
			return n;
		EndIf

		return FibStatic(n - 1) + FibStatic(n - 2);
	EndFunction

	Int Function FibMethod(int n)
		If (n <= 1)
			return n;
		EndIf

		return FibMethod(n - 1) + FibMethod(n - 2);
	EndFunction'

	mut ctx := vm_init(src_file)

	// method
	script := ctx.find_script("ABCD") or { panic("script not found") }
	self := ctx.create_object_value(script)
	mut result_value := ctx.call_method(self, "FibMethod", [ ctx.create_int(0) ]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 0

	result_value = ctx.call_method(self, "FibMethod", [ ctx.create_int(1) ]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 1

	result_value = ctx.call_method(self, "FibMethod", [ ctx.create_int(2) ]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 1

	result_value = ctx.call_method(self, "FibMethod", [ ctx.create_int(3) ]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 2
	
	result_value = ctx.call_method(self, "FibMethod", [ ctx.create_int(4) ]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 3
	
	result_value = ctx.call_method(self, "FibMethod", [ ctx.create_int(5) ]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 5
	
	result_value = ctx.call_method(self, "FibMethod", [ ctx.create_int(6) ]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 8

	result_value = ctx.call_method(self, "FibMethod", [ ctx.create_int(7) ]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 13

	result_value = ctx.call_method(self, "FibMethod", [ ctx.create_int(8) ]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 21

	result_value = ctx.call_method(self, "FibMethod", [ ctx.create_int(9) ]) or {
		panic("method not found")
	}
	assert result_value.get[i32]() == 34

	// static 
	result_value = ctx.call_static("ABCD", "FibStatic", [ ctx.create_int(9)]) or {
		panic("fn not found")
	}
	assert result_value.get[i32]() == 34
}

fn test_none_object() {
	src_file := 'Scriptname ABCD

	bool Function ScriptTest1(ABCD obj) Global
		If Obj != None
			return true
		EndIf
		
		return false
	EndFunction
	
	ABCD Function ScriptTest2() Global
		ABCD obj = None
		return obj
	EndFunction
	
	ABCD Function ScriptTest3(ABCD obj) Global
		return obj
	EndFunction
	
	ABCD Function ScriptTest4()
		return self
	EndFunction

	bool Function ScriptTest5() Global
		return ScriptTest1(None)
	EndFunction'

	mut ctx := vm_init(src_file)

	script := ctx.find_script("ABCD") or { panic("script not found") }
	abcd_value := ctx.create_object_value(script)
	abcd_none_value := ctx.create_value_none_object_from_info(script)

	// if obj none
	mut result_value := ctx.call_static("ABCD", "ScriptTest1", [ abcd_value ]) or {
		panic("fn not found")
	}
	assert result_value.get[bool]() == true

	result_value = ctx.call_static("ABCD", "ScriptTest1", [ abcd_none_value ]) or {
		panic("fn not found")
	}
	assert !result_value.get[bool]()

	result_value = ctx.call_static("ABCD", "ScriptTest5", [ ]) or {
		panic("fn not found")
	}
	assert !result_value.get[bool]()

	// set / return object/noneobject
	result_value = ctx.call_static("ABCD", "ScriptTest2", []) or {
		panic("fn not found")
	}
	assert result_value.object_is_none()

	result_value = ctx.call_static("ABCD", "ScriptTest3", [ abcd_value ]) or {
		panic("fn not found")
	}
	assert !result_value.object_is_none()

	result_value = ctx.call_static("ABCD", "ScriptTest3", [ abcd_none_value ]) or {
		panic("fn not found")
	}
	assert result_value.object_is_none()

	//self
	result_value = ctx.call_method(abcd_value, "ScriptTest4", [ ]) or {
		panic("method not found")
	}
	assert !result_value.object_is_none()
}

fn test_array() {
	// https://ck.uesp.net/wiki/Array_Reference
	// https://ck.uesp.net/wiki/Arrays_(Papyrus)

	src_file := 'Scriptname ABCD

	float[] Function GetIntArray() global
		float[] x = new float[20]

		x[0] = 5
		x[5] = 10
		x[18] = 99
		x[19] = 100

		return x
	EndFunction

	float Function GetInt() global
		float[] x = new float[10]
		x[5] = 199
		return x[5]
	EndFunction

	int Function ArrayLength() global
		float[] x = new float[16]
		return x.Length
	EndFunction

	int Function ArrayFind1(int value, int startIndex) global
		int[] x = new int[10]

		x[0] = 5
		x[1] = 10
		x[2] = 15
		x[3] = 20
		x[4] = 25
		x[5] = 30
		x[6] = 35
		x[7] = 40
		x[8] = 45
		x[9] = 50

		int index = x.Find(value, startIndex)
		return index
	EndFunction

	int Function ArrayRFind1(int value, int startIndex) global
		int[] x = new int[10]

		x[0] = 5
		x[1] = 10
		x[2] = 15
		x[3] = 20
		x[4] = 25
		x[5] = 30
		x[6] = 35
		x[7] = 40
		x[8] = 45
		x[9] = 50

		int index = x.RFind(value, startIndex)
		return index
	EndFunction'

	mut ctx := vm_init(src_file)

	// return array
	mut result_value := ctx.call_static("ABCD", "GetIntArray", []) or {
		panic("fn not found")
	}

	assert result_value.typ.raw == "float[]"
	assert result_value.get_array_length() == 20
	
	x0 := result_value.get_array_element(0)
	assert x0.get[f32]() == 5
	
	x5 := result_value.get_array_element(5)
	assert x5.get[f32]() == 10
	
	x18 := result_value.get_array_element(18)
	assert x18.get[f32]() == 99

	x19 := result_value.get_array_element(19)
	assert x19.get[f32]() == 100

	// get set element
	result_value = ctx.call_static("ABCD", "GetInt", []) or {
		panic("fn not found")
	}
	assert result_value.get[f32]() == 199

	// array length
	result_value = ctx.call_static("ABCD", "ArrayLength", []) or {
		panic("fn not found")
	}
	assert result_value.get[i32]() == 16

	// Find
	result_value = ctx.call_static("ABCD", "ArrayFind1", [ ctx.create_int(40), ctx.create_int(0) ]) or {
		panic("fn not found")
	}
	assert result_value.get[i32]() == 7

	result_value = ctx.call_static("ABCD", "ArrayFind1", [ ctx.create_int(20), ctx.create_int(5) ]) or {
		panic("fn not found")
	}
	assert result_value.get[i32]() == -1

	// RFind
	result_value = ctx.call_static("ABCD", "ArrayRFind1", [ ctx.create_int(20), ctx.create_int(-1) ]) or {
		panic("fn not found")
	}
	assert result_value.get[i32]() == 3

	result_value = ctx.call_static("ABCD", "ArrayRFind1", [ ctx.create_int(40), ctx.create_int(4) ]) or {
		panic("fn not found")
	}
	assert result_value.get[i32]() == -1
}

fn test_cast() {
	src_file := 'Scriptname ABCD
	Bool Function Assert(bool cond) Global Native

	Bool Function CastTest(ABCD obj, ABCD noneObj) Global
		;to bool
		Assert(!(None as bool))
		;Assert(12 as bool)
		;Assert(!0 as bool)
		;Assert(13.0 as bool)
		;Assert(!0.0 as bool)
		;Assert(!"" as bool)
		;Assert("123" as bool)
		;Assert(obj as bool)
		;Assert(!noneObj as bool)

		;Assert(new int[3] as bool)
		;Assert(!new int[3] as bool)

		; to int
		;Assert(True as int == 1)
		;Assert(False as int == 0)

		return true
	EndFunction'

	mut ctx := vm_init(src_file)

	native_func := vm.NativeFunction{
		object_name: "ABCD"
		name: "Assert"
		is_global: true
		cb: fn(ctx vm.ExecutionContext, self vm.Value, args []vm.Value) !vm.Value {
			assert args.len == 1

			if !args[0].get[bool]() {
				return error("error")
			}

			return ctx.create_bool(true)
		}
	}

	ctx.register_native_function(native_func) or { panic(err) }

	script := ctx.find_script("ABCD") or { panic("script not found") }
	abcd_value := ctx.create_object_value(script)
	abcd_none_value := ctx.create_value_none_object_from_info(script)

	mut result_value := ctx.call_static("ABCD", "CastTest", [ abcd_value, abcd_none_value ]) or {
		panic("fn not found")
	}
	assert result_value.get[bool]() == true

/*
	mut ctx := vm.create_context()
	ctx.load_pex_file(pex_file)

	script := ctx.find_script("ABCD") or { panic("script not found") }
	abcd_value := ctx.create_object_value(script)
	abcd_none_value := ctx.create_value_none_object_from_info(script)

	// if obj none
	mut result_value := ctx.call_static("ABCD", "ScriptTest1", [ abcd_value ]) or {
		panic("fn not found")
	}
	assert result_value.get[bool]() == true
*/
}

fn test_state() {
	// https://ck.uesp.net/wiki/State_Reference
	// TODO
}

fn test_native_call() {
	// TODO
}

fn test_properties() {
	// https://ck.uesp.net/wiki/Property_Reference
	// TODO
}

fn test_object_var() {
	// TODO
}
