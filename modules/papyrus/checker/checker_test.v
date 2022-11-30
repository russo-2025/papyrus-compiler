import pref
import papyrus.ast
import papyrus.parser
import papyrus.checker
import papyrus.token

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
"Scriptname CDFG
string myParentObjectVar = \"Hello\"
float Property myAutoParentProp = 0.2 Auto
int Function ParentFoz(int n1, int n2)
EndFunction\n"

	src_template = 
"Scriptname ABCD extends CDFG
bool myObjectVar = false
int Function Foz(int n1, int n2)
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
float Function Bar(string s1, string s2) Global
EndFunction
int Property myAutoProp = 123 Auto\n"
)

fn compile(src string) (&ast.File, &ast.Table) {
	full_src := "${src_template}Function Bar(string arg1, int arg2, float arg3, bool arg4, ABCD obj, CDFG pobj)\n${src}\nEndFunction\n"
	mut table := ast.new_table()
	global_scope := &ast.Scope{
		parent: 0
	}
	
	mut parent_file := parser.parse_text("::gen_test.v/parent::", parent_src, table, prefs, global_scope)
	mut file := parser.parse_text("::gen_test.v/src::", full_src, table, prefs, global_scope)

	mut c := checker.new_checker(table, prefs)

	c.check(mut parent_file)
	c.check(mut file)

	assert c.errors.len == 0, src

	//println(file.stmts)

	return file, table
}

fn compile_stmt(src string) (&ast.Stmt, &ast.Table) {
	mut file, table := compile(src)
	assert file.stmts.len == 13
	assert file.stmts[11] is ast.FnDecl
	func := file.stmts[11] as ast.FnDecl
	assert func.stmts.len > 0

	return &func.stmts[0], table
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
	assert (expr as ast.InfixExpr).op == token.Kind.and
	assert (expr as ast.InfixExpr).result_type == ast.bool_type

	expr, _ = compile_expr('True || False')
	assert (expr as ast.InfixExpr).op == token.Kind.logical_or
	assert (expr as ast.InfixExpr).result_type == ast.bool_type
}

fn test_ident() {
	mut expr := &ast.Expr(ast.EmptyExpr{})

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
}

fn test_kw_parent_self() {
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
}

fn test_object_props() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	
	expr, _ = compile_expr('obj.myAutoProp')
	assert (expr as ast.SelectorExpr).typ == ast.int_type

	expr, _ = compile_expr('myAutoProp')
	assert (expr as ast.Ident).typ == ast.int_type
	
	expr, _ = compile_expr('obj.myAutoParentProp')
	assert (expr as ast.SelectorExpr).typ == ast.float_type

	expr, _ = compile_expr('myAutoParentProp')
	assert (expr as ast.Ident).typ == ast.float_type
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

	expr, _ = compile_expr('ABCD.Bar("hello", "V")')
	assert (expr as ast.CallExpr).obj_name == "ABCD"
	assert (expr as ast.CallExpr).return_type == ast.float_type
	assert (expr as ast.CallExpr).args.len == 2
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
	//TODO
}