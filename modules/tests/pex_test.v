import pex

fn test_enum() {
	assert u8(pex.OpCode.array_rfindelement) == 0x23
	
	assert u8(pex.ValueType.null) == 0
	assert u8(pex.ValueType.identifier) == 1
	assert u8(pex.ValueType.str) == 2
	assert u8(pex.ValueType.integer) == 3
	assert u8(pex.ValueType.float) == 4
	assert u8(pex.ValueType.boolean) == 5
	
}