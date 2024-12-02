module vm

struct Stack[T] {
mut:
	els []T
}

fn (mut s Stack[T]) push(el T) {
	s.els << el
}

fn (mut s Stack[T]) push_many(els []T) {
	for el in els {
		s.els << el
	}
}

fn (mut s Stack[T]) pop() T {
	assert s.els.len > 1
	return s.els.pop()
}

fn (mut s Stack[T]) pop_len(len int) {
	assert s.els.len >= len
	for _ in 0..len {
		s.els.pop()
	}
}

fn (s Stack[T]) peek() &T {
	assert s.els.len > 0
	return &s.els[s.els.len - 1]
}

fn (s Stack[T]) peek_offset(offset int) &T {
	assert offset < s.els.len
	return &s.els[s.els.len - 1 - offset]
}

fn (s Stack[T]) len() int {
	return s.els.len
}
