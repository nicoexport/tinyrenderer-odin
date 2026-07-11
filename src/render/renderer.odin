package render

import "core:fmt"

@(private)
buffer_a: Framebuffer
@(private)
buffer_b: Framebuffer

front_buffer: ^Framebuffer
back_buffer: ^Framebuffer


init :: proc(size: [2]int) {
	fmt.println("Initializing Render System...")

	buffer_a = framebuffer_init(size)
	buffer_b = framebuffer_init(size)

	front_buffer = &buffer_a
	back_buffer = &buffer_b
}

shutdown :: proc() {
	fmt.println("Shutting down Render System...")
	framebuffer_destroy(&buffer_a)
	framebuffer_destroy(&buffer_b)
}

swap_buffers :: proc() {
	front_buffer, back_buffer = back_buffer, front_buffer
}

get_pixels :: proc() -> rawptr {
	return raw_data(front_buffer.pixels)
}

clear_screen :: proc(color: u32) {
	framebuffer_clear_color(back_buffer, color)
}
