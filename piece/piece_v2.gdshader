shader_type canvas_item;

instance uniform vec4 line_colour : source_color = vec4(1.0); // default = white
instance uniform float line_thickness : hint_range(0, 0.1) = 0.04;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 test = texture(TEXTURE, UV);
	if(test.a > 0.0 && test.rgba != vec4(1.0)) {
		COLOR = line_colour;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
