class_name ControlEfectos
extends Node

@export var objetivo: GeometryInstance3D
@export var tecla := KEY_F       # para probar sin la mecánica

var mat: ShaderMaterial
var flash := 0.0

func _ready() -> void:
	mat = objetivo.material_override

func _process(delta: float) -> void:
	if Input.is_physical_key_pressed(tecla):
		print(ControlEfectos.mezclar(Color(0.8, 0.2, 0.1), Color.WHITE,0.25))
		golpe()
	mat.set_shader_parameter("flash", flash)

func golpe() -> void:
	flash = 1.0

static func mezclar(base: Color, color_flash: Color, t: float) -> Color:
	return base + (color_flash - base) * t
