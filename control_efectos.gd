class_name ControlEfectos
extends Node

@export var objetivo: GeometryInstance3D
@export var tecla := KEY_F
@export var radio := 3.0           # m: hasta dónde lo alcanza un evento
@export var dura_flash := 0.5      # s: lo que se nota el destello
@export var dura_dissolve := 1.0    # s: cuánto tarda en desaparecer

var mat: ShaderMaterial
var flash := 0.0
var avance := 0.0
var disolviendo := false

func _ready() -> void:
	# Copia independiente: cada objeto tiene su propio material
	mat = objetivo.material_override.duplicate()
	objetivo.material_override = mat
	
	# Conectarse a todos los disparadores del grupo
	for d in get_tree().get_nodes_in_group("disparadores"):
		d.evento.connect(_on_evento)

func _process(delta: float) -> void:
	if Input.is_physical_key_pressed(tecla):
		golpe()
	# Decaimiento del flash
	flash = decaer(flash, 0.0, k_para(dura_flash), delta)
	mat.set_shader_parameter("flash", flash)
	
	# Dissolve progresivo
	if disolviendo:
		avance = avance_en(avance, delta, dura_dissolve)
		mat.set_shader_parameter("avance", avance_visible(avance))
		if avance >= 1.0:
			objetivo.visible = false
			disolviendo = false

func disolver() -> void:
	disolviendo = true

func golpe() -> void:
	flash = 1.0

func _on_evento(posicion: Vector3) -> void:
	if objetivo.global_position.distance_to(posicion) <= radio:
		golpe()

static func mezclar(base: Color, color_flash: Color, t: float) -> Color:
	return base + (color_flash - base) * t

static func decaer(actual: float, base: float, k: float, dt: float) -> float: 
	return actual + (base - actual) * (1.0 - exp(-k * dt))

static func k_para(duracion: float) -> float:
	return 3.0 / duracion

static func avance_en(actual: float, dt: float, duracion: float) -> float:
	return minf(1.0, actual + dt / duracion)

static func avance_visible(a: float) -> float:
	return lerpf(0.2, 0.8, a)   # el tramo donde sí se ve desaparecer
