package render

import "base:intrinsics"

BoundingBox2D :: struct($T: typeid) where intrinsics.type_is_numeric(T) {
	min_x: T,
	max_x: T,
	min_y: T,
	max_y: T,
}
