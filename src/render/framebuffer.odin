#+private package
package render

import "core:math"
import "core:slice"

Framebuffer :: struct {
	width:  int,
	height: int,
	pixels: []u32,
	depths: []f32,
}

framebuffer_init :: proc(size: [2]int) -> Framebuffer {
	count := size.x * size.y
	pixels_mem := make([]u32, count)
	depths_mem := make([]f32, count)
	slice.fill(depths_mem, -math.INF_F32)
	return Framebuffer{width = size.x, height = size.y, pixels = pixels_mem, depths = depths_mem}
}

framebuffer_destroy :: proc(fb: ^Framebuffer) {
	delete(fb.pixels)
	delete(fb.depths)
}

framebuffer_clear :: proc(fb: ^Framebuffer, color: u32) {
	framebuffer_clear_color(fb, color)
	framebuffer_clear_depth(fb)
}

framebuffer_clear_color :: proc(fb: ^Framebuffer, color: u32) {
	slice.fill(fb.pixels, color)
}

framebuffer_clear_depth :: proc(fb: ^Framebuffer) {
	slice.fill(fb.depths, -math.INF_F32)
}

framebuffer_get_pixel :: proc(fb: ^Framebuffer, x: int, y: int) -> (u32, bool) {
	if x < 0 || y < 0 {
		return 0, false
	}

	index := framebuffer_index(fb, x, y)

	if index > len(fb.pixels) {
		return 0, false
	}

	return fb.pixels[index], true
}

framebuffer_get_depth :: proc(fb: ^Framebuffer, x: int, y: int) -> (f32, bool) {
	if x < 0 || y < 0 {
		return 0, false
	}

	index := framebuffer_index(fb, x, y)

	if index > len(fb.pixels) {
		return 0, false
	}

	return fb.depths[index], true
}

framebuffer_write_pixel :: proc(fb: ^Framebuffer, x: int, y: int, color: u32) {
	if x < 0 || y < 0 do return

	index := framebuffer_index(fb, x, y)

	if index > len(fb.pixels) do return

	fb.pixels[index] = color
}

framebuffer_write_pixel_depth :: proc(fb: ^Framebuffer, x: int, y: int, z: f32, color: u32) {
	if x < 0 || y < 0 do return

	index := framebuffer_index(fb, x, y)

	if index > len(fb.pixels) do return

	if (z < fb.depths[index]) do return

	fb.pixels[index] = color
	fb.depths[index] = z
}

framebuffer_index :: proc(fb: ^Framebuffer, x: int, y: int) -> int {
	return y * fb.width + x
}
