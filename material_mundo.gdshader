shader_type spatial;

uniform vec3 color_bajo : source_color = vec3(0.172, 0.184, 0.200); // #2C2F33

uniform float amplitud = 0.06;
uniform float longitud = 1.0;
uniform float periodo  = 2.0;

float onda(float x, float t, float a, float l, float p) {
	return a * sin(TAU / l * x - TAU / p * t);
}

float pendiente(float x, float t, float a, float l, float p) {
	return a * (TAU / l) * cos(TAU / l * x - TAU / p * t);
}

void vertex() {
	float h = onda(VERTEX.x, TIME, amplitud, longitud, periodo);
	VERTEX.y += h;
	
	float s = pendiente(VERTEX.x, TIME, amplitud, longitud, periodo);
	NORMAL = normalize(vec3(-s, 1.0, 0.0));
}

void fragment() {
	ALBEDO = color_bajo;
	ROUGHNESS = 0.4;
}
