package tinyrenderer

import "render"
import "types"
import rl "vendor:raylib"

WIDTH :: 800
HEIGHT :: 450

CAMERA_MOVE_SPEED :: 2.5

do_draw_depth := false

main :: proc() {
	rl.InitWindow(WIDTH, HEIGHT, "raylib [core] example - basic window")

	render.init({WIDTH, HEIGHT})
	defer render.shutdown()

	img := rl.GenImageColor(WIDTH, HEIGHT, rl.BLUE)
	texture := rl.LoadTextureFromImage(img)

	mesh, ok := render.load_obj("res/model.obj")
	defer render.mesh_delete(&mesh)

	eye: [3]f32 = {-1, 0, 2}
	center: [3]f32 = {0, 0, 0}
	up: [3]f32 = {0, 1, 0}

	cam: render.Camera = render.camera_init(eye, center, up)
	camera_ctrl := render.CameraController {
		yaw         = -90.0, // Faces forward down the -Z axis initially
		pitch       = 0.0,
		sensitivity = 0.05,
	}

	rl.DisableCursor()

	// TODO: look into a real order of input, drawing, etc.
	for !rl.WindowShouldClose() {
		// handle input
		if (rl.IsKeyPressed(.F1)) {
			do_draw_depth = !do_draw_depth
		}

		render.camera_update_look(&cam, &camera_ctrl, rl.GetMouseDelta())
		dir := get_input_direction()
		render.camera_move(&cam, dir, CAMERA_MOVE_SPEED * rl.GetFrameTime())

		// drawing to back buffer
		render.clear_screen(types.color_pack({0, 0, 0, 255}))
		render.draw_mesh(&mesh, cam)

		// displaying front buffer
		if do_draw_depth {
			rl.UpdateTexture(texture, render.get_depth_visualized())
		} else {
			rl.UpdateTexture(texture, render.get_pixels())
		}

		rl.BeginDrawing()
		rl.DrawTexture(texture, 0, 0, rl.WHITE)
		rl.EndDrawing()

		// swapping buffers
		render.swap_buffers()
	}
	rl.CloseWindow()
}

get_input_direction :: proc() -> [3]f32 {
	dir := [3]f32{0, 0, 0}

	if rl.IsKeyDown(.W) do dir.z += 1
	if rl.IsKeyDown(.S) do dir.z -= 1
	if rl.IsKeyDown(.D) do dir.x += 1
	if rl.IsKeyDown(.A) do dir.x -= 1
	if rl.IsKeyDown(.SPACE) do dir.y += 1
	if rl.IsKeyDown(.LEFT_SHIFT) do dir.y -= 1

	return dir
}
