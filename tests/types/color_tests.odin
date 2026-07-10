package tests_types

import "core:testing"
import "../../src/types"

@(test)
test_color_pack :: proc(t: ^testing.T) {
    expected: u32 = 0xFFFFFFFF;
    input: types.Color = {
        r = 255,
        g = 255,
        b = 255,
        a = 255,
    }

    result: u32 = types.color_pack(input)

    testing.expect_value(t, result, expected)
}