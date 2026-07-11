#+private package
package render

import "core:slice"

Framebuffer :: struct {
	width:  int,
	height: int,
	pixels: []u32,
}

framebuffer_init :: proc(size: [2]int) -> Framebuffer {
	pixels_mem := make([]u32, size.x * size.y)
	return Framebuffer{width = size.x, height = size.y, pixels = pixels_mem}
}

framebuffer_destroy :: proc(fb: ^Framebuffer) {
	delete(fb.pixels)
}

framebuffer_clear_color :: proc(fb: ^Framebuffer, color: u32) {
	slice.fill(fb.pixels, color)
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

framebuffer_write_pixel :: proc(fb: ^Framebuffer, x: int, y: int, color: u32) {
	if x < 0 || y < 0 {
		return
	}

	index := framebuffer_index(fb, x, y)

	if index > len(fb.pixels) {
		return
	}

	fb.pixels[index] = color
}

framebuffer_index :: proc(fb: ^Framebuffer, x: int, y: int) -> int {
	return y * fb.width + x
}
