package render

import "core:math"
import "core:math/linalg"

Vec3 :: [3]f32
Mat4 :: matrix[4, 4]f32


// TODO: rework this to use proper near / far plane projections.
// The center projection approach breaks as soon as we introduce camera movement and rotations
// presumably
Camera :: struct {
	eye:    [3]f32,
	center: [3]f32,
	up:     [3]f32,
}

CameraController :: struct {
	yaw:         f32, // Left/Right angle (initialized to -90.0 usually)
	pitch:       f32, // Up/Down angle
	sensitivity: f32, // Mouse speed modifier
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

camera_update_look :: proc(cam: ^Camera, ctrl: ^CameraController, delta: [2]f32) {
	// 2. Update angles based on mouse movement
	ctrl.yaw += delta.x * ctrl.sensitivity
	ctrl.pitch -= delta.y * ctrl.sensitivity // Inverted so moving mouse up looks up

	// 3. Clamp pitch to prevent the camera flipping upside down (-89 to 89 degrees)
	ctrl.pitch = linalg.clamp(ctrl.pitch, -85, 85.0)

	// 4. Convert degrees to radians for math functions
	yaw_rad := math.to_radians(ctrl.yaw)
	pitch_rad := math.to_radians(ctrl.pitch)

	// 5. Calculate the new forward direction vector using spherical coordinates
	forward: [3]f32
	forward.x = math.cos(yaw_rad) * math.cos(pitch_rad)
	forward.y = math.sin(pitch_rad)
	forward.z = math.sin(yaw_rad) * math.cos(pitch_rad)
	forward = linalg.normalize(forward)

	// 6. Update the camera's center look-at target relative to the eye position
	cam.center = cam.eye + forward
}
