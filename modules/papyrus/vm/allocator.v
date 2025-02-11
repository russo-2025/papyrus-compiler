module vm

struct Block {
mut:
	size usize
	next &Block
	free bool
}

struct Allocator {
mut:
	head &Block
}

fn create_allocator() Allocator {
	allocator := Allocator {
		head: unsafe { nil }
	}

	return allocator
}

fn (mut allocator Allocator) allocate(size usize) ?voidptr {
	mut current := allocator.head
	for current != unsafe { nil } {
		if current.free && current.size >= size {
			current.free = false
			return unsafe { voidptr(&u8(current) + sizeof(Block)) }
		}
		current = current.next
	}

	mut new_block := unsafe { malloc(sizeof(Block) + size) }
	if new_block == 0 {
		return none
	}
	
	unsafe {
		&Block(new_block).size = size
		&Block(new_block).next = allocator.head
		&Block(new_block).free = false
/*
		new_block = Block {
			size: size
			next: allocator.head
			free: false
		}
*/
	}
	allocator.head = new_block

	return unsafe { voidptr(new_block + sizeof(Block)) }
}

fn (mut allocator Allocator) free_memory(ptr voidptr) {
	block_addr := unsafe { &u8(ptr) - sizeof(Block) }
	mut block := unsafe { &Block(block_addr) }
	block.free = true
}
/*
fn main() {
	mut allocator := Allocator{}
	init_allocator(mut allocator)

	// Выделение памяти
	ptr1 := allocate(mut allocator, sizeof(int)) or { panic('Allocation failed') }
	ptr2 := allocate(mut allocator, 10) or { panic('Allocation failed') }

	// Использование памяти
	unsafe {
		*int(ptr1) = 10
		str := 'Hello'
		for i := 0; i < str.len; i++ {
			*char(ptr2 + i) = str[i]
		}
	}

	// Освобождение памяти
	free_memory(mut allocator, ptr1)
	free_memory(mut allocator, ptr2)
}*/