shader_type spatial;

uniform vec3 color_base : source_color = vec3(0.7, 0.45, 0.25);
uniform vec3 color_flash : source_color = vec3(1.0, 1.0, 1.0);
uniform float flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    ALBEDO = mix(color_base, color_flash, flash);
    EMISSION = color_flash * flash;
}