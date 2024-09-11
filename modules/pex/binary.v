module pex

import encoding.binary

@[inline]
pub fn (mut r Reader) read[T]() T {
	$if T is u8 {
		val := r.bytes[r.pos]
		r.pos++
		return val
	}
	$else $if T is u16 {
		val := binary.big_endian_u16(r.bytes[r.pos..r.pos+2])
		r.pos += 2
		return val
	}
	$else $if T is u32 {
		val := binary.big_endian_u32(r.bytes[r.pos..r.pos+4])
		r.pos += 4
		return val
	}
	$else $if T is int {
		val := binary.big_endian_u32(r.bytes[r.pos..r.pos+4])
		r.pos += 4
		return int(val)
	}
	$else $if T is i32 {
		val := binary.big_endian_u32(r.bytes[r.pos..r.pos+4])
		r.pos += 4
		return int(val)
	}
	$else $if T is i64 {
		val := binary.big_endian_u64(r.bytes[r.pos..r.pos+8])
		r.pos += 8
		return i64(val)
	}
	$else $if T is f32 {
		return cast_u32_to_f32(r.read[u32]())
	}
	$else $if T is string {
		mut len := int(r.read[u16]())
		str := unsafe { tos(voidptr(&r.bytes[r.pos]), len) }
		r.pos += len
		return str
	}
	$else $if T is StringId { //u16
		val := binary.big_endian_u16(r.bytes[r.pos..r.pos+2])
		r.pos += 2
		return val
	}
	$else $if T is GameType { //u16
		val := binary.big_endian_u16(r.bytes[r.pos..r.pos+2])
		r.pos += 2
		return val
	}
	$else $if T is ValueType { //byte
		val := r.bytes[r.pos]
		r.pos++
		return val
	}
	$else {
		$compile_error('[pex.Reader.read] invalid type')
		panic('[pex.Reader.read] invalid type ${T.name}')
	}
}

@[inline]
pub fn (mut w Writer) write[T](v T) {
	$if T is u8 {
		w.buf.bytes << u8(v)
	}
	$else $if T is u16 {
		w.buf.bytes << u8(v>>u16(8))
		w.buf.bytes << u8(v)
	}
	$else $if T is u32 {
		w.buf.bytes << u8(v>>u32(24))
		w.buf.bytes << u8(v>>u32(16))
		w.buf.bytes << u8(v>>u32(8))
		w.buf.bytes << u8(v)
	}
	$else $if T is i32 {
		w.buf.bytes << u8(v>>u32(24))
		w.buf.bytes << u8(v>>u32(16))
		w.buf.bytes << u8(v>>u32(8))
		w.buf.bytes << u8(v)
	}
	$else $if T is int {
		w.buf.bytes << u8(v>>u32(24))
		w.buf.bytes << u8(v>>u32(16))
		w.buf.bytes << u8(v>>u32(8))
		w.buf.bytes << u8(v)
	}
	$else $if T is i64 {
		w.buf.bytes << u8(v>>u64(56))
		w.buf.bytes << u8(v>>u64(48))
		w.buf.bytes << u8(v>>u64(40))
		w.buf.bytes << u8(v>>u64(32))
		w.buf.bytes << u8(v>>u64(24))
		w.buf.bytes << u8(v>>u64(16))
		w.buf.bytes << u8(v>>u64(8))
		w.buf.bytes << u8(v)
	}
	$else $if T is f32 {
		w.write(cast_f32_to_u32(v))
	}
	$else $if T is string {
		str_len := cast_int_to_u16(v.len)
		w.write(str_len)
		w.buf.bytes << v.bytes()
	}
	$else $if T is StringId { //u16
		real_val := u16(v)
		assert real_val < w.pex.string_table.len
		w.buf.bytes << u8(real_val>>u16(8))
		w.buf.bytes << u8(v)
	}
	$else $if T is GameType { //u16
		real_val := u16(v)
		w.buf.bytes << u8(real_val>>u16(8))
		w.buf.bytes << u8(v)
	}
	$else $if T is ValueType { //byte
		w.buf.bytes << u8(v)
	}
	$else {
		$compile_error('[pex.Reader.write] invalid type')
		panic('[pex.Writer.write] invalid type ${T.name}')
	}
}

@[inline]
fn (mut r Reader) read_string_ref() !u16 {
	val := r.read[u16]()
	
	if val >= r.pex.string_table.len {
		return error("string index(${val}) >= total strings count(${r.pex.string_table.len})")
	}

	return val
}

@[inline]
fn (mut r Reader) read_time() i64 {
	return r.read[i64]()
}

@[inline]
pub fn cast_int_to_u16(v int) u16 {
	assert u32(v) <= 0xFFFF
	return u16(v)
}

@[inline]
fn cast_f32_to_u32(v f32) u32 {
	v_u32 := unsafe { &u32(&v) }
	return *v_u32
}

@[inline]
fn cast_u32_to_f32(v u32) f32 {
	v_f32 := unsafe { &f32(&v) }
	return *v_f32
}