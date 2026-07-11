package render

import "core:fmt"

@(private)
front_buffer: Framebuffer
@(private)
back_buffer: Framebuffer

@(private)
active_buffer_ptr: ^Framebuffer

init :: proc(size: [2]int) {
	fmt.println("Initializing Render System...")

	front_buffer = framebuffer_init(size)
	back_buffer = framebuffer_init(size)

	active_buffer_ptr = &back_buffer
}

shutdown :: proc() {
	fmt.println("Shutting down Render System...")
	framebuffer_destroy(&front_buffer)
	framebuffer_destroy(&back_buffer)
}
