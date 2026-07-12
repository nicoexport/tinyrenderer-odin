package render

Vec3 :: [3]f32
Mat4 :: matrix[4, 4]f32

Camera :: struct {
	eye:    [3]f32,
	center: [3]f32,
	up:     [3]f32,
}

camera_init :: proc(eye: Vec3, center: Vec3, up: Vec3) -> Camera {
	return {eye, center, up}
}
