module checker

import papyrus.ast
import pref
import papyrus.table
import papyrus.token
import papyrus.errors
import papyrus.util

pub struct Checker {
	pref			&pref.Preferences
pub mut:
	table			&table.Table
	file			&ast.File = 0
	errors			[]errors.Error
	warnings		[]errors.Warning

	cur_fn			&ast.FnDecl = 0
	fn_scope		&ast.Scope = voidptr(0)
	mod				string // current module name
}

pub fn new_checker(table &table.Table, pref &pref.Preferences) Checker {
	return Checker{
		table: table
		pref: pref
		cur_fn: 0
	}
}

pub fn (mut c Checker) check_files(ast_files []ast.File) {

	for i in 0 .. ast_files.len {
		file := unsafe { &ast_files[i] }
		c.check(file)
	}
}

pub fn (mut c Checker) check(ast_file &ast.File) {
	c.file = ast_file

	for stmt in ast_file.stmts {
		c.top_stmt(stmt)
	}
}

fn (mut c Checker) top_stmt(node ast.TopStmt) {
	match mut node {
		ast.ScriptDecl {
			c.mod = node.name

			if node.parent_name != "" {
				if !c.table.known_type(node.parent_name) {
					c.error("invalid parent `$node.parent_name`", node.pos)
				}
			}
		}
		ast.FnDecl {
			c.fn_decl(mut node)
		}
		ast.Comment {}
	}
}

fn (mut c Checker) type_is_valid(typ table.Type) bool {
	if typ == 0 {
		return false
	}

	if c.table.types[typ.idx()].kind == .placeholder {
		return false
	}

	return true
}

fn (mut c Checker) get_type_name(typ table.Type) string {
	assert typ != 0

	return c.table.types[typ.idx()].name
}

fn (mut c Checker) fn_decl(mut node ast.FnDecl) {
	c.cur_fn = node
	c.fn_scope = node.scope

	for param in node.params {
		if c.type_is_valid(param.typ) {
			c.fn_scope.register(ast.ScopeVar{
				name: param.name
				typ: param.typ
				is_used: false
			})
		}
		else {
			type_name := c.get_type_name(param.typ)
			c.error("invalid param type `$type_name`", node.pos)
		}
	}
	
	if token.Kind.key_global !in node.flags {
		self_typ := c.table.find_type_idx(c.mod)
		assert self_typ != 0

		c.fn_scope.register(ast.ScopeVar{
			name: "self"
			typ: self_typ
		})
	}

	c.stmts(node.stmts)
}

fn (mut c Checker) stmts(stmts []ast.Stmt) {

	for stmt in stmts {
		c.stmt(stmt)
	}
}

fn (mut c Checker) stmt(node ast.Stmt) {
	match mut node {
		ast.Return {
			typ := c.expr(node.expr)
			
			if c.valid_type(typ, c.cur_fn.return_type) {

			}
			else if c.can_cast(typ, c.cur_fn.return_type) {
				new_expr := ast.CastExpr {
					expr: node.expr
					pos: node.expr.pos
					type_name: c.get_type_name(c.cur_fn.return_type)
					typ: c.cur_fn.return_type
				}
				
				node.expr = new_expr
			}
			else {
				type_name := c.get_type_name(typ)
				fn_type_name := c.get_type_name(c.cur_fn.return_type)
				c.error("expected to return a value with type `$fn_type_name` not `$type_name`", node.pos)
			}
		}
		ast.If {
			for branch in node.branches {
				c.expr(branch.cond)
			
				if branch.cond is ast.EmptyExpr {
					c.error("invalid condition in if statement",  node.pos)
				}
				
				for b_stmt in branch.stmts {
					c.stmt(b_stmt)
				}
			}
		}
		ast.While {
			c.expr(node.cond)

			if node.cond is ast.EmptyExpr {
				c.error("invalid condition in while statement",  node.pos)
			}

			for w_stmt in node.stmts {
				c.stmt(w_stmt)
			}
		}
		ast.ExprStmt {
			c.expr(node.expr)
		}
		ast.AssignStmt {
			if !node.op.is_assign() {
				c.error("invalid assign operator: `$node.op`",  node.pos)
			}

			if node.left is ast.Ident || node.left is ast.IndexExpr {
				left_type := c.expr(node.left)
				mut right_type := c.expr(node.right)

				if node.right is ast.EmptyExpr {
					c.error("invalid right exression in assignment",  node.pos)
				}

				node.typ = left_type

				if left_type == right_type {}
				else if c.can_cast(right_type, left_type) {
					node.right = c.cast_to_type(node.right, right_type, left_type)
					right_type = left_type
				}
				else {
					ltype_name := c.get_type_name(left_type)
					rtype_name := c.get_type_name(right_type)
					c.error("value with type `$rtype_name` cannot be assigned to a variable with type `$ltype_name`",  node.pos)
				}

				if node.op != .assign {
					new_node := ast.InfixExpr{
						left: node.left
						left_type: left_type
						
						right: node.right
						right_type: left_type
						
						result_type: left_type
						pos: node.pos
						op: match node.op {
							.plus_assign { token.Kind.plus }
							.minus_assign { token.Kind.minus }
							.div_assign { token.Kind.div }
							.mult_assign { token.Kind.mul }
							.mod_assign { token.Kind.mod }
							else { token.Kind.plus }
						}
					}
					
					node.op = token.Kind.assign
					node.right = new_node
				}
			}
			else {
				c.error('left-side expression can only be an identificator(`varName1`) or index expression(`arr[1]`).', node.pos)
			}
		}
		ast.VarDecl {
			if c.type_is_valid(node.typ) {
				c.fn_scope.register(ast.ScopeVar{
					name: node.name
					typ: node.typ
					pos: node.pos
					is_used: false
				})
				
				if node.assign.right !is ast.NoneLiteral {
					c.stmt(node.assign)
				}
			}
			else {
				c.error("nvalid type in variable declaration", node.pos)
			}
		}
		ast.Comment {}
	}
}

//может ли тип t2 иметь значение с типом t1
pub fn (mut c Checker) valid_type(t1 table.Type, t2 table.Type) bool {
	if t1 == t2 {
		return true
	}

	s1 := c.table.get_type_symbol(t1)
	s2 := c.table.get_type_symbol(t2)

	if s1 == 0 || s2 == 0 {
		return false
	}
	
	match s2.kind {
		.script {
			if s1.kind == .none_ {
				return true
			}
		}
		else{}
	}

	return false
}

//можно ли кастануть тип t1 к типу t2
pub fn (mut c Checker) can_cast(t1 table.Type, t2 table.Type) bool {
	s1 := c.table.get_type_symbol(t1)
	s2 := c.table.get_type_symbol(t2)

	if s1 == 0 || s2 == 0 {
		return false
	}

	match s1.kind {
		.placeholder { panic("wtf") }
		.none_ {
			match s2.kind {
				.array,
				.script,
				.string,
				.bool { return true }
				else { return false }
			}
			return false
		}
		.int {
			match s2.kind {
				.float,
				.string,
				.bool { return true }
				else { return false}
			}
		}
		.float {
			match s2.kind {
				.int,
				.string,
				.bool { return true }
				else { return false}
			}
		}
		.string {
			match s2.kind {
				.int,
				.float,
				.bool { return true }
				else { return false}
			}
		}
		.bool {
			return true
		}
		.array {
			match s2.kind {
				.string,
				.bool { return true }
				else { return false}
			}
		}
		.script {
			match s2.kind {
				.string,
				.bool,
				.script { return true }
				else { return false}
			}
		}
	}

	return false
}

pub fn (mut c Checker) cast_to_type(node ast.Expr, from_type table.Type, to_type table.Type) &ast.Expr {
	if !c.can_cast(from_type, to_type) {
		type_name := c.get_type_name(from_type)
		to_type_name := c.get_type_name(to_type)
		c.error("cannot convert type `$type_name` to type `$to_type_name`",  node.pos)
	}

	new_node := ast.CastExpr {
		expr: node
		pos: node.pos
		type_name: c.get_type_name(to_type)
		typ: to_type
	}

	return &new_node
}

pub fn (mut c Checker) valid_infix_op_type(op token.Kind, typ table.Type) bool {
	match op {
		.plus {
			match typ {
				table.string_type,
				table.float_type,
				table.int_type {
					return true
				}
				else {
					return false
				}
			}
		}
		.minus, .mul, .div, .gt, .lt, .ge, .le {
			match typ {
				table.float_type,
				table.int_type {
					return true
				}
				else {
					return false
				}
			}
		}
		.mod {
			if typ == table.int_type {
				return true
			}
			else {
				return false
			}
		}
		.and, .logical_or, .eq, .ne {
			return true
		}
		else { panic("wtf") }
	}

	return false
}

pub fn (mut c Checker) expr_infix(mut node &ast.InfixExpr) table.Type {
	if !node.op.is_infix() {
		c.error("invalid infix operator: `$node.op`",  node.pos)
	}

	node.left_type = c.expr(node.left)
	node.right_type = c.expr(node.right)

	if node.right is ast.EmptyExpr {
		c.error("invalid right operand in infix expression(`$node.op`)",  node.pos)
	}

	match node.op {
		.plus {
			if node.left_type == node.right_type {
				//check int, float, string
				if node.left_type != table.int_type && node.left_type != table.float_type && node.left_type != table.string_type {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
				node.result_type = node.left_type
			}
			else if node.left_type == table.string_type || node.right_type == table.string_type {
				node.result_type = table.string_type

				if node.left_type == table.string_type {
					node.right = c.cast_to_type(node.right, node.right_type, table.string_type)
					node.right_type = table.string_type
				}
				else if node.right_type == table.string_type {
					node.left = c.cast_to_type(node.left, node.left_type, table.string_type)
					node.left_type = table.string_type
				}
			}
			else if node.left_type == table.float_type || node.right_type == table.float_type {
				node.result_type = table.float_type

				if node.left_type == table.float_type {
					node.right = c.cast_to_type(node.right, node.right_type, table.float_type)
					node.right_type = table.float_type
				}
				else if node.right_type == table.float_type {
					node.left = c.cast_to_type(node.left, node.left_type, table.float_type)
					node.left_type = table.float_type
				}
			}
			else {
				node.result_type = table.int_type

				if node.left_type == table.int_type {
					node.right = c.cast_to_type(node.right, node.right_type, table.int_type)
					node.right_type = table.int_type
				}
				else if node.right_type == table.int_type {
					node.left = c.cast_to_type(node.left, node.left_type, table.int_type)
					node.left_type = table.int_type
				}
				else {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
			}
		}
		.minus, .mul, .div {
			if node.left_type == node.right_type {
				//check left int, float
				if node.left_type != table.int_type && node.left_type != table.float_type {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
				node.result_type = node.left_type
			}
			else if node.left_type == table.float_type || node.right_type == table.float_type {
				node.result_type = table.float_type

				if node.left_type == table.float_type {
					node.right = c.cast_to_type(node.right, node.right_type, table.float_type)
					node.right_type = table.float_type
				}
				else if node.right_type == table.float_type {
					node.left = c.cast_to_type(node.left, node.left_type, table.float_type)
					node.left_type = table.float_type
				}
			}
			else {
				node.result_type = table.int_type

				if node.left_type == table.int_type {
					node.right = c.cast_to_type(node.right, node.right_type, table.int_type)
					node.right_type = table.int_type
				}
				else if node.right_type == table.int_type {
					node.left = c.cast_to_type(node.left, node.left_type, table.int_type)
					node.left_type = table.int_type
				}
				else {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
			}
		}
		.gt, .lt, .ge, .le {
			node.result_type = table.bool_type

			if node.left_type == node.right_type {
				//check left int, float
				if node.left_type != table.int_type && node.left_type != table.float_type {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
			}
			else if node.left_type == table.float_type || node.right_type == table.float_type {
				if node.left_type == table.float_type {
					node.right = c.cast_to_type(node.right, node.right_type, table.float_type)
					node.right_type = table.float_type
				}
				else if node.right_type == table.float_type {
					node.left = c.cast_to_type(node.left, node.left_type, table.float_type)
					node.left_type = table.float_type
				}
			}
			else {
				if node.left_type == table.int_type {
					node.right = c.cast_to_type(node.right, node.right_type, table.int_type)
					node.right_type = table.int_type
				}
				else if node.right_type == table.int_type {
					node.left = c.cast_to_type(node.left, node.left_type, table.int_type)
					node.left_type = table.int_type
				}
				else {
					type_name := c.get_type_name(node.left_type)
					c.error("infix operator `$node.op` not support type `$type_name`",  node.pos)
				}
			}
		}
		.mod {
			node.result_type = table.int_type

			if node.left_type == table.int_type && node.right_type == table.int_type  {

			}
			else if node.left_type == table.int_type {
				node.right = c.cast_to_type(node.right, node.right_type, table.int_type)
				node.right_type = table.int_type
			}
			else if node.right_type == table.int_type {
				node.left = c.cast_to_type(node.left, node.left_type, table.int_type)
				node.left_type = table.int_type
			}
			else {
				ltype_name := c.get_type_name(node.left_type)
				rtype_name := c.get_type_name(node.right_type)
				c.error("infix operator `$node.op` not support type `$ltype_name`, `$rtype_name`",  node.pos)
			}
		}
		.eq, .ne {
			node.result_type = table.bool_type

			if node.left_type == node.right_type {}
			else {
				ls := c.table.get_type_symbol(node.left_type)
				rs := c.table.get_type_symbol(node.right_type)
				
				if ls.kind == .script || rs.kind == .script {
					if ls.kind == .script {
						node.right = c.cast_to_type(node.right, node.right_type, node.left_type)
						node.right_type = node.left_type
					}
					else if rs.kind == .script {
						node.left = c.cast_to_type(node.left, node.left_type, node.right_type)
						node.left_type = node.right_type
					}
				}
				else if ls.kind == .array || rs.kind == .array {
					if ls.kind == .array {
						node.right = c.cast_to_type(node.right, node.right_type, node.left_type)
						node.right_type = node.left_type
					}
					else if rs.kind == .array {
						node.left = c.cast_to_type(node.left, node.left_type, node.right_type)
						node.left_type = node.right_type
					}
				}
				else {
					ltype_name := c.get_type_name(node.left_type)
					rtype_name := c.get_type_name(node.right_type)
					c.error("you can't compare type `$ltype_name` with type `$rtype_name`",  node.pos)
				}
			}
		}
		.and, .logical_or {
			if node.left_type != table.bool_type {
				node.left = c.cast_to_type(node.left, node.left_type, table.bool_type)
				node.left_type = table.bool_type
			}
			
			if node.right_type != table.bool_type {
				node.right = c.cast_to_type(node.right, node.right_type, table.bool_type)
				node.right_type = table.bool_type
			}

			node.result_type = table.bool_type
		}
		else {
			panic("wtf ($node.op)")
		}
	}

	return node.result_type
}

pub fn (mut c Checker) expr(node ast.Expr) table.Type {
	
	match mut node {
		ast.InfixExpr {
			return c.expr_infix(mut node)
		}
		ast.PrefixExpr {
			if !node.op.is_prefix() {
				c.error("invalid prefix operator: `$node.op`",  node.pos)
			}

			node.right_type = c.expr(node.right)

			if node.right is ast.EmptyExpr {
				c.error("invalid right operand in prefix expression(`$node.op`)",  node.pos)
			}

			match node.op {
				.not {
					if node.right_type == table.bool_type {

					}
					else if c.can_cast(node.right_type, table.bool_type) {
						new_expr := ast.CastExpr {
							expr: node.right
							pos: node.pos
							type_name: c.get_type_name(table.bool_type)
							typ: table.bool_type
						}

						node.right_type = table.bool_type
						node.right = new_expr
					}
					else {
						type_name := c.get_type_name(node.right_type)
						c.error("prefix operator: `!` not support type: `$type_name`",  node.pos)
					}
				}
				.minus {
					if node.right_type != table.int_type && node.right_type != table.float_type {
						type_name := c.get_type_name(node.right_type)
						c.error("prefix operator: `-` not support type: `$type_name`",  node.pos)
					}
				}
				.plus { panic("wtf") }
				else { panic("wtf") }
			}

			return node.right_type
		}
		ast.ParExpr {
			if node.expr is ast.EmptyExpr {
				c.error("invalid expression",  node.pos)
			}

			return c.expr(node.expr)
		}
		ast.NoneLiteral {
			return table.none_type
		}
		ast.IntegerLiteral { 
			return table.int_type
		}
		ast.FloatLiteral { 
			return table.float_type
		}
		ast.BoolLiteral { 
			return table.bool_type
		}
		ast.StringLiteral {
			return table.string_type
		}
		ast.Ident {
			if obj := c.fn_scope.find_var(node.name) {
				if node.pos.pos >= obj.pos.pos {
					node.typ = obj.typ
					return obj.typ
				}
			}
			else {
				c.error("variable declaration not found: `$node.name`",  node.pos)
				return table.none_type
			}
		}
		ast.CallExpr {
			return c.call_expr(mut node)
		}
		ast.ArrayInit {
			return node.typ
		}
		ast.IndexExpr {
			index_type := c.expr(node.index)

			if index_type != table.int_type {
				c.error("index can only be a number",  node.pos)
			}

			if node.left is ast.Ident {
				if obj := c.fn_scope.find_var(node.left.name) {
					if node.pos.pos > obj.pos.pos + obj.pos.len {
						node.typ = obj.typ

						sym := c.table.get_type_symbol(node.typ)
						
						//println(sym)
						if sym == 0 || sym.kind != .array || sym.info !is table.Array {
							c.error("invalid type in index expression",  node.pos)
						}
						else {
							info := c.table.get_type_symbol(node.typ).info as table.Array
							node.typ = info.elem_type
							return info.elem_type
						}
					}
				}
				else {
					c.error("array declaration not found: `$node.left.name`",  node.pos)
				}
			}
			else {
				c.error("left-side expression in index expression is not indifier",  node.pos)
			}
		}
		ast.SelectorExpr {
			node.typ = c.expr(node.expr)

			if node.field_name.to_lower() == "length" {
				sym := c.table.get_type_symbol(node.typ)

				if sym == 0 || sym.kind != .array {
					c.error("`.Length` property is only available for arrays",  node.pos)
				}

				node.typ = table.int_type
				return table.int_type
			}
			else {
				c.error("only `.Length` property is available",  node.pos)
				return table.none_type
			}
			
			return node.typ
		}
		ast.CastExpr {
			expr_type := c.expr(node.expr)

			idx := c.table.find_type_idx(node.type_name)
			if idx > 0 {
				node.typ = idx
				return idx
			}
			
			if !c.can_cast(expr_type, node.typ) {
				expr_type_name := c.get_type_name(expr_type)
				type_name := c.get_type_name(node.typ)
				c.error("cannot convert type `$expr_type_name` to type `$type_name`",  node.pos)
			}
		}
		ast.EmptyExpr {
			return table.none_type
		}
		ast.DefaultValue{
			panic("===checker.v WARNING expr()===")
		}
	}

	eprintln(node)
	panic("expression not processed in file: `$c.file.path`")
}

pub fn (mut c Checker) find_fn(typ table.Type, mod string, name string) ?table.Fn {
	if typ > 0 {
		mut sym := c.table.get_type_symbol(typ)

		if sym.kind == .array && name.to_lower() == "find" {
			elem_type := (sym.info as table.Array).elem_type
			return table.Fn{
				params: [
					{
						name: "value"
						typ: elem_type
						is_optional: false
						default_value: ""
					},
					{
						name: "startIndex"
						typ: table.int_type
						is_optional: true
						default_value: "0"
					}
				]
				return_type: elem_type
				mod: 'builtin'
				name: name
				sname: name.to_lower()
				is_static: false
			}
		}

		for sym != 0 {
			if func := sym.find_method(name) {
				return func
			}
			
			if sym.parent_idx == 0 {
				break
			}

			sym = c.table.get_type_symbol(sym.parent_idx)
		}
	}

	if c.table.has_module(mod) {
		if func := c.table.find_fn(mod, name) {
			return func
		}
	}

	return none
}

pub fn (mut c Checker) call_expr(mut node &ast.CallExpr) table.Type {
	mut left := c.mod
	mut name := node.name
	mut typ := 0

	if node.left is ast.EmptyExpr {
		left = c.mod
	}
	else if node.left is ast.Ident && c.table.has_module((node.left as ast.Ident).name) {
		left = (node.left as ast.Ident).name
		typ = (node.left as ast.Ident).typ
	}
	else {
		if node.left is ast.Ident {
			left = (node.left as ast.Ident).name
		}
		typ = c.expr(node.left)
	}

	if left == "" {
		panic("wtf")
	}

	mut type_name := "unknown type"
	if typ > 0 {
		type_name = c.get_type_name(typ)
	}

	if func := c.find_fn(typ, left, name) {
		node.mod = func.mod
		node.return_type = func.return_type
		node.is_static = func.is_static

		if node.args.len > func.params.len {
			c.error("function takes $func.params.len parameters not $node.args.len", node.pos)
			return table.none_type
		}

		//добавляем параметры по умолчанию
		if node.args.len < func.params.len {
			mut i := node.args.len
			for i < func.params.len {
				if func.params[i].is_optional {
					func_arg_def_value := func.params[i].default_value
					match func.params[i].typ {
						table.int_type {
							node.args << ast.CallArg {
								expr: ast.IntegerLiteral{ val: func_arg_def_value }
								typ: table.int_type 
							}
						}
						table.float_type {
							node.args << ast.CallArg {
								expr: ast.FloatLiteral{ val: func_arg_def_value }
								typ: table.float_type 
							}
						}
						table.string_type {
							node.args << ast.CallArg {
								expr: ast.StringLiteral{ val: func_arg_def_value }
								typ: table.string_type 
							}
						}
						table.bool_type {
							node.args << ast.CallArg {
								expr: ast.BoolLiteral{ val: func_arg_def_value }
								typ: table.bool_type
							}
						}
						table.none_type {
							node.args << ast.CallArg {
								expr: ast.NoneLiteral{ val: "None" }
								typ: table.none_type
							}
						}
						else {
							node.args << ast.CallArg {
								expr: ast.NoneLiteral{ val: "None" }
								typ: func.params[i].typ
							}
						}
					}
				}
				else {
					break
				}

				i++
			}
		}

		if node.args.len != func.params.len {
			c.error("function takes $func.params.len parameters not $node.args.len", node.pos)
			return table.none_type
		}

		mut i := 0
		for i < node.args.len {
			arg_typ := c.expr(node.args[i].expr)
			node.args[i].typ = arg_typ
			func_arg_type := func.params[i].typ
			
			if arg_typ == func_arg_type || (func.params[i].is_optional && c.valid_type(arg_typ, func_arg_type)) {

			}
			else if c.can_cast(arg_typ, func_arg_type) {
				new_expr := ast.CastExpr {
					expr: node.args[i].expr
					pos: node.args[i].pos
					type_name: c.get_type_name(func_arg_type)
					typ: func_arg_type
				}
				
				node.args[i].expr = new_expr
			}
			else {
				left_type_name := c.get_type_name(func_arg_type)
				right_type_name := c.get_type_name(arg_typ)
				c.error("cannot convert type `$right_type_name` to type `$left_type_name`", node.pos)
			}

			i++
		}

		return node.return_type
	}
	else {
		c.error("undefined function: " + left + "." + name,  node.pos)
	}

	return table.none_type
}

pub fn (mut c Checker) warn(message string, pos token.Position) {
	eprintln("Checker warning: " + message)
}

pub fn (mut c Checker) error(message string, pos token.Position) {
	ferror := util.formatted_error('Checker error:', message, c.file.path, pos)
	eprintln(ferror)
	c.errors << errors.Error {
		message: message
		details: message
		file_path: c.file.path
		pos: pos
		backtrace: ""
		reporter:  errors.Reporter.checker
	}	
}