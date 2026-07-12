package render

import "base:intrinsics"
import "core:fmt"
import "core:math/linalg"
import "core:math/rand"

@(private)
buffer_a: Framebuffer
@(private)
buffer_b: Framebuffer

front_buffer: ^Framebuffer
back_buffer: ^Framebuffer

// used to hold memory for when depth needs to be converted to color for ouput
// TODO: rethink, if this is the right approach. For now it is definately fine.
// I like that the render module owns the memory and frees it on shutdown.
vis_depth_buffer: []u32

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
	delete(vis_depth_buffer)
}

swap_buffers :: proc() {
	front_buffer, back_buffer = back_buffer, front_buffer
}

get_pixels :: proc() -> rawptr {
	return raw_data(front_buffer.pixels)
}

get_depth_visualized :: proc() -> rawptr {
	// Automatically allocate or resize only when the framebuffer size changes
	if len(vis_depth_buffer) != len(front_buffer.depths) {
		if vis_depth_buffer != nil do delete(vis_depth_buffer)
		vis_depth_buffer = make([]u32, len(front_buffer.depths))
	}

	// Process the data in-place using the private buffer
	for depth, i in front_buffer.depths {
		// remapping, since depth values range from -1 to 1
		remapped := (depth + 1) / 2
		d := clamp(remapped, 0.0, 1.0)
		c := u8(d * 255.0)
		vis_depth_buffer[i] = u32(c) | (u32(c) << 8) | (u32(c) << 16) | (0xFF << 24)
	}

	return raw_data(vis_depth_buffer)
}

clear_screen :: proc(color: u32) {
	framebuffer_clear(back_buffer, color)
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

// TODO: have one main camera as a global package variable state
draw_mesh :: proc(mesh: ^Mesh, cam: Camera) {
	width := back_buffer.width
	height := back_buffer.height

	m_model_view := look_at(cam.eye, cam.center, cam.up)
	m_perspective := perspective(2, cam)
	// NOTE: in my Zig tinyrenderer I didnt use the whole viewport size but rather something like:
	// const m_viewport = viewport(@divTrunc(w, 16), @divTrunc(h, 16), @divTrunc(w * 7, 8), @divTrunc(h * 7, 8));
	// check if this causes problems
	m_viewport := viewport(0, 0, width, height)
	m_pmv := m_perspective * m_model_view

	// resetting seed for the random color per face
	rand.reset(0)

	for face in mesh.faces {
		v0 := mesh.vertices[face.x]
		v1 := mesh.vertices[face.y]
		v2 := mesh.vertices[face.z]

		// Odin supports matrix and vector math out of the box, YAY!
		v0_clip := m_pmv * [4]f32{v0.x, v0.y, v0.z, 1.0}
		v1_clip := m_pmv * [4]f32{v1.x, v1.y, v1.z, 1.0}
		v2_clip := m_pmv * [4]f32{v2.x, v2.y, v2.z, 1.0}

		// clipping geometry, thats too near to the camera for now
		epsilon: f32 = 0.1
		if v0_clip.w < epsilon || v1_clip.w < epsilon || v2_clip.w < epsilon {
			continue
		}

		v0_ndc := v0_clip / v0_clip.w
		v1_ndc := v1_clip / v1_clip.w
		v2_ndc := v2_clip / v2_clip.w

		v0_viewport := m_viewport * v0_ndc
		v1_viewport := m_viewport * v1_ndc
		v2_viewport := m_viewport * v2_ndc

		v0_screen := [3]f32{v0_viewport.x, v0_viewport.y, v0_ndc.z}
		v1_screen := [3]f32{v1_viewport.x, v1_viewport.y, v1_ndc.z}
		v2_screen := [3]f32{v2_viewport.x, v2_viewport.y, v2_ndc.z}

		draw_triangle(v0_screen, v1_screen, v2_screen, random_color_u32())
	}
}

random_color_u32 :: proc() -> u32 {
	return (rand.uint32() & 0x00FFFFFF) | 0xFF000000
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

			framebuffer_write_pixel_depth(back_buffer, x, y, z, color)
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

viewport :: proc(x_in: int, y_in: int, w_in: int, h_in: int) -> matrix[4, 4]f32 {
	x, y, w, h := f32(x_in), f32(y_in), f32(w_in), f32(h_in)
	return matrix[4, 4]f32{
		w / 2, 0, 0, x + w / 2,
		0, -h / 2, 0, y + h / 2,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}
}

perspective :: proc(f: f32, cam: Camera) -> Mat4 {
	scale := linalg.length((cam.eye - cam.center))
	return matrix[4, 4]f32{
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, -1.0 / f, scale,
	}
}

look_at :: proc(eye: Vec3, center: Vec3, up: Vec3) -> Mat4 {
	n := linalg.normalize(eye - center)
	l := linalg.cross(up, n)
	m := linalg.cross(n, l)

	view := matrix[4, 4]f32{
		l.x, l.y, l.z, 0,
		m.x, m.y, m.z, 0,
		n.x, n.y, n.z, 0,
		0, 0, 0, 1,
	}

	model := matrix[4, 4]f32{
		1, 0, 0, -center.x,
		0, 1, 0, -center.y,
		0, 0, 1, -center.z,
		0, 0, 0, 1,
	}

	return view * model
}
