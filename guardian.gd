extends CharacterBody3D

enum Estado { PATRULLA, PERSEGUIR }

@export var objetivo: Node3D
@export var rapidez = 2.0
@export var radio_ver = 6.0
@export var radio_perder = 9.0
@export var puntos: Array[Vector3] = [
	Vector3(-6, 0, -3),
	Vector3(6, 0, -3)
]

@onready var anim: AnimationPlayer = _buscar_anim()

var estado = Estado.PATRULLA
var punto = 0

func _buscar_anim() -> AnimationPlayer:
	if has_node("Modelo/AnimationPlayer"):
		return get_node("Modelo/AnimationPlayer")
	elif has_node("modelo/AnimationPlayer"):
		return get_node("modelo/AnimationPlayer")
	var encontrados = find_children("*", "AnimationPlayer", true, false)
	if encontrados.size() > 0:
		return encontrados[0]
	return null

func _physics_process(delta):
	velocity += get_gravity() * delta
	
	if objetivo == null:
		move_and_slide()
		return

	var distancia = global_position.distance_to(objetivo.global_position)

	match estado:
		Estado.PATRULLA:
			if distancia < radio_ver:
				estado = Estado.PERSEGUIR
				print("lo vio a ", snappedf(distancia, 0.01), " m")
			ir_a(puntos[punto])
			if global_position.distance_to(puntos[punto]) < 0.3:
				punto = (punto + 1) % puntos.size()

		Estado.PERSEGUIR:
			if distancia > radio_perder:
				estado = Estado.PATRULLA
				print("lo perdió a ", snappedf(distancia, 0.01), " m")
			ir_a(objetivo.global_position)

	move_and_slide()

func ir_a(p):
	var hacia = p - global_position
	hacia.y = 0.0
	if hacia.length() < 0.05:
		return
	var dir = hacia.normalized()
	velocity.x = dir.x * rapidez
	velocity.z = dir.z * rapidez
	basis = Basis.looking_at(dir)
	if anim != null and anim.has_animation("walk"):
		anim.play("walk")
