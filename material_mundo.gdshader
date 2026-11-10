shader_type spatial;

uniform vec3 color_bajo : source_color = vec3(0.172, 0.184, 0.200); 
uniform vec3 color_bajo : source_color = vec3(0.172, 0.184, 0.200);
uniform vec3 color_alto : source_color = vec3(0.180, 0.800, 0.443);

uniform float amplitud = 0.06;
uniform float longitud = 1.0;
uniform float periodo  = 2.0;

uniform float amplitud2 = 0.02;
uniform float longitud2 = 0.7;
uniform float periodo2  = 1.3;

varying float altura;

float onda(float x, float t, float a, float l, float p) {
	return a * sin(TAU / l * x - TAU / p * t);
}

float pendiente(float x, float t, float a, float l, float p) {
	return a * (TAU / l) * cos(TAU / l * x - TAU / p * t);
}

void vertex() {
	float h = onda(VERTEX.x, TIME, amplitud, longitud, periodo);
	float h = onda(VERTEX.x, TIME, amplitud, longitud, periodo)
	        + onda(VERTEX.x, TIME, amplitud2, longitud2, periodo2);

	float s = pendiente(VERTEX.x, TIME, amplitud, longitud, periodo)
	        + pendiente(VERTEX.x, TIME, amplitud2, longitud2, periodo2);

	VERTEX.y += h;
	
	float s = pendiente(VERTEX.x, TIME, amplitud, longitud, periodo);
	NORMAL = normalize(vec3(-s, 1.0, 0.0));

	altura = h;
}

void fragment() {
	ALBEDO = color_bajo;
	float a_total = amplitud + amplitud2;
	float m = clamp(altura / (2.0 * a_total) + 0.5, 0.0, 1.0);

	ALBEDO = mix(color_bajo, color_alto, m);
	ROUGHNESS = 0.4;
}
