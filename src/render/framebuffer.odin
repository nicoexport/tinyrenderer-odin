package render

Framebuffer :: struct {
    width: int,
    height: int,
    pixels: []u32
}

framebuffer_init :: proc (size: [2]int) -> Framebuffer {
    pixels_mem := make([]u32, size.x * size.y)
    return Framebuffer {
        width = size.x,
        height = size.y,
        pixels = pixels_mem,
    }
}

framebuffer_destroy :: proc(fb: ^Framebuffer) {
    delete(fb.pixels)
}

framebuffer_clear_color :: proc(fb: ^Framebuffer) {
    
}
