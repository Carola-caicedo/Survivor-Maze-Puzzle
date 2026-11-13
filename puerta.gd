extends Node3D

@export var es_entrada: bool = false
@export var enemigo: Node3D = null

@onready var malla: MeshInstance3D = $MeshInstance3D
@onready var colision: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var sensor: Area3D = $Sensor
@onready var efectos: ControlEfectos = $MeshInstance3D/ControlEfectos

var tiene_enemigo: bool = false
var pos_enemigo: Vector3 = Vector3.ZERO
var distancia_al_enemigo: float = 0.0
var sellada: bool = false
var ya_abierta: bool = false

func _ready() -> void:
	tiene_enemigo = (enemigo != null)
	if tiene_enemigo:
		pos_enemigo = enemigo.global_position
		distancia_al_enemigo = global_position.distance_to(pos_enemigo)

	sensor.body_exited.connect(_on_sensor_body_exited)

	if es_entrada:
		# La puerta de entrada empieza abierta para que el jugador pueda entrar al cuarto
		malla.visible = false
		colision.set_deferred("disabled", true)
	else:
		# La puerta de salida empieza cerrada bloqueando el paso
		malla.visible = true
		colision.set_deferred("disabled", false)

func _process(_delta: float) -> void:
	# Cuando el enemigo asignado es derrotado (liberado con queue_free)
	if tiene_enemigo and not ya_abierta and not is_instance_valid(enemigo):
		abrir_puerta()

func _on_sensor_body_exited(cuerpo: Node3D) -> void:
	if not cuerpo.is_in_group("jugador") or sellada:
		return

	# Si es puerta de entrada, verificamos si el jugador cruzó hacia adentro del cuarto
	if es_entrada:
		var d_jugador = cuerpo.global_position.distance_to(pos_enemigo)
		if d_jugador < distancia_al_enemigo:
			sellar_puerta()

func sellar_puerta() -> void:
	sellada = true
	malla.visible = true
	colision.set_deferred("disabled", false)
	if efectos != null:
		efectos.golpe()
	print(name, ": cuarto sellado tras entrar el jugador")

func abrir_puerta() -> void:
	ya_abierta = true
	colision.set_deferred("disabled", true)
	if efectos != null:
		efectos.disolver()
	print(name, ": puerta desbloqueada tras derrotar al enemigo")
