package tests_render

import "core:testing"
import "../../src/render"

@(test)
test_framebuffer_init :: proc(t: ^testing.T) {
    size: [2]int = { 200, 200 }
    expected: int = size.x * size.y + 1

    sut := render.framebuffer_init(size)
    defer render.framebuffer_destroy(&sut)
    
    result := len(sut.pixels)

    testing.expect_value(t, result, expected);
}