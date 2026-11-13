extends Area3D

@onready var bloqueo: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var malla: MeshInstance3D = $MeshInstance3D

var abierta: bool = false

func _ready() -> void:
	body_entered.connect(_al_entrar)

func _process(_delta: float) -> void:
	if abierta:
		return
	
	var faltan = get_tree().get_nodes_in_group("objetivos").size()
	if faltan == 0:
		abrir()

func abrir() -> void:
	abierta = true
	if bloqueo != null:
		bloqueo.set_deferred("disabled", true)
	if malla != null:
		malla.visible = false
	print("¡Salida abierta! Se recogieron todas las llaves.")

	for cuerpo in get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			_al_entrar(cuerpo)

func _al_entrar(cuerpo: Node3D) -> void:
	if not cuerpo.is_in_group("jugador"):
		return
	
	var faltan = get_tree().get_nodes_in_group("objetivos").size()
	if faltan > 0:
		print("Salida cerrada: faltan ", faltan, " llaves")
		return
	
	print("Salida abierta cuadro ", Engine.get_physics_frames())
	var partida = get_tree().get_first_node_in_group("partida")
	if partida != null:
		partida.ganar()
