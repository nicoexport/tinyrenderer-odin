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

	for !rl.WindowShouldClose() {
		// drawing to back buffer
		render.clear_screen(types.color_pack({255, 0, 0, 255}))
		render.draw_line_screen_space({0, 0}, {100, 100}, types.color_pack({255, 255, 255, 255}))

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
