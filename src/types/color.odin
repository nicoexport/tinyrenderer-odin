package types

Color :: struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
}

color_pack :: proc(c: Color) -> u32 {
    return (u32(c.a) << 24) | (u32(c.r) << 16 | (u32(c.g) << 8) | (u32(c.b)))
}

color_unpack :: proc(p: u32) -> Color {
    return Color {
        a = u8((p >> 24) & 0xFF),
        r = u8((p >> 16) & 0xFF),
        g = u8((p >> 8) & 0xFF),
        b = u8(p & 0xFF),
    }
}