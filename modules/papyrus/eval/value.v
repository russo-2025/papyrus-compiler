module eval

import pex

enum Type {
	boolean
	integer
	float
	string
	object
}

type Object = voidptr
type Value = string | i32 | f32 | bool | Object

fn default_value(typ Type) Value {
	return match typ {
		.integer {
			Value(i32(0))
		}
		.float {
			Value(f32(0.0))
		}
		.boolean {
			Value(false)
		}
		.string {
			Value("")
		}
		.object {
			Value(Object(voidptr(0))) // todo
		}

	}
}

fn get_type_from_type_name(name string) Type {
	lname := name.to_lower()
	return match lname {
		"string" { .string }
		"int" { .integer }
		"float" { .float }
		"bool" { .boolean }
		else { .object }
	}
}

struct Exec {
pub:
	pex_file &pex.PexFile
}

fn (e Exec) get_string(id pex.StringId) string {
	return e.pex_file.get_string(id)
}
 
pub fn run(pex_file &pex.PexFile, func &pex.Function) Value {
	mut exec := Exec {
		pex_file: pex_file
	}
	mut locals := map[pex.StringId]Value
	
	for local in func.info.locals {
		// init locals
		locals[local.name] = default_value(get_type_from_type_name(exec.get_string(local.typ)))
	}

	println(locals.len)
	println(locals)

	println(func.info.instructions.len)
	for inst in func.info.instructions {
		println(inst.op)
		match inst.op {
			.nop { }
			.iadd {
				assert inst.args.len == 3
				assert inst.args[0].typ == .identifier
				assert inst.args[1].typ == .integer
				assert inst.args[2].typ == .integer

				res := inst.args[1].data.integer + inst.args[2].data.integer
				locals[inst.args[0].data.string_id] = Value(i32(res))
				println("asdasd")
				println( Value(i32(res)))
				println(locals[inst.args[0].data.string_id])
			}
			.fadd {
				assert inst.args.len == 3
				assert inst.args[0].typ == .identifier
				assert inst.args[1].typ == .float
				assert inst.args[2].typ == .float

				res := inst.args[1].data.float + inst.args[2].data.float
				locals[inst.args[0].data.string_id] = Value(f32(res))
				println(locals[inst.args[0].data.string_id])
			}
			.isub {}
			.fsub {}
			.imul {}
			.fmul {}
			.idiv {}
			.fdiv {}
			.imod {}
			.not {}
			.ineg {}
			.fneg {}
			.assign {}
			.cast {}
			.cmp_eq {}
			.cmp_lt {}
			.cmp_le {}
			.cmp_gt {}
			.cmp_ge {}
			.jmp {}
			.jmpt {}
			.jmpf {}
			.callmethod {}
			.callparent {}
			.callstatic {}
			.ret {}
			.strcat {}
			.propget {}
			.propset {}
			.array_create {}
			.array_length {}
			.array_getelement {}
			.array_setelement {}
			.array_findelement {}
			.array_rfindelement {}
			._opcode_end { panic("wtf") }
		}
	}

	return Value(false)
}