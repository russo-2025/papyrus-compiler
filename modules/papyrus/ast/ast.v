module ast

import papyrus.ast
import papyrus.token

pub type TopStmt = ScriptDecl | FnDecl | Comment | PropertyDecl | VarDecl | StateDecl
pub type Stmt =  Return | If | While | ExprStmt | AssignStmt | VarDecl | Comment

[heap]
pub struct File {
pub mut:
	path			string // '..../src/file.psc'
	path_base		string // file.psc'
	file_name		string // 'file'
	obj_name		string
	stmts			[]TopStmt
	imports			[]string
	scope			&Scope
	last_mod_time	int
	used_indents	[]string
}

[unsafe]
pub fn (f &File) free() {
	unsafe {
		f.path.free()
		f.path_base.free()
		f.file_name.free()
		f.obj_name.free()
		f.stmts.free()
		f.imports.free()
		f.scope.free()
		f.used_indents.free()
	}
}

pub struct ScriptDecl {
pub mut:
	pos				token.Position
	name			string
	name_pos		token.Position

	parent_name		string
	parent_pos		token.Position
	flags			[]token.Kind
}

pub struct StateDecl {
pub mut:
	pos		token.Position
	name	string
	fns		[]FnDecl
}

pub struct FnArg {
pub mut:
	name			string
	typ				ast.Type
	default_value	Expr
}

pub struct FnDecl {
pub mut:
	name			string
	pos				token.Position
	params			[]ast.Param
	
	stmts			[]Stmt
	return_type		ast.Type
	flags			[]token.Kind
	scope			&Scope
	no_body			bool
	is_static		bool
	is_event		bool
}

pub struct Empty {}
pub type Handler = Empty | FnDecl

pub struct PropertyDecl {
pub mut:
	name		string
	pos			token.Position
	typ			ast.Type
	flags		[]token.Kind
	expr		Expr
	read		Handler
	write		Handler
}

pub struct Return {
pub mut:
	pos		token.Position
	expr	Expr
}

pub struct IfBranch {
pub:
	cond		Expr
	pos			token.Position
	stmts		[]Stmt
}

pub struct If {
pub:
	pos			token.Position
	branches	[]IfBranch // includes all `if/elseif/else` branches
	has_else	bool
}

pub struct While {
pub:
	pos		token.Position
	cond	Expr
	stmts	[]Stmt
}

pub struct ExprStmt {
pub:
	expr     Expr
	pos      token.Position
}

pub struct AssignStmt {
pub:
	pos			token.Position
pub mut:
	op			token.Kind
	right		Expr
	left		Expr
	typ			ast.Type	
}

pub struct VarDecl {
pub mut:
	typ			ast.Type
	obj_name	string
	name		string
	assign		AssignStmt
	pos			token.Position
	flags		[]token.Kind
	is_obj_var	bool
}

pub struct Comment {
pub:
	text	string
	pos		token.Position
}