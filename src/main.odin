package tinyrenderer

import rl "vendor:raylib"
import fmt "core:fmt"
import "render"

main :: proc() {
    rl.InitWindow(800, 450, "raylib [core] example - basic window")

    fb := render.framebuffer_init({1280, 720})
    defer render.framebuffer_destroy(&fb)

    fmt.println("Runtime framebuffer pixels allocated:", len(fb.pixels))

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)
            rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.LIGHTGRAY)
        rl.EndDrawing()
      }
    rl.CloseWindow()
}

