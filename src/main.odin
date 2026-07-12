package tinyrenderer

import "render"
import "types"
import rl "vendor:raylib"

WIDTH :: 800
HEIGHT :: 450

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

	for !rl.WindowShouldClose() {
		// drawing to back buffer
		render.clear_screen(types.color_pack({0, 0, 0, 255}))
		render.draw_mesh(&mesh, cam)

		// displaying front buffer
		rl.UpdateTexture(texture, render.get_pixels())
		rl.BeginDrawing()
		rl.DrawTexture(texture, 0, 0, rl.WHITE)
		rl.EndDrawing()

		// swapping buffers
		render.swap_buffers()
	}
	rl.CloseWindow()
}
