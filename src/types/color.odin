package types

Color :: struct {
	r: u8,
	g: u8,
	b: u8,
	a: u8,
}

color_pack :: proc(c: Color) -> u32 {
	return transmute(u32)c
}

color_unpack :: proc(p: u32) -> Color {
	return transmute(Color)p
}
