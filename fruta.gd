extends Node3D

@export var curacion = 30

func usar():
	print("Fruta consumida: cura +", curacion, " HP")
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador and jugador.has_node("Salud"):
		var salud = jugador.get_node("Salud")
		salud.curar(curacion)
		salud.actualizar_checkpoint(jugador.global_position)
	if has_node("/root/Sonidos"):
		Sonidos.play_curar()
	_crear_texto_flotante()
	# Se retira del grupo para que el personaje no vuelva a detectarla
	remove_from_group("interactivos")
	queue_free()

func _crear_texto_flotante():
	var label = Label3D.new()
	label.text = "+" + str(curacion)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 48
	label.modulate = Color(0.2, 1.0, 0.4)
	label.global_position = global_position + Vector3(0, 1.2, 0)
	get_tree().current_scene.add_child(label)

	var tween = label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y + 1.2, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)
