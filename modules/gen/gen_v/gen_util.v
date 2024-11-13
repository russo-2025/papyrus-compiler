module gen_v

import strings

import papyrus.ast
import pref

pub fn gen_util(mut table ast.Table, prefs &pref.Preferences) string {
	mut g := Gen{
		table: table
		pref: prefs
		out: strings.new_builder(1 * 1000)
	}
	
	g.writeln("[translated]")
	g.writeln("module papyrus")
	g.writeln("")

	/*if g.pref.backend == .v_vm_wrapper {
		g.gen_wrapper_util()
	}
	else {*/
		g.gen_util_cast_object_desc()
		g.writeln("")
		g.gen_util_cast_object()
		g.writeln("")
		g.gen_util_call_vm_static_func()
		g.writeln("")
	//}

	return g.out.str()
}

	/*
	for sym in table.types {

	}

	for func in table.fns {

	}
	*/


fn (mut g Gen) gen_util_cast_object_desc() {
	g.writeln("[inline]")
	g.writeln("pub fn cast_object_desc[H](desc &ObjectDesc) ?H {")
	g.indent_size++
	
	for sym_idx in 0..g.table.types.len {
		sym := g.table.types[sym_idx]

		if sym.parent_idx == 0 || sym.kind != .script {
			continue
		}

		to_type_name := g.get_object_type_name(sym.name)

		g.writeln("\$if H is ${g.get_object_type_name(sym.name)} {")
		g.indent_size++
		
		g.writeln("if desc.typ == ${sym_idx} { // desc == ${sym.name}")
		g.writeln("\treturn ${to_type_name}(desc.ptr)")
		g.writeln("}")

		for child_idx in 0..g.table.types.len {
			child := g.table.types[child_idx]
			from_type_name := g.get_object_type_name(child.name)

			if child.kind != .script || child.parent_idx != sym_idx {
				continue
			}

			g.writeln("else if desc.typ == ${child_idx} { // desc == ${child.name}")
			g.writeln("\treturn cast_object[${from_type_name}, ${to_type_name}](${from_type_name}(desc.ptr))")
			g.writeln("}")
		}
		
		g.writeln("return none")
		g.indent_size--
		g.writeln("}")
	}
	
	g.writeln("return none")
	g.indent_size--
	g.writeln("}")
}

// Form -> ObjectReference -> Actor
fn (mut g Gen) gen_util_cast_object() {
	g.writeln("[inline]")
	g.writeln("pub fn cast_object[T, H](value T) ?H {")
	g.indent_size++
	
	for sym in g.table.types {
		if sym.parent_idx == 0 || sym.kind != .script {
			continue
		}
		
		name := sym.name

		g.writeln("\$if T is ${g.get_object_type_name(name)} {")
		g.indent_size++

		mut parent := g.table.get_type_symbol(sym.parent_idx)
		mut cast_expr := "value"
		for {
			parent_name := parent.name
			cast_expr += "." + parent_name

			g.writeln("\$if H is ${g.get_object_type_name(parent_name)} {")
			g.indent_size++
			g.writeln("return ${cast_expr}")
			g.indent_size--
			g.writeln("}")

			if parent.parent_idx != 0 {
				parent = g.table.get_type_symbol(parent.parent_idx)
				continue
			}

			break
		}

		g.indent_size--
		g.writeln("}")
		

		g.writeln("\$if H is ${g.get_object_type_name(name)} {")
		g.indent_size++

		g.write_tab("// ")
		parent = g.table.get_type_symbol(sym.parent_idx)
		
		for {
			parent_name := parent.name
			g.write(parent_name)

			if parent.parent_idx != 0 {
				g.write(", ")
				parent = g.table.get_type_symbol(parent.parent_idx)
				continue
			}

			break
		}
		g.write(" -> ${name}")
		g.writeln("")

		g.writeln("return cast_object_desc[${g.get_object_type_name(name)}](value.desc) or { return none }")

		g.indent_size--
		g.writeln("}")
	}
	
	g.writeln("")
	g.writeln("//\$compile_error(\"invalid type in cast\")")
	g.writeln("panic(\"invalid type in cast \${T.name} -> \${H.name}\")")

	g.indent_size--
	g.writeln("}")
}

fn (mut g Gen) gen_util_call_vm_static_func() {
	g.writeln("pub fn call_vm_static_func(obj_name string, func_name string, args ...PapyrusValue) ! {")
	g.indent_size++

	g.writeln("name := obj_name.to_lower() + \".\" + func_name.to_lower()")
	g.writeln("match name {")

	g.indent_size++
	for _, func in g.table.fns {
		g.writeln("\"${func.name.to_lower()}.${func.obj_name.to_lower()}\" {")
		g.indent_size++
		g.writeln("if args.len != ${func.params.len} { return error(\"incorrect number of arguments\") }")
		g.write_tab("${g.get_global_fn_name(func.obj_name, func.name)}(")
		for i in 0..func.params.len {
			param := func.params[i] 
			param_sym := g.table.get_type_symbol(param.typ)
			
			if param_sym.kind == .script {
				type_name := g.get_object_type_name(param_sym.name)
				g.write("cast_object_desc[${type_name}](args[${i}].desc())")
				g.write(" or { return error(\"failed to convert argument with index ${i} into ${type_name} type\") }")
			}
			else if param_sym.kind == .array {

			}
			else {
				g.write("args[${i}].${g.get_type_name(param.typ)}()")
			}

			if i < func.params.len - 1 {
				g.write(", ")
			}
		}
		g.write(")")
		g.writeln("")
		g.indent_size--
		g.writeln("}")
	}
	g.writeln("else {/* Error TODO */}")
	g.indent_size--
	
	g.writeln("}")
	g.indent_size--
	g.writeln("}")
}
