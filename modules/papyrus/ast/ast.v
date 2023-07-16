module ast

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
	last_mod_time	i64
	used_indents	[]string
}

pub struct ScriptDecl {
pub mut:
	pos					token.Position
	name				string
	name_pos			token.Position

	parent_name			string
	parent_pos			token.Position
	flags				[]token.Kind
}

pub struct StateDecl {
pub mut:
	pos			token.Position
	name		string
	fns			[]FnDecl
	is_auto		bool //flag
}

pub struct FnArg {
pub mut:
	name			string
	typ				Type
	default_value	Expr
}

pub struct FnDecl {
pub mut:
	name			string
	pos				token.Position
	params			[]Param
	
	stmts			[]Stmt
	return_type		Type
	flags			[]token.Kind
	scope			&Scope
	is_native		bool //flag
	is_global		bool //flag
	is_event		bool
}

pub struct Empty {}
pub type Handler = FnDecl | Empty

pub struct PropertyDecl {
pub mut:
	name				string
	pos					token.Position
	typ					Type
	auto_var_name		string
	expr				Expr
	read				Handler
	write				Handler

	is_auto				bool //flag
	is_autoread			bool //flag
	is_hidden			bool //flag
	is_conditional		bool //flag
}

pub struct Return {
pub mut:
	pos		token.Position
	expr	Expr
}

pub struct IfBranch {
pub:
	pos			token.Position
	stmts		[]Stmt
	scope		&Scope
pub mut:
	cond		Expr
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
	stmts	[]Stmt
	scope	&Scope
pub mut:
	cond	Expr
}

pub struct ExprStmt {
pub:
	pos      token.Position
pub mut:
	expr     Expr
}

pub struct AssignStmt {
pub:
	pos			token.Position
pub mut:
	op			token.Kind
	right		Expr
	left		Expr
	typ		 	Type
}

pub struct VarDecl {
pub mut:
	typ				Type
	obj_name		string
	name			string
	assign			AssignStmt
	pos				token.Position
	flags			[]token.Kind
	is_object_var	bool
}

pub struct Comment {
pub:
	text	string
	pos		token.Position
}