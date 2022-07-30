module pex

import encoding.binary

union FloatCast {
	f	f32 = f32(0)
	i 	u32
}

[inline]
fn (mut r Reader) read_string() string {
	mut buf := []u8{}
	mut len := int(r.read_u16())
	len += r.pos

	for r.pos < len {
		buf << r.bytes[r.pos]
		r.pos++
	}
	
	buf << 0x00

	return buf.bytestr()
}

[inline]
fn (mut r Reader) read_string_ref() ?u16 {
	val := r.read_u16()

	if val >= r.pex.string_table.len {
		return error("string index($val) >= total strings count($r.pex.string_table.len)")
	}

	return val
}

[inline]
fn (mut r Reader) read_time() u64 {
	return r.read_u64()
}

[inline]
fn (mut r Reader) read_int() int {
	b := r.bytes[r.pos..r.pos+4]

	_ = b[3] // bounds check
	val := int(b[3]) | (int(b[2])<<int(8)) | (int(b[1])<<int(16)) | (int(b[0])<<int(24))

	r.pos += 4
	return val
}

[inline]
fn (mut r Reader) read_f32() f32 {
	v := FloatCast{i:r.read_u32()}

	unsafe{ return v.f }
}

[inline]
fn (mut r Reader) read_u64() u64 {
	val := binary.big_endian_u64(r.bytes[r.pos..r.pos+8])
	r.pos += 8
	return val
}

[inline]
fn (mut r Reader) read_u32() u32 {
	val := binary.big_endian_u32(r.bytes[r.pos..r.pos+4])
	r.pos += 4
	return val
}

[inline]
fn (mut r Reader) read_u16() u16 {
	val := binary.big_endian_u16(r.bytes[r.pos..r.pos+2])
	r.pos += 2
	return val
}

[inline]
fn (mut r Reader) read_byte() byte {
	val := r.bytes[r.pos]
	r.pos++
	return val
}

[inline]
fn (mut w Writer) write_int_to_u16(v int) {
	assert u32(v) <= 0xFFFF

	w.bytes << u8(v>>int(8))
	w.bytes << u8(v)
}

[inline]
fn (mut w Writer) write_u16(v u16) {
	w.bytes << u8(v>>u16(8))
	w.bytes << u8(v)
}

[inline]
fn (mut w Writer) write_f32(v f32) {
	tmp := FloatCast{f:v}
	unsafe { w.write_u32(tmp.i) }
}

[inline]
fn (mut w Writer) write_int(v int) {
	w.write_u32(u32(v))
}

[inline]
fn (mut w Writer) write_u32(v u32) {
	w.bytes << u8(v>>u32(24))
	w.bytes << u8(v>>u32(16))
	w.bytes << u8(v>>u32(8))
	w.bytes << u8(v)
}

[inline]
fn (mut w Writer) write_u64(v u64) {
	w.bytes << u8(v>>u64(56))
	w.bytes << u8(v>>u64(48))
	w.bytes << u8(v>>u64(40))
	w.bytes << u8(v>>u64(32))
	w.bytes << u8(v>>u64(24))
	w.bytes << u8(v>>u64(16))
	w.bytes << u8(v>>u64(8))
	w.bytes << u8(v)
}

[inline]
fn (mut w Writer) write_byte(v byte) {
	w.bytes << u8(v)
}

[inline]
fn (mut w Writer) write_string_ref(v u16) {
	w.write_u16(v)
}

[inline]
fn (mut w Writer) write_string(str string) {
	w.write_int_to_u16(str.len)
	w.bytes << str.bytes()
}