package tinyrenderer

import fmt "core:fmt"
import "render"
import "types"
import rl "vendor:raylib"

WIDTH :: 800
HEIGHT :: 450

main :: proc() {


	rl.InitWindow(WIDTH, HEIGHT, "raylib [core] example - basic window")

	render.init({WIDTH, HEIGHT})
	defer render.shutdown()

	render.clear_screen(types.color_pack({255, 0, 0, 255}))

	img := rl.GenImageColor(WIDTH, HEIGHT, rl.BLUE)
	texture := rl.LoadTextureFromImage(img)

	for !rl.WindowShouldClose() {

		rl.UpdateTexture(texture, render.get_pixels())

		rl.BeginDrawing()
		rl.DrawTexture(texture, 0, 0, rl.WHITE)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
