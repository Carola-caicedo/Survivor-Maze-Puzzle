shader_type spatial;
render_mode unshaded, cull_front;
uniform vec3 color_contorno : source_color = vec3(0.173, 0.184, 0.200); // #2C2F33 (Paredes)
uniform float grosor = 0.03;
void vertex() {
	VERTEX += NORMAL * grosor;
}
void fragment() {
	ALBEDO = color_contorno;
}