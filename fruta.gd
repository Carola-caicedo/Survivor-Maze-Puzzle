extends Node3D

@export var curacion = 30

func usar():
	print("Fruta consumida: cura +", curacion, " HP")
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador and jugador.has_node("Salud"):
		var salud = jugador.get_node("Salud")
		salud.curar(curacion)
	# Se retira del grupo para que el personaje no vuelva a detectarla
	remove_from_group("interactivos")
	queue_free()
