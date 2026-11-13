extends Area3D


func _ready():
	body_entered.connect(_al_entrar)


func _al_entrar(cuerpo):
	if not cuerpo.is_in_group("jugador"):
		return
	
	var faltan = get_tree().get_nodes_in_group("objetivos").size()
	if faltan > 0:
		print("salida cerrada: faltan ", faltan)
		return
	print("salida abierta cuadro ", Engine.get_physics_frames())
	var partida = get_tree().get_first_node_in_group("partida")
	if partida != null:
		partida.ganar()
