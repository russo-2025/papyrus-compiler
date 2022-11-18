import pex

import math

fn test_read() {
	mut r := &pex.Reader{
		pex: unsafe { voidptr(0) }
		bytes: 	[]byte{}
	}

	is_empty := fn [r] () bool {
		return r.pos >= r.bytes.len
	}

	//byte
	r.bytes << 0x12
	assert r.read<byte>() == byte(0x12)
	assert is_empty()

	r.bytes << 0xff
	assert r.read<byte>() == byte(0xff)
	assert is_empty()

	//u16
	r.bytes << 0x12
	r.bytes << 0x34
	assert r.read<u16>() == u16(0x1234)
	assert is_empty()

	r.bytes << 0xff
	r.bytes << 0xff
	assert r.read<u16>() == u16(0xffff)
	assert is_empty()

	//u32
	r.bytes << 0x12
	r.bytes << 0x34
	r.bytes << 0x56
	r.bytes << 0x78
	assert r.read<u32>() == u32(0x12345678)
	assert is_empty()

	r.bytes << 0xff
	r.bytes << 0xff
	r.bytes << 0xff
	r.bytes << 0xff
	assert r.read<u32>() == u32(0xffffffff)
	assert is_empty()

	//int
	r.bytes << 0x80
	r.bytes << 0x00
	r.bytes << 0x00
	r.bytes << 0x00
	assert r.read<int>() == int(math.min_i32)
	assert is_empty()

	r.bytes << 0x7f
	r.bytes << 0xff
	r.bytes << 0xff
	r.bytes << 0xff
	assert r.read<int>() == int(math.max_i32)
	assert is_empty()

	//i64
	r.bytes << 0x12
	r.bytes << 0x34
	r.bytes << 0x56
	r.bytes << 0x78
	r.bytes << 0x12
	r.bytes << 0x34
	r.bytes << 0x56
	r.bytes << 0x78
	assert r.read<i64>() == i64(0x1234567812345678)
	assert is_empty()

	r.bytes << 0x80
	r.bytes << 0x00
	r.bytes << 0x00
	r.bytes << 0x00
	r.bytes << 0x00
	r.bytes << 0x00
	r.bytes << 0x00
	r.bytes << 0x00
	assert r.read<i64>() == i64(math.min_i64)
	assert is_empty()

	r.bytes << 0x7f
	r.bytes << 0xff
	r.bytes << 0xff
	r.bytes << 0xff
	r.bytes << 0xff
	r.bytes << 0xff
	r.bytes << 0xff
	r.bytes << 0xff
	assert r.read<i64>() == i64(math.max_i64)
	assert is_empty()

	//f32
	r.bytes << 0xc3
	r.bytes << 0x23
	r.bytes << 0x14
	r.bytes << 0xdb
	assert r.read<f32>() == f32(-163.081468)
	assert is_empty()
	
	r.bytes << 0x47
	r.bytes << 0xa8
	r.bytes << 0x3B
	r.bytes << 0x4f
	assert r.read<f32>() == f32(86134.617983)
	assert is_empty()

	//string
	r.bytes << 0  //len u16
	r.bytes << 6
	r.bytes << "a"[0] //str []char
	r.bytes << "b"[0]
	r.bytes << "c"[0]
	r.bytes << "d"[0]
	r.bytes << "e"[0]
	r.bytes << "f"[0]

	str := r.read<string>()

	assert str[0] == "a"[0]
	assert str[1] == "b"[0]
	assert str[2] == "c"[0]
	assert str[3] == "d"[0]
	assert str[4] == "e"[0]
	assert str[5] == "f"[0]

	assert str.len == "abcdef".len
	assert is_empty()
}

fn test_write() {
	mut w := &pex.Writer{
		pex: unsafe { voidptr(0) }
		bytes: 	[]u8{}
	}

	mut i := 0
	mut ref_i := &i

	next := fn [w, mut ref_i] () byte {
		val := w.bytes[*ref_i]
		(*ref_i)++
		return val
	}
	
	is_empty := fn [w, mut ref_i] () bool {
		return *ref_i >= w.bytes.len
	}

	//byte
	w.write(byte(0xff))
	assert next() == 0xff
	assert is_empty()

	w.write(byte(0x56))
	assert next() == 0x56
	assert is_empty()

	//u16
	w.write(u16(0xffff))
	assert next() == 0xff
	assert next() == 0xff
	assert is_empty()

	w.write(u16(0x1234))
	assert next() == 0x12
	assert next() == 0x34
	assert is_empty()

	//u32
	w.write(u32(0xffffffff))
	assert next() == 0xff
	assert next() == 0xff
	assert next() == 0xff
	assert next() == 0xff
	assert is_empty()

	w.write(u32(0x12345678))
	assert next() == 0x12
	assert next() == 0x34
	assert next() == 0x56
	assert next() == 0x78
	assert is_empty()

	//int
	w.write(int(1))
	assert next() == 0x00
	assert next() == 0x00
	assert next() == 0x00
	assert next() == 0x01
	assert is_empty()

	w.write(int(-6))
	assert next() == 0xff
	assert next() == 0xff
	assert next() == 0xff
	assert next() == 0xfa
	assert is_empty()

	w.write(math.min_i32)
	assert next() == 0x80
	assert next() == 0x00
	assert next() == 0x00
	assert next() == 0x00
	assert is_empty()

	w.write(math.max_i32)
	assert next() == 0x7f
	assert next() == 0xff
	assert next() == 0xff
	assert next() == 0xff
	assert is_empty()

	//i64
	w.write(i64(0x1234567812345678))
	assert next() == 0x12
	assert next() == 0x34
	assert next() == 0x56
	assert next() == 0x78
	assert next() == 0x12
	assert next() == 0x34
	assert next() == 0x56
	assert next() == 0x78
	assert is_empty()

	w.write(i64(math.min_i64))
	assert next() == 0x80
	assert next() == 0x00
	assert next() == 0x00
	assert next() == 0x00
	assert next() == 0x00
	assert next() == 0x00
	assert next() == 0x00
	assert next() == 0x00
	assert is_empty()

	w.write(i64(math.max_i64))
	assert next() == 0x7f
	assert next() == 0xff
	assert next() == 0xff
	assert next() == 0xff
	assert next() == 0xff
	assert next() == 0xff
	assert next() == 0xff
	assert next() == 0xff
	assert is_empty()
	
	//f32
	w.write(f32(-163.081468))
	assert next() == 0xc3
	assert next() == 0x23
	assert next() == 0x14
	assert next() == 0xdb
	assert is_empty()
	
	w.write(f32(86134.617983))
	assert next() == 0x47
	assert next() == 0xa8
	assert next() == 0x3B
	assert next() == 0x4f
	assert is_empty()

	//string
	w.write("abcdefg")
	assert next() == 0  //len u16
	assert next() == 7
	assert next() == "a"[0] //str []char
	assert next() == "b"[0]
	assert next() == "c"[0]
	assert next() == "d"[0]
	assert next() == "e"[0]
	assert next() == "f"[0]
	assert next() == "g"[0]
	assert is_empty()
}