package render

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Mesh :: struct {
	vertices: [dynamic][3]f32,
	faces:    [dynamic][3]uint,
}

mesh_add_vertex :: proc(mesh: ^Mesh, vertex: [3]f32) {
	append(&mesh.vertices, vertex)
}

mesh_add_face :: proc(mesh: ^Mesh, face: [3]uint) {
	append(&mesh.faces, face)
}

mesh_delete :: proc(mesh: ^Mesh) {
	delete(mesh.vertices)
	delete(mesh.faces)
}

// TODO: parse vertex tangents and normals as well. For now only vertex positions
load_obj :: proc(filepath: string) -> (mesh: Mesh, succuess: bool) {
	// Read entire file into temp memory
	data, err := os.read_entire_file_from_path(filepath, context.temp_allocator)
	if err != nil {
		fmt.eprintln("failed to read file: ", filepath)
		return mesh, false
	}

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		trimmed := strings.trim_space(line)
		if len(trimmed) == 0 || trimmed[0] == '#' {
			continue // skipping empty lines and commments
		}

		// split lines into tokes by whitespace
		tokens := strings.fields(trimmed, context.temp_allocator)
		if len(tokens) == 0 do continue

		// match tokens and fill mesh
		switch tokens[0] {
		case "v":
			x, _ := strconv.parse_f32(tokens[1])
			y, _ := strconv.parse_f32(tokens[2])
			z, _ := strconv.parse_f32(tokens[3])
			mesh_add_vertex(&mesh, {x, y, z})
		case "f":
			// OBJ indices are 1-based, convert to 0-based
			v0 := parse_face_index(tokens[1]) - 1
			v1 := parse_face_index(tokens[2]) - 1
			v2 := parse_face_index(tokens[3]) - 1
			mesh_add_face(&mesh, {v0, v1, v2})
		}
	}

	return mesh, true
}

// Helper to handle face formats like "v", "v/vt", or "v/vt/vn"
// Example for v/vt/vn: f 1301/1411/1301 1350/1402/1350 1351/1413/1351
parse_face_index :: proc(token: string) -> uint {
	parts := strings.split(token, "/", context.temp_allocator)
	val, _ := strconv.parse_uint(parts[0])
	return val
}

// NOTE: using a callback to give a abstraction for doing work on a file on a line by line basis.
// Another option would be to use a custom iterator. This would be a little more complex to setup for me now.
// Will need to look into pros and cons of callback vs. custom iterator

// on benefitof  a custom iterator would be the usage of it. With a custom iterator you can simply loop,
// which might be more natural to use

// can not even use this callback approach for loading an obj and writing into a mesh data structure,
// because of closures. Would need to pass user data to the callback as a rawptr
do_work_for_line_in_file :: proc(filepath: string, worker: proc(line: string)) {
	data, err := os.read_entire_file_from_path(filepath, context.temp_allocator)
	if err != nil do return
	defer delete(data, context.temp_allocator)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		worker(line)
	}
}
