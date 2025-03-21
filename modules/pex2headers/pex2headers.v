module pex2headers

import pex
import strings
import os

struct Gen {
	pex_file	&pex.PexFile
mut:
	b			strings.Builder
	in_state	bool
}

@[inline]
fn (mut g Gen) next_line() {
	g.b.write_string("\n")
}

@[inline]
fn (mut g Gen) write(str string) {
	g.b.write_string(str)
}

@[inline]
fn (mut g Gen) get_string(id pex.StringId) string {
	return g.pex_file.get_string(id)
}

pub fn gen(pex_file &pex.PexFile, output_dir string) {
	mut g := Gen{
		pex_file: pex_file
		b: strings.new_builder(500)
	}

	assert g.pex_file.objects.len == 1

	name := g.pex_file.get_string(g.pex_file.objects[0].name)
	g.gen_object(g.pex_file.objects[0])

	os.write_file(os.join_path(output_dir, name + ".psc"), g.b.str()) or { panic(err) }
}

@[inline]
fn (mut g Gen) gen_object(obj &pex.Object) {
	obj_name := g.pex_file.get_string(obj.name)
	
	//Scriptname Actor extends ObjectReference Hidden
	g.write("Scriptname ")
	g.write(obj_name)

	if g.pex_file.has_parent() {
		parent_name := g.pex_file.get_string(obj.parent_class_name)
		g.write(" extends ")
		g.write(parent_name)
	}

	if obj.is_hidden() {
		g.write(" Hidden")
	}

	if obj.is_conditional() {
		g.write(" Conditional")
	}
	
	g.next_line()
	g.next_line()

	for var in obj.variables {
		var_name := g.get_string(var.name)
		
		if var_name.starts_with("::") {
			continue
		}


		g.write(g.get_string(var.type_name))
		g.write(" ")
		g.write(var_name)
		g.write(" = ")

		mut data_str := ""
		match var.data.typ {
			.null {
				data_str = "None"
			}
			.identifier {
				str_id := unsafe { var.data.data.string_id }
				data_str = g.get_string(str_id)
			}
			.str {
				str_id := unsafe { var.data.data.string_id }
				str := g.get_string(str_id)
				data_str = "\"${str}\""
			}
			.integer {
				data_str = unsafe { var.data.data.integer }.str()
			}
			.float {
				data_str = unsafe { var.data.data.float }.str()
			}
			.boolean {
				data_str = unsafe { var.data.data.boolean }.str()
			}
		}

		g.write(data_str)
		g.next_line()
	}

	g.next_line()

	for prop in obj.properties {
		//string Property Hello3 = "Hello world3!" Auto
		g.write(g.get_string(prop.typ))
		g.write(" Property ")
		g.write(g.get_string(prop.name))
		g.next_line()

		if prop.is_autovar() {
			if prop.is_read() && !prop.is_write() {
				g.write(" AutoReadOnly")
			}
			else {
				g.write(" Auto")
			}

			g.next_line()
		}
		else {
			if prop.is_read() && !prop.is_write() {
				g.write("\t${g.get_string(prop.typ)} Function Get()")
				g.next_line()
				g.write("\t\treturn 123")
				g.next_line()
				g.write("\tEndFunction")
				g.next_line()
			}
			else {
				g.write("\t${g.get_string(prop.typ)} Function Get()")
				g.next_line()
				g.write("\t\treturn 123")
				g.next_line()
				g.write("\tEndFunction")
				g.next_line()
				g.write("\tFunction Set(${g.get_string(prop.typ)} value)")
				g.next_line()
				g.write("\tEndFunction")
				g.next_line()
			}
		}

		g.write("EndProperty")
		g.next_line()
	}
	
	g.next_line()

	auto_state_name := g.get_string(obj.auto_state_name)

	for state in obj.states {
		state_name := g.get_string(state.name)
		if state_name != auto_state_name {
			g.next_line()
			g.write("State ")
			g.write(state_name)
			g.next_line()
			g.in_state = true
		}

		for func in state.functions {
			g.gen_function(func)
		}

		if state_name != auto_state_name {
			g.write("EndState")
			g.in_state = false
			g.next_line()
		}
	}
}

@[inline]
fn (mut g Gen) get_default_value_type(typ string) string {
	if typ.ends_with() {

	}
	
	match typ.to_lower() {
		"none" { return "None" }
		"string" { return "\"\"" }
		"int" { return "0" }
		"float" { return "0.0" }
		"bool" { return "False" }
	}
}

@[inline]
fn (mut g Gen) gen_function(func &pex.Function) {
	name := g.get_string(func.name)

	if name in state_fns {
		return
	}

	if g.in_state {
		g.write("\t")
	}
	
	g.write("Function ")
	g.write(name)
	g.write("(")

	for i in 0..func.info.params.len {
		arg := func.info.params[i]

		g.write(g.get_string(arg.typ))
		g.write(" ")
		g.write(g.get_string(arg.name))

		if i < func.info.params.len - 1 {
			g.write(", ")
		}
	}

	g.write(")")

	if func.info.is_global() {
		g.write(" Global")
	}
	
	g.write(" Native")

	g.next_line()
}

const state_fns = ["GetState", "GotoState", "onEndState", "onBeginState"]