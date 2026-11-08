extends Area3D

@export var valor = 1


func _ready():
	add_to_group("objetivos")
	body_entered.connect(_al_entrar)


func _al_entrar(cuerpo):
	if not cuerpo.is_in_group("jugador"):
		return
	print(name, " recogido cuadro ", Engine.get_physics_frames())
	queue_free()
