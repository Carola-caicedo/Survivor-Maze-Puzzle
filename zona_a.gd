extends Node3D

@onready var area: Area3D = $Trampa

func _ready() -> void:
	if area != null:
		area.body_entered.connect(_al_entrar_trampa)

func _al_entrar_trampa(cuerpo: Node3D) -> void:
	if not cuerpo.is_in_group("jugador"):
		return

	print("¡El jugador cayó en la trampa de agua!")
	var salud = cuerpo.get_node_or_null("Salud")
	if salud != null:
		# Daño letal instantáneo
		salud.vida = 0
		salud.sin_vida.emit()
	else:
		var partida = get_tree().get_first_node_in_group("partida")
		if partida != null:
			partida.perder("caíste en el agua")
