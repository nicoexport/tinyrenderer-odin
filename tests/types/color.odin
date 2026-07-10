package tests_types

import "core:testing"
import "../../src/types"

Color_Pack_Test_Case :: struct {
    input: types.Color,
    expected: u32,
}

@(test)
test_color_pack :: proc(t: ^testing.T) {
    test_cases := []Color_Pack_Test_Case {
        {{r = 255, g = 255, b = 255, a = 255}, 0xFFFFFFFF},
        {{r = 0, g = 0, b = 0, a = 0}, 0x00000000},
        {{r = 255, g = 0, b = 0, a = 0}, 0x00FF0000},
        {{r = 0, g = 255, b = 0, a = 0}, 0x0000FF00},
        {{r = 0, g = 0, b = 255, a = 0}, 0x000000FF},
    }

    for tc in test_cases {
        result := types.color_pack(tc.input)
        testing.expect_value(t, result, tc.expected)
    }
}

Color_Unpack_Test_Case :: struct {
    input: u32,
    expected: types.Color,
}

@(test)
test_color_unpack :: proc(t: ^testing.T) {
    test_cases := []Color_Unpack_Test_Case {
        {0xFFFFFFFF, {r = 255, g = 255, b = 255, a = 255}},
        {0x00000000, {r = 0, g = 0, b = 0, a = 0}},
        {0x00FF0000, {r = 255, g = 0, b = 0, a = 0}},
        {0x0000FF00, {r = 0, g = 255, b = 0, a = 0}},
        {0x000000FF, {r = 0, g = 0, b = 255, a = 0}},
    }

    for tc in test_cases {
        result := types.color_unpack(tc.input)
        testing.expect_value(t, result, tc.expected)
    }
}