import pref
import papyrus.ast
import papyrus.parser
import papyrus.checker
import papyrus.token

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
string Function MethodFoo(bool arg1, bool arg2, bool arg3)
return \"123\"
EndFunction
string Function OBar(Float afvalue) Global\n
return \"123\"
EndFunction"

	other2_src = 
"Scriptname OtherScript2"

	parent_src =
"Scriptname CDFG
int otherProp = 0 ; for ABCD property test
string myParentObjectVar = \"Hello\"
float Property myAutoParentProp = 0.2 Auto
int Function ParentFoz(int n1, int n2)
EndFunction\n"

	src_template = 
"Scriptname ABCD extends CDFG
Import OtherScript
bool myObjectVar = false
int Function Foz(int n1, int n2)
return 0
EndFunction
Function FuncBoolArg(bool arg)
EndFunction
Function FuncIntArg(int arg)
EndFunction
Function FuncFloatArg(float arg)
EndFunction
Function FuncStringArg(string arg)
EndFunction
Function FuncObjectArg(CDFG arg)
EndFunction
Function FuncArrayArg(bool[] arg)
EndFunction
Function FuncWithOptionalArgs(int arg1, int arg2, int arg3, int arg4 = 0, int arg5 = 0, int arg6 = 0)
EndFunction
float Function Bar(string s1, string s2) Global
EndFunction
int Property myAutoProp = 123 Auto
OtherScript Property otherProp Auto
OtherScript Property OtherScript2 Auto\n"
)

fn compile(src string) (&ast.File, &ast.Table) {
	mut table := ast.new_table()
	global_scope := &ast.Scope{
		parent: 0
	}
	
	full_src := "${src_template}${src}"

	mut other_file := parser.parse_text("::gen_test.v/other-src::", other_src, table, prefs, global_scope)
	mut other2_file := parser.parse_text("::gen_test.v/other2-src::", other2_src, table, prefs, global_scope)
	mut parent_file := parser.parse_text("::gen_test.v/parent::", parent_src, table, prefs, global_scope)
	mut file := parser.parse_text("::gen_test.v/src::", full_src, table, prefs, global_scope)

	mut c := checker.new_checker(table, prefs)

	c.check(mut other_file)
	c.check(mut other2_file)
	c.check(mut parent_file)
	c.check(mut file)

	assert c.errors.len == 0, src

	//println(file.stmts)

	return file, table
}

fn compile_top_stmts(src string) ([]ast.TopStmt, &ast.Table) {
	mut file, table := compile(src)
	return file.stmts, table
}

fn compile_stmts(src string) ([]ast.Stmt, &ast.Table) {
	full_src := "Function MyTestFn(string arg1, int arg2, float arg3, bool arg4, ABCD obj, CDFG pobj, int[] int_arr)\n${src}\nEndFunction\n"
	mut top_stmts, table := compile_top_stmts(full_src)
	assert top_stmts.len == 15
	assert top_stmts[14] is ast.FnDecl
	func := top_stmts[14] as ast.FnDecl
	assert func.name == "MyTestFn"
	return func.stmts, table
}

fn compile_stmt(src string) (&ast.Stmt, &ast.Table) {
	stmts, table := compile_stmts(src)
	assert stmts.len == 1
	return &stmts[0], table
}

fn compile_expr(src string) (&ast.Expr, &ast.Table) {
	mut stmt, table := compile_stmt(src)
	assert stmt is ast.ExprStmt
	return &(stmt as ast.ExprStmt).expr, table
}

fn test_literals() {
	mut expr := &ast.Expr(ast.EmptyExpr{})

	expr, _ = compile_expr('123')
	assert expr is ast.IntegerLiteral

	expr, _ = compile_expr('-123')
	assert expr is ast.IntegerLiteral

	expr, _ = compile_expr('0x00080C29')
	assert expr is ast.IntegerLiteral

	expr, _ = compile_expr('0X00080C29')
	assert expr is ast.IntegerLiteral

	expr, _ = compile_expr('0.123')
	assert expr is ast.FloatLiteral

	expr, _ = compile_expr('10.123')
	assert expr is ast.FloatLiteral

	expr, _ = compile_expr('-10.123')
	assert expr is ast.FloatLiteral

	expr, _ = compile_expr('"msg123"')
	assert expr is ast.StringLiteral

	expr, _ = compile_expr('None')
	assert expr is ast.NoneLiteral

	expr, _ = compile_expr('True')
	assert expr is ast.BoolLiteral

	expr, _ = compile_expr('False')
	assert expr is ast.BoolLiteral
}

fn test_prefix_expr() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	
	expr, _ = compile_expr('!False')
	assert (expr as ast.PrefixExpr).op == token.Kind.not
	assert (expr as ast.PrefixExpr).right_type == ast.bool_type
	
	expr, _ = compile_expr('-arg2')
	assert (expr as ast.PrefixExpr).op == token.Kind.minus
	assert (expr as ast.PrefixExpr).right_type == ast.int_type
	assert ((expr as ast.PrefixExpr).right as ast.Ident).typ == ast.int_type
}

fn test_infix() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	
	expr, _ = compile_expr('1 + 1')
	assert (expr as ast.InfixExpr).op == token.Kind.plus
	assert (expr as ast.InfixExpr).result_type == ast.int_type

	expr, _ = compile_expr('0.1 + 0.2')
	assert (expr as ast.InfixExpr).op == token.Kind.plus
	assert (expr as ast.InfixExpr).result_type == ast.float_type

	expr, _ = compile_expr('"a" + "b"')
	assert (expr as ast.InfixExpr).op == token.Kind.plus
	assert (expr as ast.InfixExpr).result_type == ast.string_type

	expr, _ = compile_expr('1 - 1')
	assert (expr as ast.InfixExpr).op == token.Kind.minus
	assert (expr as ast.InfixExpr).result_type == ast.int_type

	expr, _ = compile_expr('0.1 - 0.2')
	assert (expr as ast.InfixExpr).op == token.Kind.minus
	assert (expr as ast.InfixExpr).result_type == ast.float_type

	expr, _ = compile_expr('1 * 1')
	assert (expr as ast.InfixExpr).op == token.Kind.mul
	assert (expr as ast.InfixExpr).result_type == ast.int_type

	expr, _ = compile_expr('0.1 * 0.2')
	assert (expr as ast.InfixExpr).op == token.Kind.mul
	assert (expr as ast.InfixExpr).result_type == ast.float_type

	expr, _ = compile_expr('1 / 1')
	assert (expr as ast.InfixExpr).op == token.Kind.div
	assert (expr as ast.InfixExpr).result_type == ast.int_type

	expr, _ = compile_expr('0.1 / 0.2')
	assert (expr as ast.InfixExpr).op == token.Kind.div
	assert (expr as ast.InfixExpr).result_type == ast.float_type

	expr, _ = compile_expr('1 % 1')
	assert (expr as ast.InfixExpr).op == token.Kind.mod
	assert (expr as ast.InfixExpr).result_type == ast.int_type

	expr, _ = compile_expr('1 == 1')
	assert (expr as ast.InfixExpr).op == token.Kind.eq
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('0.1 == 0.2')
	assert (expr as ast.InfixExpr).op == token.Kind.eq
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('1 != 1')
	assert (expr as ast.InfixExpr).op == token.Kind.ne
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('0.1 != 0.2')
	assert (expr as ast.InfixExpr).op == token.Kind.ne
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('1 > 1')
	assert (expr as ast.InfixExpr).op == token.Kind.gt
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('0.1 > 0.2')
	assert (expr as ast.InfixExpr).op == token.Kind.gt
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('1 < 1')
	assert (expr as ast.InfixExpr).op == token.Kind.lt
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('0.1 < 0.2')
	assert (expr as ast.InfixExpr).op == token.Kind.lt
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('1 >= 1')
	assert (expr as ast.InfixExpr).op == token.Kind.ge
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('0.1 >= 0.2')
	assert (expr as ast.InfixExpr).op == token.Kind.ge
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('1 <= 1')
	assert (expr as ast.InfixExpr).op == token.Kind.le
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('0.1 <= 0.2')
	assert (expr as ast.InfixExpr).op == token.Kind.le
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('True && False')
	assert (expr as ast.InfixExpr).op == token.Kind.logical_and
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('True || False')
	assert (expr as ast.InfixExpr).op == token.Kind.logical_or
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('obj == None')
	assert (expr as ast.InfixExpr).op == token.Kind.eq
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('None == obj')
	assert (expr as ast.InfixExpr).op == token.Kind.eq
	assert (expr as ast.InfixExpr).result_type == ast.bool_type
	
	expr, _ = compile_expr('int_arr == None')
	assert (expr as ast.InfixExpr).op == token.Kind.eq
	assert (expr as ast.InfixExpr).result_type == ast.bool_type
	
	expr, _ = compile_expr('None == int_arr')
	assert (expr as ast.InfixExpr).op == token.Kind.eq
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('True && \\\n False')
	assert (expr as ast.InfixExpr).op == token.Kind.logical_and
	assert (expr as ast.InfixExpr).result_type == ast.bool_type
	assert ((expr as ast.InfixExpr).left as ast.BoolLiteral).val == "True"
	assert ((expr as ast.InfixExpr).right as ast.BoolLiteral).val == "False"
	
	expr, _ = compile_expr('True \\\n && False')
	assert (expr as ast.InfixExpr).op == token.Kind.logical_and
	assert (expr as ast.InfixExpr).result_type == ast.bool_type
	assert ((expr as ast.InfixExpr).left as ast.BoolLiteral).val == "True"
	assert ((expr as ast.InfixExpr).right as ast.BoolLiteral).val == "False"
}

fn test_ident() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()

	expr, _ = compile_expr('arg1') //fn argument
	assert expr is ast.Ident
	assert (expr as ast.Ident).typ == ast.string_type

	expr, _ = compile_expr('myObjectVar') //object var
	assert expr is ast.Ident
	assert (expr as ast.Ident).typ == ast.bool_type

	expr, _ = compile_expr('myAutoProp') //object property
	assert expr is ast.Ident
	assert (expr as ast.Ident).typ == ast.int_type

	expr, _ = compile_expr('myParentObjectVar') //parent object var
	assert expr is ast.Ident
	assert (expr as ast.Ident).typ == ast.string_type

	expr, _ = compile_expr('myAutoParentProp') //parent object property
	assert expr is ast.Ident
	assert (expr as ast.Ident).typ == ast.float_type

	expr, table = compile_expr('otherProp') // equal names (property ABCD.otherProp and var CDFG.otherProp)
	assert expr is ast.Ident
	assert (expr as ast.Ident).typ == table.find_type_idx("OtherScript")
}

fn test_keywords_parent_self() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()
	
	expr, table = compile_expr('self')
	assert (expr as ast.Ident).typ == table.find_type_idx("ABCD")

	expr, table = compile_expr('parent')
	assert (expr as ast.Ident).typ == table.find_type_idx("CDFG")
	
	expr, _ = compile_expr('self.myAutoProp')
	assert (expr as ast.SelectorExpr).typ == ast.int_type
	
	expr, _ = compile_expr('self.myAutoParentProp')
	assert (expr as ast.SelectorExpr).typ == ast.float_type
	
	expr, _ = compile_expr('parent.myAutoParentProp')
	assert (expr as ast.SelectorExpr).typ == ast.float_type

	expr, _ = compile_expr('self.Foz(11, 22)')
	assert (expr as ast.CallExpr).obj_name == "ABCD"
	assert (expr as ast.CallExpr).return_type == ast.int_type
	assert (expr as ast.CallExpr).args.len == 2

	expr, _ = compile_expr('self.ParentFoz(11, 22)')
	assert (expr as ast.CallExpr).obj_name == "CDFG"
	assert (expr as ast.CallExpr).return_type == ast.int_type
	assert (expr as ast.CallExpr).args.len == 2

	expr, _ = compile_expr('parent.ParentFoz(11, 22)')
	assert (expr as ast.CallExpr).obj_name == "CDFG"
	assert (expr as ast.CallExpr).return_type == ast.int_type
	assert (expr as ast.CallExpr).args.len == 2
}

fn test_object_props() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()
	
	expr, _ = compile_expr('obj.myAutoProp')
	assert (expr as ast.SelectorExpr).typ == ast.int_type

	expr, _ = compile_expr('myAutoProp')
	assert (expr as ast.Ident).typ == ast.int_type
	
	expr, _ = compile_expr('obj.myAutoParentProp')
	assert (expr as ast.SelectorExpr).typ == ast.float_type

	expr, _ = compile_expr('myAutoParentProp')
	assert (expr as ast.Ident).typ == ast.float_type

	expr, table = compile_expr("obj.otherProp") // equal names (property ABCD.otherProp and var CDFG.otherProp)
	assert (expr as ast.SelectorExpr).typ == table.find_type_idx("OtherScript")
}

fn test_object_vars() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	
	expr, _ = compile_expr('obj.myObjectVar')
	assert (expr as ast.SelectorExpr).typ == ast.bool_type

	expr, _ = compile_expr('myObjectVar')
	assert (expr as ast.Ident).typ == ast.bool_type
	
	expr, _ = compile_expr('obj.myParentObjectVar')
	assert (expr as ast.SelectorExpr).typ == ast.string_type

	expr, _ = compile_expr('myParentObjectVar')
	assert (expr as ast.Ident).typ == ast.string_type
}

fn test_call_expr() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()
	
	expr, _ = compile_expr('Foz(11, 22)')
	assert (expr as ast.CallExpr).obj_name == "ABCD"
	assert (expr as ast.CallExpr).return_type == ast.int_type
	assert (expr as ast.CallExpr).args.len == 2
	
	expr, _ = compile_expr('ParentFoz(11, 22)')
	assert (expr as ast.CallExpr).obj_name == "CDFG"
	assert (expr as ast.CallExpr).return_type == ast.int_type
	assert (expr as ast.CallExpr).args.len == 2

	expr, _ = compile_expr('obj.Foz(11, 22)')
	assert (expr as ast.CallExpr).obj_name == "ABCD"
	assert (expr as ast.CallExpr).return_type == ast.int_type
	assert (expr as ast.CallExpr).args.len == 2

	expr, _ = compile_expr('obj.Foz(11, 22)')
	assert (expr as ast.CallExpr).obj_name == "ABCD"
	assert (expr as ast.CallExpr).return_type == ast.int_type
	assert (expr as ast.CallExpr).args.len == 2

	expr, _ = compile_expr('ABCD.Bar("hello", "V")')
	assert (expr as ast.CallExpr).obj_name == "ABCD"
	assert (expr as ast.CallExpr).return_type == ast.float_type
	assert (expr as ast.CallExpr).args.len == 2

	expr, _ = compile_expr('OtherScript.OBar(1.6)')
	assert (expr as ast.CallExpr).obj_name == "OtherScript"
	assert (expr as ast.CallExpr).return_type == ast.string_type
	assert (expr as ast.CallExpr).args.len == 1

	expr, _ = compile_expr('OBar(1.6)') //import fn
	assert (expr as ast.CallExpr).obj_name == "OtherScript"
	assert (expr as ast.CallExpr).return_type == ast.string_type
	assert (expr as ast.CallExpr).args.len == 1

	expr, _ = compile_expr('obj.FuncWithOptionalArgs(72, 85, 95)')
	assert (expr as ast.CallExpr).obj_name == "ABCD"
	assert (expr as ast.CallExpr).return_type == ast.none_type
	assert (expr as ast.CallExpr).args.len == 6
	assert ((expr as ast.CallExpr).args[0].expr as ast.IntegerLiteral).val == "72"
	assert ((expr as ast.CallExpr).args[1].expr as ast.IntegerLiteral).val == "85"
	assert ((expr as ast.CallExpr).args[2].expr as ast.IntegerLiteral).val == "95"
	assert ((expr as ast.CallExpr).args[3].expr as ast.IntegerLiteral).val == "0"
	assert ((expr as ast.CallExpr).args[4].expr as ast.IntegerLiteral).val == "0"
	assert ((expr as ast.CallExpr).args[5].expr as ast.IntegerLiteral).val == "0"

	expr, _ = compile_expr('obj.FuncWithOptionalArgs(112, 124, 164, arg5 = 423)')
	assert (expr as ast.CallExpr).obj_name == "ABCD"
	assert (expr as ast.CallExpr).return_type == ast.none_type
	assert (expr as ast.CallExpr).args.len == 6
	assert ((expr as ast.CallExpr).args[0].expr as ast.IntegerLiteral).val == "112"
	assert ((expr as ast.CallExpr).args[1].expr as ast.IntegerLiteral).val == "124"
	assert ((expr as ast.CallExpr).args[2].expr as ast.IntegerLiteral).val == "164"
	assert ((expr as ast.CallExpr).args[3].expr as ast.IntegerLiteral).val == "0"
	assert ((expr as ast.CallExpr).args[4].expr as ast.IntegerLiteral).val == "423"
	assert ((expr as ast.CallExpr).args[5].expr as ast.IntegerLiteral).val == "0"

	expr, _ = compile_expr('obj.FuncWithOptionalArgs(arg3 = 5, arg1 = 4, arg2 = 1)')
	assert (expr as ast.CallExpr).obj_name == "ABCD"
	assert (expr as ast.CallExpr).return_type == ast.none_type
	assert (expr as ast.CallExpr).args.len == 6
	assert ((expr as ast.CallExpr).args[0].expr as ast.IntegerLiteral).val == "4"
	assert ((expr as ast.CallExpr).args[1].expr as ast.IntegerLiteral).val == "1"
	assert ((expr as ast.CallExpr).args[2].expr as ast.IntegerLiteral).val == "5"
	assert ((expr as ast.CallExpr).args[3].expr as ast.IntegerLiteral).val == "0"
	assert ((expr as ast.CallExpr).args[4].expr as ast.IntegerLiteral).val == "0"
	assert ((expr as ast.CallExpr).args[5].expr as ast.IntegerLiteral).val == "0"

	expr, _ = compile_expr('obj.FuncWithOptionalArgs(arg6 = 6, arg5 = 66, arg3 = 5, arg1 = 44, arg2 = 1)')
	assert (expr as ast.CallExpr).obj_name == "ABCD"
	assert (expr as ast.CallExpr).return_type == ast.none_type
	assert (expr as ast.CallExpr).args.len == 6
	assert ((expr as ast.CallExpr).args[0].expr as ast.IntegerLiteral).val == "44"
	assert ((expr as ast.CallExpr).args[1].expr as ast.IntegerLiteral).val == "1"
	assert ((expr as ast.CallExpr).args[2].expr as ast.IntegerLiteral).val == "5"
	assert ((expr as ast.CallExpr).args[3].expr as ast.IntegerLiteral).val == "0"
	assert ((expr as ast.CallExpr).args[4].expr as ast.IntegerLiteral).val == "66"
	assert ((expr as ast.CallExpr).args[5].expr as ast.IntegerLiteral).val == "6"

	expr, _ = compile_expr("otherProp.MethodFoo(True, False, true)")
	assert (expr as ast.CallExpr).obj_name == "OtherScript"
	assert (expr as ast.CallExpr).name == "MethodFoo"
	assert (expr as ast.CallExpr).return_type == ast.string_type
	assert (expr as ast.CallExpr).args.len == 3


	// call method self property with a name equivalent to object
	// string Function MethodFoo(bool arg1, bool arg2, bool arg3)
	expr, table = compile_expr("OtherScript2.MethodFoo(false, True, True)")
	call_expr := expr as ast.CallExpr
	
	assert call_expr.obj_name == "OtherScript"
	assert call_expr.name == "MethodFoo"
	assert call_expr.return_type == ast.string_type
	assert call_expr.is_global == false
	assert (call_expr.left as ast.Ident).name == "OtherScript2"
	assert (call_expr.left as ast.Ident).typ == table.find_type_idx("OtherScript")
	assert call_expr.args.len == 3
	assert (call_expr.args[0].expr as ast.BoolLiteral).val == "false"
	assert call_expr.args[0].typ == ast.bool_type
	assert (call_expr.args[1].expr as ast.BoolLiteral).val == "True"
	assert call_expr.args[1].typ == ast.bool_type
	assert (call_expr.args[2].expr as ast.BoolLiteral).val == "True"
	assert call_expr.args[2].typ == ast.bool_type
}

fn test_cast_expr() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()

	//to bool
	expr, _ = compile_expr('1 as Bool')
	assert (expr as ast.CastExpr).typ == ast.bool_type

	expr, _ = compile_expr('0.4 as Bool')
	assert (expr as ast.CastExpr).typ == ast.bool_type

	expr, _ = compile_expr('"hello" as Bool')
	assert (expr as ast.CastExpr).typ == ast.bool_type

	expr, _ = compile_expr('(new String[5]) as Bool')
	assert (expr as ast.CastExpr).typ == ast.bool_type

	expr, _ = compile_expr('obj as Bool')
	assert (expr as ast.CastExpr).typ == ast.bool_type

	//to int
	expr, _ = compile_expr('True as Int')
	assert (expr as ast.CastExpr).typ == ast.int_type
	
	expr, _ = compile_expr('10.05 as Int')
	assert (expr as ast.CastExpr).typ == ast.int_type
	
	expr, _ = compile_expr('"30" as Int')
	assert (expr as ast.CastExpr).typ == ast.int_type

	// to float
	expr, _ = compile_expr('True as Float')
	assert (expr as ast.CastExpr).typ == ast.float_type

	expr, _ = compile_expr('10 as Float')
	assert (expr as ast.CastExpr).typ == ast.float_type

	expr, _ = compile_expr('"16.007" as Float')
	assert (expr as ast.CastExpr).typ == ast.float_type

	// to string
	expr, _ = compile_expr('True as String')
	assert (expr as ast.CastExpr).typ == ast.string_type
	
	expr, _ = compile_expr('10 as String')
	assert (expr as ast.CastExpr).typ == ast.string_type
	
	expr, _ = compile_expr('0.01007 as String')
	assert (expr as ast.CastExpr).typ == ast.string_type
	
	expr, _ = compile_expr('obj as String')
	assert (expr as ast.CastExpr).typ == ast.string_type
	
	expr, _ = compile_expr('(new String[5]) as String')
	assert (expr as ast.CastExpr).typ == ast.string_type

	// to object
	expr, table = compile_expr('obj as CDFG')
	assert (expr as ast.CastExpr).typ == table.find_type_idx("CDFG")

}

fn test_par_expr() {
	mut expr := &ast.Expr(ast.EmptyExpr{})

	expr, _ = compile_expr('(123.123 + 321.321)')
	assert (expr as ast.ParExpr).expr is ast.InfixExpr
	assert ((expr as ast.ParExpr).expr as ast.InfixExpr).result_type == ast.float_type
}

fn test_array() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()

	expr, table = compile_expr('new float[20]')
	assert (expr as ast.ArrayInit).typ == table.find_type_idx("float[]")

	expr, _ = compile_expr('(new float[20])[4]')
	assert (expr as ast.IndexExpr).typ == ast.float_type

	expr, _ = compile_expr('(new float[20]).length')
	assert (expr as ast.SelectorExpr).typ == ast.int_type

	expr, _ = compile_expr('(new string[20]).find("one", 2)')
	assert (expr as ast.CallExpr).return_type == ast.int_type

	expr, _ = compile_expr('(new float[20]).find(none)')
	assert (expr as ast.CallExpr).return_type == ast.int_type
	
	expr, _ = compile_expr('(new string[20]).find(none, 2)')
	assert (expr as ast.CallExpr).return_type == ast.int_type

	expr, _ = compile_expr('(new string[20]).rfind(none)')
	assert (expr as ast.CallExpr).return_type == ast.int_type

	expr, _ = compile_expr('(new bool[20]).rfind(none, -1)')
	assert (expr as ast.CallExpr).return_type == ast.int_type
}

fn test_autocast_assign() {
	mut stmt := &ast.Stmt(ast.Comment{})
	mut table := ast.new_table()
	
	// to bool
	stmt, _ = compile_stmt("arg4 = None")
	assert (stmt as ast.AssignStmt).typ == ast.bool_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.bool_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.NoneLiteral).val == "None"

	stmt, _ = compile_stmt("arg4 = 100")
	assert (stmt as ast.AssignStmt).typ == ast.bool_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.bool_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.IntegerLiteral).val == "100"

	stmt, _ = compile_stmt("arg4 = 0.15")
	assert (stmt as ast.AssignStmt).typ == ast.bool_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.bool_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.FloatLiteral).val == "0.15"

	stmt, _ = compile_stmt("arg4 = \"hello\"")
	assert (stmt as ast.AssignStmt).typ == ast.bool_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.bool_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.StringLiteral).val == "hello"

	stmt, table = compile_stmt("arg4 = obj")
	assert (stmt as ast.AssignStmt).typ == ast.bool_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.bool_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.Ident).typ == table.find_type_idx("ABCD")

	stmt, _ = compile_stmt("arg4 = new float[20]")
	assert (stmt as ast.AssignStmt).typ == ast.bool_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.bool_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.ArrayInit).typ == table.find_type_idx("float[]")

	// to float
	stmt, _ = compile_stmt("arg3 = 100")
	assert (stmt as ast.AssignStmt).typ == ast.float_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.float_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.IntegerLiteral).val == "100"
	
	// to string
	stmt, _ = compile_stmt("arg1 = None")
	assert (stmt as ast.AssignStmt).typ == ast.string_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.string_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.NoneLiteral).val == "None"

	stmt, _ = compile_stmt("arg1 = True")
	assert (stmt as ast.AssignStmt).typ == ast.string_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.string_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.BoolLiteral).val == "True"

	stmt, table = compile_stmt("arg1 = 100")
	assert (stmt as ast.AssignStmt).typ == ast.string_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.string_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.IntegerLiteral).val == "100"

	stmt, _ = compile_stmt("arg1 = 0.15")
	assert (stmt as ast.AssignStmt).typ == ast.string_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.string_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.FloatLiteral).val == "0.15"

	stmt, table = compile_stmt("arg1 = obj")
	assert (stmt as ast.AssignStmt).typ == ast.string_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.string_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.Ident).typ == table.find_type_idx("ABCD")

	stmt, _ = compile_stmt("arg1 = new float[20]")
	assert (stmt as ast.AssignStmt).typ == ast.string_type
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == ast.string_type
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.ArrayInit).typ == table.find_type_idx("float[]")

	// to object
	stmt, table = compile_stmt("pobj = obj")
	assert (stmt as ast.AssignStmt).typ == table.find_type_idx("CDFG")
	assert ((stmt as ast.AssignStmt).right as ast.CastExpr).typ == table.find_type_idx("CDFG")
	assert (((stmt as ast.AssignStmt).right as ast.CastExpr).expr as ast.Ident).typ == table.find_type_idx("ABCD")
}

fn test_autocast_infix() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()

	// to float
	expr, _ = compile_expr("1 + 0.15")
	assert ((expr as ast.InfixExpr).left as ast.CastExpr).typ == ast.float_type
	assert (((expr as ast.InfixExpr).left as ast.CastExpr).expr as ast.IntegerLiteral).val == "1"

	expr, _ = compile_expr("0.15 + 1")
	assert ((expr as ast.InfixExpr).right as ast.CastExpr).typ == ast.float_type
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.IntegerLiteral).val == "1"

	// to string
	expr, _ = compile_expr("\"hello\" + None")
	assert ((expr as ast.InfixExpr).right as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.NoneLiteral).val == "None"

	expr, _ = compile_expr("None + \"hello\"")
	assert ((expr as ast.InfixExpr).left as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).left as ast.CastExpr).expr as ast.NoneLiteral).val == "None"

	expr, _ = compile_expr("\"hello\" + True")
	assert ((expr as ast.InfixExpr).right as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.BoolLiteral).val == "True"

	expr, _ = compile_expr("True + \"hello\"")
	assert ((expr as ast.InfixExpr).left as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).left as ast.CastExpr).expr as ast.BoolLiteral).val == "True"

	expr, _ = compile_expr("\"hello\" + 1")
	assert ((expr as ast.InfixExpr).right as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.IntegerLiteral).val == "1"

	expr, _ = compile_expr("1 + \"hello\"")
	assert ((expr as ast.InfixExpr).left as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).left as ast.CastExpr).expr as ast.IntegerLiteral).val == "1"

	expr, _ = compile_expr("\"hello\" + 0.0016")
	assert ((expr as ast.InfixExpr).right as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.FloatLiteral).val == "0.0016"

	expr, _ = compile_expr("0.0016 + \"hello\"")
	assert ((expr as ast.InfixExpr).left as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).left as ast.CastExpr).expr as ast.FloatLiteral).val == "0.0016"

	expr, table = compile_expr("\"hello\" + obj")
	assert ((expr as ast.InfixExpr).right as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.Ident).typ == table.find_type_idx("ABCD")

	expr, table = compile_expr("obj + \"hello\"")
	assert ((expr as ast.InfixExpr).left as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).left as ast.CastExpr).expr as ast.Ident).typ == table.find_type_idx("ABCD")

	expr, table = compile_expr("\"hello\" + new float[20]")
	assert ((expr as ast.InfixExpr).right as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.ArrayInit).typ == table.find_type_idx("float[]")


	expr, table = compile_expr("new float[20] + \"hello\"")
	assert ((expr as ast.InfixExpr).left as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.InfixExpr).left as ast.CastExpr).expr as ast.ArrayInit).typ == table.find_type_idx("float[]")
}

fn test_autocast_call() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()

	// to bool
	expr, _ = compile_expr("FuncBoolArg(None)")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.bool_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.NoneLiteral).val == "None"

	expr, _ = compile_expr("FuncBoolArg(1)")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.bool_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.IntegerLiteral).val == "1"

	expr, _ = compile_expr("FuncBoolArg(0.0199)")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.bool_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.FloatLiteral).val == "0.0199"

	expr, _ = compile_expr("FuncBoolArg(\"hello2\")")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.bool_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.StringLiteral).val == "hello2"

	expr, table = compile_expr("FuncBoolArg(obj)")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.bool_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.Ident).typ == table.find_type_idx("ABCD")

	expr, table = compile_expr("FuncBoolArg(new int[20])")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.bool_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.ArrayInit).typ == table.find_type_idx("int[]")

	// to float
	expr, _ = compile_expr("FuncFloatArg(1)")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.float_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.IntegerLiteral).val == "1"

	// to string
	expr, _ = compile_expr("FuncStringArg(None)")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.NoneLiteral).val == "None"

	expr, _ = compile_expr("FuncStringArg(False)")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.BoolLiteral).val == "False"

	expr, _ = compile_expr("FuncStringArg(1)")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.IntegerLiteral).val == "1"

	expr, _ = compile_expr("FuncStringArg(0.0199)")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.FloatLiteral).val == "0.0199"

	expr, table = compile_expr("FuncStringArg(obj)")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.Ident).typ == table.find_type_idx("ABCD")

	expr, table = compile_expr("FuncStringArg(new int[20])")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == ast.string_type
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.ArrayInit).typ == table.find_type_idx("int[]")

	// to object
	expr, table = compile_expr("FuncObjectArg(obj)")
	assert ((expr as ast.CallExpr).args[0].expr as ast.CastExpr).typ == table.find_type_idx("CDFG")
	assert (((expr as ast.CallExpr).args[0].expr as ast.CastExpr).expr as ast.Ident).typ == table.find_type_idx("ABCD")
}

fn test_operator_priority() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()

	expr, _ = compile_expr("1 + 2 - 3")
	assert ((expr as ast.InfixExpr).right as ast.IntegerLiteral).val == "3"
	expr = &(expr as ast.InfixExpr).left
	assert ((expr as ast.InfixExpr).right as ast.IntegerLiteral).val == "2"
	assert ((expr as ast.InfixExpr).left as ast.IntegerLiteral).val == "1"
	
	expr, _ = compile_expr("1 / 2 * 3 % 4")
	assert ((expr as ast.InfixExpr).right as ast.IntegerLiteral).val == "4"
	expr = &(expr as ast.InfixExpr).left
	assert ((expr as ast.InfixExpr).right as ast.IntegerLiteral).val == "3"
	expr = &(expr as ast.InfixExpr).left
	assert ((expr as ast.InfixExpr).right as ast.IntegerLiteral).val == "2"
	assert ((expr as ast.InfixExpr).left as ast.IntegerLiteral).val == "1"

	expr, table = compile_expr("obj as CDFG.myAutoParentProp")
	assert (expr as ast.SelectorExpr).field_name == "myAutoParentProp"
	assert (expr as ast.SelectorExpr).typ == ast.float_type
	expr = &(expr as ast.SelectorExpr).expr
	assert (expr as ast.CastExpr).type_name == "CDFG"
	assert (expr as ast.CastExpr).typ == table.find_type_idx("CDFG")
	expr = &(expr as ast.CastExpr).expr
	assert (expr as ast.Ident).name == "obj"
	assert (expr as ast.Ident).typ == table.find_type_idx("ABCD")

	expr, _ = compile_expr("1 || 2 && 3")
	assert (expr as ast.InfixExpr).op == .logical_or
	assert (((expr as ast.InfixExpr).left as ast.CastExpr).expr as ast.IntegerLiteral).val == "1"
	expr = &(expr as ast.InfixExpr).right
	assert (expr as ast.InfixExpr).op == .logical_and
	assert (((expr as ast.InfixExpr).left as ast.CastExpr).expr as ast.IntegerLiteral).val == "2"
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.IntegerLiteral).val == "3"

	expr, _ = compile_expr("1 && 2 || 3")
	assert (expr as ast.InfixExpr).op == .logical_or
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.IntegerLiteral).val == "3"
	expr = &(expr as ast.InfixExpr).left
	assert (expr as ast.InfixExpr).op == .logical_and
	assert (((expr as ast.InfixExpr).left as ast.CastExpr).expr as ast.IntegerLiteral).val == "1"
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.IntegerLiteral).val == "2"

	expr, _ = compile_expr("(1 || 2) && 3")
	assert (expr as ast.InfixExpr).op == .logical_and
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.IntegerLiteral).val == "3"
	expr = &((expr as ast.InfixExpr).left as ast.ParExpr).expr
	assert (expr as ast.InfixExpr).op == .logical_or
	assert (((expr as ast.InfixExpr).left as ast.CastExpr).expr as ast.IntegerLiteral).val == "1"
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.IntegerLiteral).val == "2"

	expr, _ = compile_expr("2 + -arg2")
	assert (expr as ast.InfixExpr).op == .plus
	assert ((expr as ast.InfixExpr).left as ast.IntegerLiteral).val == "2"
	expr = &(expr as ast.InfixExpr).right
	assert (expr as ast.PrefixExpr).op == .minus
	expr = &(expr as ast.PrefixExpr).right
	assert (expr as ast.Ident).name == "arg2"

	expr, _ = compile_expr("1 * (2 + 3)")
	assert (expr as ast.InfixExpr).op == .mul
	assert ((expr as ast.InfixExpr).left as ast.IntegerLiteral).val == "1"
	expr = &((expr as ast.InfixExpr).right as ast.ParExpr).expr
	assert (expr as ast.InfixExpr).op == .plus
	assert ((expr as ast.InfixExpr).left as ast.IntegerLiteral).val == "2"
	assert ((expr as ast.InfixExpr).right as ast.IntegerLiteral).val == "3"

	expr, _ = compile_expr("1 + 2 * 3 == 4 && 5 || -arg2")
	assert (expr as ast.InfixExpr).op == .logical_or
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.PrefixExpr).op == .minus
	assert ((((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.PrefixExpr).right as ast.Ident).name == "arg2"
	expr = &(expr as ast.InfixExpr).left
	assert (expr as ast.InfixExpr).op == .logical_and
	assert (((expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.IntegerLiteral).val == "5"
	expr = &(expr as ast.InfixExpr).left
	assert (expr as ast.InfixExpr).op == .eq
	assert ((expr as ast.InfixExpr).right as ast.IntegerLiteral).val == "4"
	expr = &(expr as ast.InfixExpr).left
	assert (expr as ast.InfixExpr).op == .plus
	assert ((expr as ast.InfixExpr).left as ast.IntegerLiteral).val == "1"
	expr = &(expr as ast.InfixExpr).right
	assert (expr as ast.InfixExpr).op == .mul
	assert ((expr as ast.InfixExpr).left as ast.IntegerLiteral).val == "2"
	assert ((expr as ast.InfixExpr).right as ast.IntegerLiteral).val == "3"
}

fn test_expr_bug() {
	mut stmt := &ast.Stmt(ast.Comment{})

	 //parser error
	stmt, _ = compile_stmt("
	If obj == obj\n
	(pobj as ABCD).myAutoProp = 11\n
	EndIf")

	assert (((stmt as ast.If).branches[0] as ast.IfBranch).cond as ast.InfixExpr).op == .eq
	assert ((((stmt as ast.If).branches[0] as ast.IfBranch).cond as ast.InfixExpr).left as ast.Ident).name == "obj"
	assert ((((stmt as ast.If).branches[0] as ast.IfBranch).cond as ast.InfixExpr).right as ast.Ident).name == "obj"
	assert (((stmt as ast.If).branches[0] as ast.IfBranch).stmts[0] as ast.AssignStmt).op == .assign
	assert ((((stmt as ast.If).branches[0] as ast.IfBranch).stmts[0] as ast.AssignStmt).right as ast.IntegerLiteral).val == "11"
	assert (((stmt as ast.If).branches[0] as ast.IfBranch).stmts[0] as ast.AssignStmt).left is ast.SelectorExpr
}

fn test_expr_bug2() {
	mut stmt := &ast.Stmt(ast.Comment{})

	 //parser error
	stmt, _ = compile_stmt("
	If (pobj as ABCD).myAutoProp\n
	(pobj as ABCD).myAutoProp = 11\n
	EndIf")

	assert ((stmt as ast.If).branches[0].cond as ast.SelectorExpr).field_name == "myAutoProp"
	assert ((((stmt as ast.If).branches[0].cond as ast.SelectorExpr).expr as ast.ParExpr).expr as ast.CastExpr).type_name == "ABCD"
	assert (((((stmt as ast.If).branches[0].cond as ast.SelectorExpr).expr as ast.ParExpr).expr as ast.CastExpr).expr as ast.Ident).name == "pobj"
	assert ((stmt as ast.If).branches[0].stmts[0] as ast.AssignStmt).op == .assign
	assert (((stmt as ast.If).branches[0].stmts[0] as ast.AssignStmt).right as ast.IntegerLiteral).val == "11"
	assert ((stmt as ast.If).branches[0].stmts[0] as ast.AssignStmt).left is ast.SelectorExpr
	
	stmt, _ = compile_stmt("\"Hello\" + pobj.ParentFoz(1, 2)")

	assert ((stmt as ast.ExprStmt).expr as ast.InfixExpr).op == .plus
	assert (((stmt as ast.ExprStmt).expr as ast.InfixExpr).left as ast.StringLiteral).val == "Hello"
	assert (((stmt as ast.ExprStmt).expr as ast.InfixExpr).right as ast.CastExpr).type_name == "String"
	assert (((((stmt as ast.ExprStmt).expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.CallExpr).left as ast.Ident).name == "pobj"
	assert ((((stmt as ast.ExprStmt).expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.CallExpr).obj_name == "CDFG"
	assert ((((stmt as ast.ExprStmt).expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.CallExpr).name == "ParentFoz"
	assert (((((stmt as ast.ExprStmt).expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.CallExpr).args[0].expr as ast.IntegerLiteral).val == "1"
	assert (((((stmt as ast.ExprStmt).expr as ast.InfixExpr).right as ast.CastExpr).expr as ast.CallExpr).args[1].expr as ast.IntegerLiteral).val == "2"
}

fn test_expr_bug3() {
	mut stmts := []ast.Stmt{}

	 //parser error
	stmts, _ = compile_stmts("Int MyBugVar = 123\n-1")
	assert stmts.len == 2
	assert (((stmts[0] as ast.VarDecl).assign as ast.AssignStmt).right as ast.IntegerLiteral).val == "123"
	assert ((stmts[1] as ast.ExprStmt).expr as ast.IntegerLiteral).val == "-1"
}

fn test_expr_bug4() {
	mut stmt := &ast.Stmt(ast.Comment{})

	 //parser error
	stmt, _ = compile_stmt("
	While True\n
	arg2\n
	EndWhile")
	assert (((stmt as ast.While).stmts[0] as ast.ExprStmt).expr as ast.Ident).name == "arg2"
	assert ((stmt as ast.While).cond as ast.BoolLiteral).val == "True"
}

fn test_state() {
	mut stmts := []ast.TopStmt{}

	stmts, _ = compile_top_stmts("
		State Ready
		EndState
		State Ready
		int Function Foz(int n1, int n2)
		return 0
		EndFunction
		EndState")

	assert (stmts[stmts.len - 2] as ast.StateDecl).name == "Ready"
	assert (stmts[stmts.len - 2] as ast.StateDecl).fns.len == 0
	assert (stmts[stmts.len - 1] as ast.StateDecl).name == "Ready"
	assert (stmts[stmts.len - 1] as ast.StateDecl).fns.len == 1
}

fn test_using_var_before_decl() {
	mut stmts := []ast.Stmt{}

	stmts, _ = compile_stmts("
		myIntVar + 1
		Int myIntVar = 12")

	assert ((stmts[0] as ast.ExprStmt).expr as ast.InfixExpr).op == .plus
	assert (((stmts[0] as ast.ExprStmt).expr as ast.InfixExpr).left as ast.Ident).name == "myIntVar"
	assert (((stmts[0] as ast.ExprStmt).expr as ast.InfixExpr).left as ast.Ident).typ == ast.int_type
	assert (((stmts[0] as ast.ExprStmt).expr as ast.InfixExpr).right as ast.IntegerLiteral).val == "1"
	assert ((stmts[0] as ast.ExprStmt).expr as ast.InfixExpr).left_type == ast.int_type
	assert ((stmts[0] as ast.ExprStmt).expr as ast.InfixExpr).right_type == ast.int_type
	assert ((stmts[0] as ast.ExprStmt).expr as ast.InfixExpr).result_type == ast.int_type

	assert (stmts[1] as ast.VarDecl).obj_name == "ABCD"
	assert (stmts[1] as ast.VarDecl).name == "myIntVar"
	assert (stmts[1] as ast.VarDecl).is_object_var == false
	assert ((stmts[1] as ast.VarDecl).assign as ast.AssignStmt).op == .assign
	assert (((stmts[1] as ast.VarDecl).assign as ast.AssignStmt).left as ast.Ident).name == "myIntVar"
	assert (((stmts[1] as ast.VarDecl).assign as ast.AssignStmt).left as ast.Ident).typ == ast.int_type
	assert (((stmts[1] as ast.VarDecl).assign as ast.AssignStmt).right as ast.IntegerLiteral).val == "12"
}

fn test_return() {
	mut stmts := []ast.TopStmt{}

	stmts, _ = compile_top_stmts("
		Function MyFunc()
			return
		EndFunction")
	
	func := stmts.last() as ast.FnDecl

	assert func.name == "MyFunc"
	assert func.params.len == 0
	assert func.flags.len == 0
	assert func.is_native == false
	assert func.is_global == false
	assert func.is_event == false
	assert func.return_type == ast.none_type

	ret_stmt := func.stmts.last() as ast.Return
	assert (ret_stmt.expr as ast.NoneLiteral).val == "None"
}