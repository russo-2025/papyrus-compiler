module pex

const (
	datatype_str = build_datatype_str()
	opcode_str = build_opcode_str()
)

fn build_datatype_str() []string {
	mut s := []string{len: int(DataType.type_bool) + 1}
	
	s[DataType.type_null] = 'null'
	s[DataType.type_ident] = 'indent'
	s[DataType.type_string] = 'string'
	s[DataType.type_integer] = 'integer'
	s[DataType.type_float] = 'float'
	s[DataType.type_bool] = 'bool'

	return s
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

pub enum OpCode as u8 {
	nop					//none		do nothing
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

pub fn opcode_from_byte(v byte) OpCode {
	if v >= byte(OpCode._opcode_end) {
		panic("invalid opcode: 0x" + v.hex())
	}

	return unsafe { OpCode(v) }
}

pub fn (op OpCode) str() string {
	return opcode_str[int(op)]
}

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

pub enum DataType {
	type_null
	type_ident
	type_string
	type_integer
	type_float
	type_bool
}

pub fn (typ DataType) str() string {
	return datatype_str[int(typ)]
}

pub struct DebugFunction {
pub mut:
	object_name			u16 //Index(base 0) into string table.
	state_name			u16 //Index(base 0) into string table.
	function_name		u16 //Index(base 0) into string table.
	function_type		byte //valid values 0-3
	instruction_count	u16	
	line_numbers		[]u16 //[instruction_count] Maps instructions to their original lines in the source.
}

pub struct UserFlag {
pub mut:
	name		u16		//Index(base 0) into string table.
	flag_index	byte	//Bit index
}

[heap]
pub struct PexFile {
pub mut:
	magic_number		u32		// 0xFA57C0DE (FASTCODE?)
	major_version		byte	// 3
	minor_version		byte	// 1 (Dawnguard, Hearthfire and Dragonborn scripts are 2)
	game_id				u16		// 1 = Skyrim?
	compilation_time	i64
	
	src_file_name		string	// Name of the source file this file was compiled from (.psc extension).
	user_name			string	// Username used to compile the script
	machine_name		string	// Machine name used to compile the script

	//String Table
	string_table_count	u16
	string_table		[]string //StringTable to look up member names and other stuff from

	//Debug Info
	has_debug_info		byte //Flag, if zero then no debug info is present and the rest of the record is skipped
	modification_time 	i64 // time_t
	function_count		u16
	functions			[]DebugFunction

	user_flag_count		u16
	user_flags			[]UserFlag
	object_count		u16	
	objects				[]Object //[object_count]
}

pub struct Object {
pub mut:
	name				u16	//Index(base 0) into string table.
	size				u32	
	parent_class_name	u16	//Index(base 0) into string table.
	docstring			u16	//Index(base 0) into string table.
	user_flags			u32	
	auto_state_name		u16	//Index(base 0) into string table.
	num_variables		u16	
	variables			[]Variable //[num_variables]	
	num_properties		u16	
	properties			[]Property //[num_properties]	
	num_states			u16	
	states				[]State //[num_states]
}

pub struct Variable {
pub mut:
	name		u16	//Index(base 0) into string table.
	type_name	u16	//Index(base 0) into string table.
	user_flags	u32	
	data		VariableData //Default value
}

pub struct VariableData {
pub mut:
	typ			byte //0 = null, 1 = identifier, 2 = string, 3 = integer, 4 = float, 5 = bool
	string_id	u16 //Index(base 0) into string table, present for identifier and string types only
	integer		int	//present for integer types only
	float		f32	//present for float types only
	boolean		byte //present for bool types only
}

pub struct Property {
pub mut:
	name			u16	//Index(base 0) into string table
	typ				u16	//Index(base 0) into string table
	docstring		u16	//Index(base 0) into string table
	user_flags		u32	
	flags			byte //bitfield: 1(bit 1) = read, 2(bit 2) = write, 4(bit 3) = autovar. For example, Property in a source script contains only get() or is defined AutoReadOnly then the flags is 0x1, contains get() and set() then the flags is 0x3.
	auto_var_name	u16	//Index(base 0) into string table, present if (flags & 4) != 0
	read_handler	FunctionInfo //present if (flags & 5) == 1
	write_handler	FunctionInfo //present if (flags & 6) == 2
}

pub struct State {
pub mut:
	name			u16	//Index(base 0) into string table, empty string for default state
	num_functions	u16	
	functions		[]Function // [num_functions]
}

pub struct Function {
pub mut:
	name	u16	//Index(base 0) into string table
	info	FunctionInfo
}

pub struct FunctionInfo {
pub mut:
	return_type			u16	//Index(base 0) into string table
	docstring			u16	//Index(base 0) into string table
	user_flags			u32	
	flags				byte //первый бит - global, второй бит - native
	num_params			u16	
	params				[]VariableType //[num_params]	
	num_locals			u16	
	locals				[]VariableType //[num_locals]	
	num_instructions	u16	
	instructions		[]Instruction //[num_instructions]
}

pub struct VariableType {
pub mut:
	name	u16	//Index(base 0) into string table
	typ		u16	//Index(base 0) into string table
}

pub struct Instruction {
pub mut:
	op		OpCode 			//see Opcodes
	args	[]VariableData	//[changes depending on opcode]	Length is dependent on opcode, also varargs
}

fn (p PexFile) get_string(i int) string {
	assert i < p.string_table.len
	assert i < p.string_table_count
	return p.string_table[i]
}

fn (p PexFile) get_object_by_name(name string) ?&Object {
	for i := 0; i < p.objects.len; i++ {
		obj_name := p.get_string(p.objects[i].name)
		
		if name == obj_name {
			return unsafe { &p.objects[i] }
		}
	}

	return none
}

fn (p PexFile) get_state(obj &Object, name string) ?&State {
	for i := 0; i < obj.states.len; i++ {
		state_name := p.get_string(obj.states[i].name)
		if state_name == name {
			return unsafe { &obj.states[i] }
		}
	}

	return none
}

fn (p PexFile) get_default_state(obj &Object) ?&State {
	default_state_name := p.get_string(obj.auto_state_name)

	for i := 0; i < obj.states.len; i++ {
		state_name := p.get_string(obj.states[i].name)
		if state_name == default_state_name {
			return unsafe { &obj.states[i] }
		}
	}

	return none
}

fn (p PexFile) get_function(state &State, name string) ?&Function {
	for i := 0; i < state.functions.len; i++ {
		state_name := p.get_string(state.functions[i].name)
		if state_name == name {
			return unsafe { &state.functions[i] }
		}
	}

	return none
}

fn (p PexFile) find_function(obj_name string, func_name string) ?&Function {
	obj := p.get_object_by_name(obj_name) or { return none }
	default_state := p.get_default_state(obj) or { return none }
	func := p.get_function(default_state, func_name) or { return none }
	return func
}