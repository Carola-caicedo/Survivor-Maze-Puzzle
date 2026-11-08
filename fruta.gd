extends Node3D

@export var curacion = 30

func usar():
	print("Fruta consumida: cura +", curacion, " HP")
	# Se retira del grupo para que el personaje no vuelva a detectarla
	remove_from_group("interactivos")
	visible = false
