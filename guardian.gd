extends CharacterBody3D

@export var objetivo: Node3D

@onready var anim: AnimationPlayer = _buscar_anim()

func _buscar_anim() -> AnimationPlayer:
	var encontrados = find_children("*", "AnimationPlayer", true, false)
	if encontrados.size() > 0:
		return encontrados[0]
	return null

func _ready() -> void:
	if anim == null:
		push_warning("guardian: no se encontró ningún AnimationPlayer")
	else:
		print("Animaciones disponibles: ", anim.get_animation_list())

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta

	if anim != null and anim.has_animation("idle"):
		if anim.current_animation != "idle":
			anim.play("idle")

	move_and_slide()

	if objetivo == null:
		return

	var hacia = objetivo.global_position - global_position
	hacia.y = 0.0

	if Engine.get_physics_frames() % 30 == 0:
		print("distancia ", snappedf(hacia.length(), 0.01))
