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

draw_line_screen_space :: proc(a_in: [2]int, b_in: [2]int, color: u32) {
	a := a_in
	b := b_in

	steep: bool = abs(a.x - b.x) < abs(a.y - b.y)

	if steep { 	// if line is steep transpose
		a.x, a.y = a.y, a.x
		b.x, b.y = b.y, b.x
	}

	if a.x > b.x { 	// if line is right to left, make it left to right
		a.x, b.x = b.x, a.x
		a.y, b.y = b.y, a.y
	}

	dx := b.x - a.x
	dy := b.y - a.y
	abs_dy := abs(dy)

	direction: int
	if b.y > a.y do direction = 1
	else do direction = -1

	y := a.y
	err: int = 0

	for x := a.x; x <= b.x; x += 1 {

		if steep {
			framebuffer_write_pixel(back_buffer, y, x, color)
		} else {
			framebuffer_write_pixel(back_buffer, x, y, color)
		}

		err += 2 * abs_dy

		// Calculate the step flag (1 if error exceeded dx, 0 otherwise)
		step := int(bool(err > dx))

		// Apply the step changes branchlessly
		y += direction * step
		err -= 2 * dx * step
	}
}
