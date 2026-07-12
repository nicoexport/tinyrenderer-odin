package render

import "base:intrinsics"
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

draw_triangle :: proc(v0: [3]f32, v1: [3]f32, v2: [3]f32, color: u32) {
	bb := bounding_box_triangle_2d(f32, v0.xy, v1.xy, v2.xy)
	total_area := signed_triangle_area(v0.xy, v1.xy, v2.xy)

	x_lower: int = max(bb.min_x, 0)
	x_upper: int = min(bb.max_x, back_buffer.width - 1)
	for x := x_lower; x <= x_upper; x += 1 {
		y_lower: int = max(bb.min_y, 0)
		y_upper: int = min(bb.max_y, back_buffer.height - 1)
		for y := y_lower; y <= y_upper; y += 1 {
			p: [2]f32 = {f32(x), f32(y)}

			alpha := signed_triangle_area(p, v1.xy, v2.xy) / total_area
			beta := signed_triangle_area(p, v2.xy, v0.xy) / total_area
			gamma := signed_triangle_area(p, v0.xy, v1.xy) / total_area

			if alpha < 0 || beta < 0 || gamma < 0 {
				continue
			}

			z: f32 = alpha * v0.z + beta * v1.z + gamma * v2.z

			framebuffer_write_pixel(back_buffer, x, y, color)
		}
	}
}

bounding_box_triangle_2d :: proc(
	$T: typeid,
	v0: [2]T,
	v1: [2]T,
	v2: [2]T,
) -> BoundingBox2D(int) where intrinsics.type_is_numeric(T) {
	min_x: int = int(min(v0.x, v1.x, v2.x))
	max_x: int = int(max(v0.x, v1.x, v2.x))
	min_y: int = int(min(v0.y, v1.y, v2.y))
	max_y: int = int(max(v0.y, v1.y, v2.y))

	return {min_x, max_x, min_y, max_y}
}

signed_triangle_area :: proc(a: [2]f32, b: [2]f32, c: [2]f32) -> f32 {
	rect_area := (b.y - a.y) * (b.x + a.x) + (c.y - b.y) * (c.x + b.x) + (a.y - c.y) * (a.x + c.x)
	return 0.5 * rect_area
}
