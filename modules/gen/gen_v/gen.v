module gen_v

import strings

import papyrus.ast
import pex
import pref

struct Gen {
	pref			&pref.Preferences
pub mut:
	file			&ast.File = unsafe{ voidptr(0) }

	table			&ast.Table
	
	//cur_obj		&pex.Object = unsafe{ voidptr(0) }
	//cur_state		&pex.State = unsafe{ voidptr(0) }
	//cur_fn		&pex.Function = unsafe{ voidptr(0) }

	//empty_state	&pex.State = unsafe{ voidptr(0) }

	cur_fn			&ast.FnDecl = voidptr(0)
	cur_obj_type	ast.Type
	cur_obj_name	string

	out				strings.Builder
	indent_size		int

	funcs			map[string]map[string]&ast.FnDecl // map[<fnName>][<stateName>]
	variables		map[string]&ast.VarDecl // map[<name>]
	properties		map[string]&ast.PropertyDecl // map[<name>]

	interface_mode	bool = true
}
pub fn gen_v_file(mut file ast.File, mut table ast.Table, prefs &pref.Preferences) string {
	mut g := Gen{
		file: file
		table: table
		pref: prefs
		out: strings.new_builder(10 * 1000)
	}
	
	println("=======================================================")
	println("=======================================================")
	println("=======================================================")
	println("=======================================================")
	
	for mut stmt in g.file.stmts {
		match mut stmt {
			ast.ScriptDecl {
				g.cur_obj_type = g.table.find_type_idx(stmt.name)
				assert g.cur_obj_type != 0
				g.cur_obj_name = stmt.name
			}
			ast.StateDecl {
				println("TODO gen state")
			}
			ast.FnDecl {
				g.funcs[stmt.name][pex.empty_state_name] = &stmt
			}
			ast.VarDecl {
				g.variables[stmt.name] = &stmt
			}
			ast.PropertyDecl {
				g.properties[stmt.name] = &stmt
			}
			ast.Comment {
				//skip
			}
		}
	}

	g.writeln("[translated]")
	g.writeln("module papyrus")
	g.writeln("")

	/*if g.pref.backend == .v_vm_wrapper {
		g.gen_object_interface()
	}
	else {*/
		g.gen_object_struct()
		g.gen_funcs()
	//}
	
	return g.out.str()
}

fn (mut g Gen) gen_object_struct() {
	g.writeln("pub struct ${g.cur_obj_name} {")
	
	sym := g.table.get_type_symbol(g.cur_obj_type)
	

	if sym.parent_idx != 0 {
		g.indent_size++
		parent_sym := g.table.get_type_symbol(sym.parent_idx)

		g.writeln(parent_sym.name)
		g.indent_size--
	}

	g.writeln("mut:")
	g.indent_size++
	g.writeln("desc\t&ObjectDesc")
	g.indent_size--

	
	if g.variables.len > 0 {
		g.writeln("// variables")
		//g.writeln("mut:")

		g.indent_size++

		for _, var in g.variables {
			assert var.is_object_var
			var_name := g.get_object_var_prop_name(var.name)
			type_name := g.get_type_name(var.typ)
			g.write_tab("${var_name}\t${type_name}")
			
			if var.assign.right !is ast.EmptyExpr  {
				if !var.assign.right.is_literal() {
					eprintln(var)
					panic("wtf")
				}

				g.write(" = ")
				g.gen_expr(var.assign.right)
			}

			g.writeln("")
		}

		g.indent_size--
	}

	if g.properties.len > 0 {
		mut prop_is_exist := false
		for _, prop in g.properties {
			type_name := g.get_type_name(prop.typ)
			prop_name := g.get_object_var_prop_name(prop.name)

			if prop.is_auto {
				if !prop_is_exist {
					prop_is_exist = true
					g.writeln("// auto properties")
					g.writeln("pub mut:")
					g.indent_size++
				}
				
				g.writeln("${prop_name}\t${type_name}")
			}
		}

		if prop_is_exist {
			g.indent_size--
		}

		prop_is_exist = false
		for _, prop in g.properties {
			type_name := g.get_type_name(prop.typ)
			prop_name := g.get_object_var_prop_name(prop.name)

			if prop.is_autoread {
				if !prop_is_exist {
					prop_is_exist = true
					g.writeln("")
					g.writeln("// autoread properties")
					g.writeln("pub:")
					g.indent_size++
				}

				g.writeln("${prop_name}\t${type_name}")
			}
		}

		if prop_is_exist {
			g.indent_size--
		}
	}

	g.writeln("}")
}

fn (mut g Gen) gen_funcs() {
	for _, mut prop in g.properties {
		prop_name := g.get_object_var_prop_name(prop.name)

		if !prop.is_auto && !prop.is_autoread {
			g.writeln("")

			if mut prop.read is ast.FnDecl {
				g.cur_fn = &prop.read
				prop.read.name = g.get_method_name("set_" + prop_name)
				g.gen_method(prop.read)
				g.cur_fn = voidptr(0)
			}

			if mut prop.write is ast.FnDecl {
				g.cur_fn = &prop.write
				prop.write.name = g.get_method_name("get_" + prop_name)
				g.gen_method(prop.write)
				g.cur_fn = voidptr(0)
			}
		}
	}

	for _, map_func in g.funcs {
		func := map_func[pex.empty_state_name] or { panic("wtf") }
		g.cur_fn = func

		g.writeln("")
		if func.is_native {
			g.writeln("/* <native func ${g.cur_obj_name}.${func.name}> */")
		}
		else if func.is_global {
			g.gen_global_fn(func)
		}
		else {
			g.gen_method(func)
		}

		
		g.cur_fn = voidptr(0)
	}
}

[inline]
fn (mut g Gen) write(str string) {
	g.out.write_string(str)
}

[inline]
fn (mut g Gen) write_tab(str string) {
	if g.indent_size > 0 {
		g.write(strings.repeat(`\t`, g.indent_size))
	}

	g.out.write_string(str)
}

[inline]
fn (mut g Gen) writeln(str string) {
	if g.indent_size > 0 {
		g.write(strings.repeat(`\t`, g.indent_size))
	}

	g.out.writeln(str)
}

[inline]
fn (mut g Gen) write_startln() {
	if g.indent_size > 0 {
		g.write(strings.repeat(`\t`, g.indent_size))
	}
}

[inline]
fn (mut g Gen) write_endln() {
	g.write("\n")
}

[inline]
fn (g Gen) get_object_var_prop_name(name string) string {
	//return to_snake_case(name)
	return name.camel_to_snake()
}

[inline]
fn (g Gen) get_global_fn_name(obj_name string, name string) string {
	//return "${to_snake_case(obj_name)}_${to_snake_case(name)}"
	return obj_name.camel_to_snake() + "_" + name.camel_to_snake()
}

[inline]
fn (g Gen) get_method_name(name string) string {
	//return to_snake_case(name)
	return name.camel_to_snake()
}

[inline]
fn (g Gen) get_object_type_name(name string) string {
	return "&" + name
}
/*
[inline]
fn to_snake_case(camel string) string {
    mut b := strings.new_builder(30)
    diff := 'a'[0] - 'A'[0]
    len := camel.len

    for i, v in camel {
        // A is 65, a is 97
        if v < "A"[0] || v > "Z"[0]/*v >= 'a'[0]*/ {
            b.write_u8(v)
            continue
        }
        // v is capital letter here
        // irregard first letter
        // add underscore if last letter is capital letter
        // add underscore when previous letter is lowercase
        // add underscore when next letter is lowercase
        if (i != 0 || i == len - 1) && ( // head and tail
            (i > 0 && camel[i - 1] >= 'a'[0]) || // pre
                (i < len - 1 && camel[i + 1] >= 'a'[0])) { //next
            b.write_string('_')
        }
		
        b.write_u8(v + diff)
    }

    return b.str()
}
*/
[inline]
fn (g Gen) get_type_name(typ ast.Type) string {
	sym := g.table.get_type_symbol(typ)
	
	match sym.kind {
		.placeholder { panic("Gen.get_type_name invalid type") }
		.none_ { return "none" }
		.int { return "int" }
		.float { return "f32" }
		.string { return "string" }
		.bool { return "bool" }
		.array {
			elem_type := (sym.info as ast.Array).elem_type
			return "[]${g.get_type_name(elem_type)}"
		}
		.script {
			return g.get_object_type_name(sym.name)
		}
	}
}