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
float Function Bar(string s1, string s2) Global
EndFunction
int Property myAutoProp = 123 Auto\n"
)

fn compile(src string) (&ast.File, &ast.Table) {
	full_src := "${src_template}Function Bar(string arg1, int arg2, ABCD obj)\n${src}\nEndFunction\n"
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
	assert file.stmts.len == 7
	assert file.stmts[5] is ast.FnDecl
	func := file.stmts[5] as ast.FnDecl
	assert func.stmts.len > 0

	return &func.stmts[0], table
}

fn compile_expr(src string) (&ast.Expr, &ast.Table) {
	mut stmt, table := compile_stmt(src)
	assert stmt is ast.ExprStmt
	return &(stmt as ast.ExprStmt).expr, table
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

	expr, _ = compile_expr('myParentObjectVar') //object var
	assert expr is ast.Ident
	assert (expr as ast.Ident).typ == ast.string_type

	expr, _ = compile_expr('myAutoParentProp') //object property
	assert expr is ast.Ident
	assert (expr as ast.Ident).typ == ast.float_type
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

fn test_props() {
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
}

fn test_vars() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()
	
	expr, _ = compile_expr('obj.myObjectVar')
	assert (expr as ast.SelectorExpr).typ == ast.bool_type

	expr, _ = compile_expr('myObjectVar')
	assert (expr as ast.Ident).typ == ast.bool_type
	
	expr, _ = compile_expr('obj.myParentObjectVar')
	assert (expr as ast.SelectorExpr).typ == ast.string_type

	expr, _ = compile_expr('myParentObjectVar')
	assert (expr as ast.Ident).typ == ast.string_type
}

fn test_par_expr() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()

	expr, _ = compile_expr('(123.123 + 321.321)')
	assert (expr as ast.ParExpr).expr is ast.InfixExpr
	assert ((expr as ast.ParExpr).expr as ast.InfixExpr).result_type == ast.float_type
}

fn test_array() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()

	expr, table = compile_expr('new float[20]')
	assert (expr as ast.ArrayInit).typ == table.find_type_idx("float[]")

	expr, table = compile_expr('(new float[20])[4]')
	assert (expr as ast.IndexExpr).typ == ast.float_type

	expr, table = compile_expr('(new float[20]).length')
	assert (expr as ast.SelectorExpr).typ == ast.int_type

	expr, table = compile_expr('(new string[20]).find("one", 2)')
	assert (expr as ast.CallExpr).return_type == ast.int_type

	expr, table = compile_expr('(new float[20]).find(none)')
	assert (expr as ast.CallExpr).return_type == ast.int_type
	
	expr, table = compile_expr('(new string[20]).find(none, 2)')
	assert (expr as ast.CallExpr).return_type == ast.int_type

	expr, table = compile_expr('(new string[20]).rfind(none)')
	assert (expr as ast.CallExpr).return_type == ast.int_type

	expr, table = compile_expr('(new bool[20]).rfind(none, -1)')
	assert (expr as ast.CallExpr).return_type == ast.int_type
}

fn test_prefix_expr() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()
	
	expr, _ = compile_expr('!False')
	assert (expr as ast.PrefixExpr).op == token.Kind.not
	assert (expr as ast.PrefixExpr).right_type == ast.bool_type
	
	expr, _ = compile_expr('-arg2')
	assert (expr as ast.PrefixExpr).op == token.Kind.minus
	assert (expr as ast.PrefixExpr).right_type == ast.int_type
	assert ((expr as ast.PrefixExpr).right as ast.Ident).typ == ast.int_type
}

fn test_literals() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()

	expr, table = compile_expr('123')
	assert expr is ast.IntegerLiteral

	expr, table = compile_expr('-123')
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

fn test_infix() {
	mut expr := &ast.Expr(ast.EmptyExpr{})
	mut table := ast.new_table()
	
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

fn test_autocast() {
	//TODO
}

fn test_operator_priority() {
	//TODO
}