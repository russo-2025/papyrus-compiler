module pex

pub const empty_state_name = ""

@[inline]
pub fn get_property_autovar_name(prop_name string) string {
	return "::" + prop_name + "_var"
}

const opcode_str = build_opcode_str()

pub enum OpCode as u8 {
	nop = 0				//none		do nothing
	iadd				//SII		add two integers
	fadd				//SFF		add two floats
	isub				//SII		subtract two integers
	fsub				//SFF		subtract two floats
	imul				//SII		multiply two integers
	fmul				//SFF		multiply two floats
	idiv				//SII		divide two integers
	fdiv				//SFF		divide two floats
	imod				//SII		remainder of two integers
	not					//SA		flip a bool, type conversion may occur?
	ineg				//SI		negate an integer
	fneg				//SF		negate a float
	assign				//SA		store a variable
	cast				//SA		type conversion?
	cmp_eq				//SAA		set a bool to true if a == b
	cmp_lt				//SAA		set a bool to true if a < b
	cmp_le				//SAA		set a bool to true if a <= b
	cmp_gt				//SAA		set a bool to true if a > b
	cmp_ge				//SAA		set a bool to true if a >= b
	jmp					//L			relative unconditional branch
	jmpt				//AL		relative conditional branch if a bool is true
	jmpf				//AL		relative conditional branch if a bool is false
	callmethod			//NSS*	
	callparent			//NS*	
	callstatic			//NNS*	
	ret					//A	
	strcat				//SQQ		concatenate two strings
	propget				//NSS		retrieve an instance property
	propset				//NSA		set an instance property
	array_create		//Su		create an array of the specified size
	array_length		//SS		get an array's length
	array_getelement	//SSI		get an element from an array
	array_setelement	//SIA		set an element to an array
	array_findelement	//SSII		find an element in an array. The 4th arg is the startIndex, default = 0
	array_rfindelement	//SSII		find an element in an array, starting from the end. The 4th arg is the startIndex, default = -1

	_opcode_end
}

// https://open-papyrus.github.io/docs/Pex_File_Format/Endianness.html
//LITTLE_ENDIAN
pub const le_magic_number = u32(0xFA57C0DE)
	
	//BIG_ENDIAN
pub const be_magic_number = u32(0xDEC057FA)

pub enum GameType as u16 {
	unknown = 0
	skyrim = 1
}

pub type StringId = u16

@[heap]
pub struct PexFile {
pub mut:
	//Header
	magic_number		u32			// 0xFA57C0DE (FASTCODE?)
	major_version		u8		// 3
	minor_version		u8		// 1 (Dawnguard, Hearthfire and Dragonborn scripts are 2)
	game_id				GameType	// 1 = Skyrim?
	compilation_time	i64
	src_file_name		string	// Name of the source file this file was compiled from (.psc extension).
	user_name			string	// Username used to compile the script
	machine_name		string	// Machine name used to compile the script

	//String Table
	string_table		[]string // StringTable to look up member names and other stuff from

	//Debug Info
	has_debug_info		u8 //Flag, if zero then no debug info is present and the rest of the record is skipped
	modification_time 	i64 // time_t
	functions			[]DebugFunction

	//Objects
	user_flags			[]UserFlag // flags from *.flg file
	objects				[]&Object
}

@[inline]
pub fn (file PexFile) user_flags_str() string {
	mut flags := []string{}

	for flag in file.user_flags {
		hex := "0x" + flag.flag_index.hex()
		str := file.get_string(flag.name)
		flags << "${str}(${hex})"
	}

	return flags.str()
}

pub struct DebugFunction {
pub mut:
	object_name					StringId
	state_name					StringId
	function_name				StringId
	function_type				u8 //valid values 0-3
	instruction_line_numbers	[]u16 //Maps instructions to their original lines in the source.
}

pub struct UserFlag {
pub mut:
	name		StringId
	flag_index	u8	//Bit index
}

pub struct Object {
pub mut:
	name				StringId
	size				u32	
	parent_class_name	StringId
	docstring			StringId
	user_flags			u32	
	auto_state_name		StringId
	variables			[]&Variable
	properties			[]&Property
	states				[]&State
}

@[inline]
pub fn (obj Object) is_hidden() bool {
	return (obj.user_flags & 0b0001) != 0
}

@[inline]
pub fn (obj Object) is_conditional() bool {
	return (obj.user_flags & 0b0010) != 0
}

@[inline]
pub fn (obj Object) user_flags_str() string {
	mut flags := []string{}

	if obj.is_hidden() {
		flags << "Hidden"
	}

	if obj.is_conditional() {
		flags << "Conditional"
	}

	return flags.str()
}

pub struct Variable {
pub mut:
	name		StringId
	type_name	StringId
	user_flags	u32	
	data		VariableValue //Default value
}

@[inline]
pub fn (v Variable) is_conditional() bool {
	return (v.user_flags & 0b0010) != 0
}

@[inline]
pub fn (v Variable) user_flags_str() string {
	mut flags := []string{}

	if v.is_conditional() {
		flags << "Conditional"
	}

	return flags.str()
}

pub enum ValueType as u8 {
	null = 0 // aka none
	identifier
	str
	integer
	float
	boolean
}

pub union ValueData {
pub mut:
	string_id	StringId
	integer		int	//present for integer types only
	float		f32	//present for float types only
	boolean		u8 //present for bool types only
}

pub struct VariableValue {
pub mut:
	typ		ValueType // 0 = null, 1 = identifier, 2 = string, 3 = integer, 4 = float, 5 = bool
	data 	ValueData
	
}

pub struct Property {
pub mut:
	name			StringId
	typ				StringId
	docstring		StringId
	user_flags		u32	
	flags			u8 //bitfield: 1(bit 1) = read, 2(bit 2) = write, 4(bit 3) = autovar. For example, Property in a source script contains only get() or is defined AutoReadOnly then the flags is 0x1, contains get() and set() then the flags is 0x3.
	auto_var_name	StringId //present if (flags & 4) != 0
	read_handler	FunctionInfo //present if (flags & 5) == 1
	write_handler	FunctionInfo //present if (flags & 6) == 2
}

@[inline]
pub fn (prop Property) is_read() bool {
	return (prop.flags & 0b0001) != 0
}

@[inline]
pub fn (prop Property) is_write() bool {
	return (prop.flags & 0b0010) != 0
}

pub fn (prop Property) is_autovar() bool {
	return (prop.flags & 0b0100) != 0
}

@[inline]
pub fn (prop Property) is_hidden() bool {
	return (prop.user_flags & 0b0001) != 0
}

@[inline]
pub fn (prop Property) user_flags_str() string {
	mut flags := []string{}

	if prop.is_hidden() {
		flags << "Hidden"
	}

	return flags.str()
}

@[inline]
pub fn (prop Property) flags_str() string {
	mut flags := []string{}

	if prop.is_read() {
		flags << "Read"
	}
	if prop.is_write() {
		flags << "Write"
	}
	if prop.is_autovar() {
		flags << "AutoVar"
	}

	return flags.str()
}

pub struct State {
pub mut:
	name			StringId	//empty string for default state
	functions		[]&Function
}

pub struct Function {
pub mut:
	name	StringId
	info	FunctionInfo
}

pub struct FunctionInfo {
pub mut:
	return_type			StringId
	docstring			StringId
	user_flags			u32	
	flags				u8 //1 bit - global, 2 bit - native
	params				[]VariableType
	locals				[]VariableType
	instructions		[]Instruction
}

@[inline]
pub fn (info FunctionInfo) is_global() bool {
	return info.flags & 0b1 != 0
}

@[inline]
pub fn (info FunctionInfo) is_native() bool {
	return info.flags & 0b10 != 0
}

@[inline]
pub fn (info FunctionInfo) user_flags_str() string {
	return "[]"
}

@[inline]
pub fn (info FunctionInfo) flags_str() string {
	mut flags := []string{}
	
	if info.is_global() {
		flags << "Global"
	}

	if info.is_native() {
		flags << "Native"
	}

	return flags.str()
}

pub struct VariableType {
pub mut:
	name	StringId
	typ		StringId
}

@[inline]
pub fn (var_type &VariableType) to_string(pex_file &PexFile) string {
	name := pex_file.get_string(var_type.name)
	type_name := pex_file.get_string(var_type.typ)

	return "${type_name} ${name}"
}

pub struct Instruction {
pub mut:
	op		OpCode 			//see Opcodes
	args	[]VariableValue	//[changes depending on opcode]	Length is dependent on opcode, also varargs
}

@[inline]
pub fn (inst &Instruction) to_string(pex_file &PexFile) string {
	mut args := ""
	
	mut i := 0
	for i < inst.args.len {
		args += inst.args[i].to_string(pex_file)
		
		if i < inst.args.len - 1 {
			args += ", "
		}

		i++
	}

	return "opcode: '${inst.op}', args: [${args}]"
}

@[inline]
pub fn value_none() VariableValue {
	return VariableValue{ typ: .null }
}

@[inline]
pub fn value_ident(v StringId) VariableValue {
	return VariableValue{
		typ: .identifier,
		data: ValueData{ string_id: v }
	}
}

@[inline]
pub fn value_string(v StringId) VariableValue {
	return VariableValue{
		typ: .str,
		data: ValueData{ string_id: v }
	}
}

@[inline]
pub fn value_integer(v int) VariableValue {
	return VariableValue{
		typ: .integer,
		data: ValueData{ integer: v }
	}
}

@[inline]
pub fn value_float(v f32) VariableValue {
	return VariableValue{
		typ: .float,
		data: ValueData{ float: v }
	}
}

@[inline]
pub fn value_bool(v u8) VariableValue {
	return VariableValue{
		typ: .boolean,
		data: ValueData{ boolean: v }
	}
}

@[inline]
pub fn (value VariableValue) to_string_id() StringId {
	assert value.typ == .identifier || value.typ == .str
	return unsafe { value.data.string_id }
}

@[inline]
pub fn (value VariableValue) to_integer() int {
	assert value.typ == .integer
	return unsafe { value.data.integer }
}

@[inline]
pub fn (value VariableValue) to_float() f32 {
	assert value.typ == .float
	return unsafe { value.data.float }
}

@[inline]
pub fn (value VariableValue) to_boolean() u8 {
	assert value.typ == .boolean
	return unsafe { value.data.boolean }
}

pub fn (value &VariableValue) to_string(pex_file &PexFile) string {
	mut result := ""

	match value.typ {
		.null {
			result = "none"
		}
		.identifier {
			result = "ident(${pex_file.get_string(value.to_string_id())})"
		}
		.str {
			result = "string('${pex_file.get_string(value.to_string_id())}')"
		}
		.integer {
			result = "integer(${value.to_integer().str()})"
		}
		.float {
			result = "float(${value.to_float().str()})"
		}
		.boolean {
			result = "boolean(${value.to_boolean().hex()})"
		}
	}
	
	return result
}

@[inline]
pub fn (p PexFile) get_string[T](v T) string {
	$if T is int {
		index := v
		assert index < p.string_table.len
		return p.string_table[index]
	}
	$else $if T is u16 {
		index := int(v)
		assert index < p.string_table.len
		return p.string_table[index]
	}
	$else $if T is StringId {
		index := int(u16(v))
		assert index < p.string_table.len
		return p.string_table[index]
	}
	$else {
		$compile_error("[pex.PexFile.get_string] invalid argument type")
		assert false, "[pex.PexFile.get_string] invalid argument type ${T.name}"
		panic("[pex.PexFile.get_string] invalid argument type ${T.name}")
	}
}

pub fn (p PexFile) get_object(name string) ?&Object {
	for i := 0; i < p.objects.len; i++ {
		tname := p.get_string(p.objects[i].name)
		
		if tname == name {
			return p.objects[i]
		}
	}

	return none
}

pub fn (p PexFile) get_state(obj &Object, name string) ?&State {
	for i := 0; i < obj.states.len; i++ {
		tname := p.get_string(obj.states[i].name)
		if tname == name {
			return obj.states[i]
		}
	}

	return none
}

pub fn (p PexFile) get_empty_state(obj &Object) ?&State {
	name := ""

	for i := 0; i < obj.states.len; i++ {
		tname := p.get_string(obj.states[i].name)
		if tname == name {
			return obj.states[i]
		}
	}

	return none
}

pub fn (p PexFile) get_default_state(obj &Object) ?&State {
	name := p.get_string(obj.auto_state_name)

	for i := 0; i < obj.states.len; i++ {
		tname := p.get_string(obj.states[i].name)
		if tname == name {
			return obj.states[i]
		}
	}

	return none
}

pub fn (p PexFile) get_function_from_state(state &State, func_name string) ?&Function {
	for i := 0; i < state.functions.len; i++ {
		tname := p.get_string(state.functions[i].name)
		if tname == func_name {
			return state.functions[i]
		}
	}

	return none
}

pub fn (p PexFile) get_function_from_empty_state(obj_name string, func_name string) ?&Function {
	obj := p.get_object(obj_name) or { return none }
	default_state := p.get_empty_state(obj) or { return none }
	func := p.get_function_from_state(default_state, func_name) or { return none }
	return func
}

pub fn (p PexFile) get_property(obj_name string, prop_name string) ?&Property {
	obj := p.get_object(obj_name) or { return none }

	for i := 0; i < obj.properties.len; i++ {
		tname := p.get_string(obj.properties[i].name)
		if tname == prop_name {
			return obj.properties[i]
		}
	}

	return none
}

pub fn (p PexFile) get_var(obj_name string, var_name string) ?&Variable {
	obj := p.get_object(obj_name) or { return none }

	for i := 0; i < obj.variables.len; i++ {
		tname := p.get_string(obj.variables[i].name)
		if tname == var_name {
			return obj.variables[i]
		}
	}

	return none
}

fn build_opcode_str() []string {
	mut s := []string{len: int(OpCode.array_rfindelement) + 1}
	
	s[OpCode.nop] = 'nop'				
	s[OpCode.iadd] = 'iadd'
	s[OpCode.fadd] = 'fadd'
	s[OpCode.isub] = 'isub'
	s[OpCode.fsub] = 'fsub'
	s[OpCode.imul] = 'imul'
	s[OpCode.fmul] = 'fmul'
	s[OpCode.idiv] = 'idiv'
	s[OpCode.fdiv] = 'fdiv'
	s[OpCode.imod] = 'imod'
	s[OpCode.not] = 'not'
	s[OpCode.ineg] = 'ineg'
	s[OpCode.fneg] = 'fneg'
	s[OpCode.assign] = 'assign'
	s[OpCode.cast] = 'cast'
	s[OpCode.cmp_eq] = 'cmp_eq'
	s[OpCode.cmp_lt] = 'cmp_lt'
	s[OpCode.cmp_le] = 'cmp_le'
	s[OpCode.cmp_gt] = 'cmp_gt'
	s[OpCode.cmp_ge] = 'cmp_ge'
	s[OpCode.jmp] = 'jmp'
	s[OpCode.jmpt] = 'jmpt'
	s[OpCode.jmpf] = 'jmpf'
	s[OpCode.callmethod] = 'callmethod'
	s[OpCode.callparent] = 'callparent'
	s[OpCode.callstatic] = 'callstatic'
	s[OpCode.ret] = 'ret'
	s[OpCode.strcat] = 'strcat'
	s[OpCode.propget] = 'propget'
	s[OpCode.propset] = 'propset'
	s[OpCode.array_create] = 'array_create'
	s[OpCode.array_length] = 'array_length'
	s[OpCode.array_getelement] = 'array_getelement'
	s[OpCode.array_setelement] = 'array_setelement'
	s[OpCode.array_findelement] = 'array_findelement'
	s[OpCode.array_rfindelement] = 'array_rfindelement'

	return s
}

@[inline]
pub fn opcode_from_byte(v u8) OpCode {
	if v >= u8(OpCode._opcode_end) {
		panic("invalid opcode: 0x" + v.hex())
	}

	return unsafe { OpCode(v) }
}

@[inline]
pub fn (op OpCode) str() string {
	return opcode_str[int(op)]
}

@[inline]
fn (op OpCode) get_count_arguments() int {
	match op {
		.nop {
			return 0
		}

		.jmp,
		.ret {
			return 1
		}

		.not,
		.ineg,
		.fneg,
		.assign,
		.cast,
		.jmpt,
		.jmpf,
		.array_create,
		.array_length {
			return 2
		}

		.iadd,
		.fadd,
		.isub,
		.fsub,
		.imul,
		.fmul,
		.idiv,
		.fdiv,
		.imod,
		.cmp_eq,
		.cmp_lt,
		.cmp_le,
		.cmp_gt,
		.cmp_ge,
		.strcat,
		.propget,
		.propset,
		.array_getelement,
		.array_setelement {
			return 3
		}

		.array_findelement,
		.array_rfindelement {
			return 4
		}

		.callparent {
			return 2//2+
		}

		.callstatic,
		.callmethod {
			return 3//3+
		}
		._opcode_end {
			panic("error")
		}
	}
}