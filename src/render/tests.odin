package render

import "core:fmt"
import "core:log"
import "core:testing"

@(test)
test_frame_buffer_width :: proc(t: ^testing.T) {
	sut := framebuffer_init({300, 200})
	defer framebuffer_destroy(&sut)

	expected := 300
	result := sut.width

	testing.expect_value(t, result, expected)
}

@(test)
test_frame_buffer_height :: proc(t: ^testing.T) {
	sut := framebuffer_init({300, 200})
	defer framebuffer_destroy(&sut)

	expected := 200
	result := sut.height

	testing.expect_value(t, result, expected)
}

@(test)
test_framebuffer_init :: proc(t: ^testing.T) {
	size: [2]int = {300, 200}

	sut := framebuffer_init(size)
	defer framebuffer_destroy(&sut)

	expected: int = size.x * size.y
	result := len(sut.pixels)

	testing.expect_value(t, result, expected)
}

Framebuffer_Get_Pixel_TestCase :: struct {
	input:       [2]int,
	expected_ok: bool,
	expeceted:   u32,
}

@(test)
test_framebuffer_get_pixel :: proc(t: ^testing.T) {
	sut := framebuffer_init({200, 200})
	defer framebuffer_destroy(&sut)

	test_cases := []Framebuffer_Get_Pixel_TestCase {
		{{0, 0}, true, 0},
		{{199, 199}, true, 0},
		{{-1, -1}, false, 0},
		{{200, 200}, false, 0},
	}

	for tc in test_cases {
		result, result_ok := framebuffer_get_pixel(&sut, tc.input.x, tc.input.y)
		testing.expect_value(t, result_ok, tc.expected_ok)
		testing.expect_value(t, result, tc.expeceted)
	}
}

@(test)
test_obj_loader_load_obj :: proc(t: ^testing.T) {
	mesh, ok := load_obj("res/model.obj")
	defer mesh_delete(&mesh)

	testing.expect_value(t, true, ok)
	testing.expect_value(t, 2519, len(mesh.vertices))
}
