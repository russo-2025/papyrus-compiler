module ast

import papyrus.table
import papyrus.token

pub type TopStmt = ScriptDecl | FnDecl | Comment
pub type Stmt =  Return | If | While | ExprStmt | AssignStmt | VarDecl | Comment

pub struct File {
pub:
	path			string // '..../src/file.psc'
	path_base		string // file.psc'
	file_name		string // 'file'
	stmts			[]TopStmt
	scope			&Scope
	last_mod_time	int
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

pub struct FnArg {
pub mut:
	name			string
	typ				table.Type
	default_value	Expr
}

pub struct FnDecl {
pub mut:
	name            string
	pos             token.Position
	params			[]table.Param
	
	stmts			[]Stmt
	return_type		table.Type
	flags			[]token.Kind
	scope			&Scope
	no_body			bool
	is_static		bool
	is_event		bool
}

pub struct Return {
pub:
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
	typ			table.Type	
}

pub struct VarDecl {
pub mut:
	typ			table.Type
	name		string
	//expr		Expr
	assign		AssignStmt
	pos			token.Position
}

pub struct Comment {
	text	string
}