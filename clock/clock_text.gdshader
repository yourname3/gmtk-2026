shader_type canvas_item;

uniform float t = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(UV.y > t) {
		discard;
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
