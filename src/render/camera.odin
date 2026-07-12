package render

import "core:math/linalg"

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

camera_move :: proc(cam: ^Camera, input: [3]f32, speed: f32) {
	// 1. Calculate camera local axes
	forward := linalg.normalize(cam.center - cam.eye)
	right := linalg.normalize(linalg.cross(forward, cam.up))
	up := cam.up // Or calculate true up: linalg.cross(right, forward)

	// 2. Combine inputs with camera axes
	move_dir: [3]f32
	move_dir += forward * input.z
	move_dir += right * input.x
	move_dir += up * input.y

	// 3. Normalize and apply movement
	if linalg.length(move_dir) > 0.0001 {
		move_dir = linalg.normalize(move_dir)

		displacement := move_dir * speed
		cam.eye += displacement
		cam.center += displacement
	}
}
