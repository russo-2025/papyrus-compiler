module vm

struct Stack[T] {
mut:
	els []T
}

@[direct_array_access; inline]
fn (mut s Stack[T]) push(el &T) {
	s.els << el
}

@[direct_array_access; inline]
fn (mut s Stack[T]) push_many(data voidptr, len int) {
	unsafe { 
		s.els.push_many(data, len)
	}
}

@[direct_array_access; inline]
fn (mut s Stack[T]) pop() T {
	assert s.els.len > 1
	return s.els.pop()
}

@[direct_array_access; inline]
fn (mut s Stack[T]) pop_len(len int) {
	assert s.els.len >= len
	for _ in 0..len {
		s.els.pop()
	}
}

@[direct_array_access; inline]
fn (s Stack[T]) peek() &T {
	assert s.els.len > 0
	return &s.els[s.els.len - 1]
}

@[direct_array_access; inline]
fn (s Stack[T]) peek_offset(offset int) &T {
	assert offset < s.els.len
	return &s.els[s.els.len - 1 - offset]
}

@[direct_array_access; inline]
fn (s Stack[T]) len() int {
	return s.els.len
}
