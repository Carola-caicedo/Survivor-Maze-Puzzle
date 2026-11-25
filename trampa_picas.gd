class_name TrampaPicas
extends Node3D

enum Estado { REPOSO, ANTICIPACION, ACTIVO, RETRACCION }

@export_group("Tiempos")
@export var tiempo_reposo: float = 1.0
@export var tiempo_anticipacion: float = 0.6
@export var tiempo_activo: float = 1.8
@export var tiempo_retraccion: float = 0.35
@export var desfase_inicial: float = 0.0

@export_group("Combate")
@export var danio: int = 100

@export_group("Audio")
@export var sonido_aviso: AudioStream = null
@export var sonido_disparo: AudioStream = null

@onready var lanzas: Node3D = $Lanzas
@onready var area_peligro: Area3D = $AreaPeligro
@onready var colision_peligro: CollisionShape3D = $AreaPeligro/CollisionShape3D
@onready var audio: AudioStreamPlayer3D = $AudioPeligro

const Y_OCULTO: float = -1.7
const Y_ANTICIPACION: float = -1.3
const Y_ACTIVO: float = 0.0

var estado: Estado = Estado.REPOSO
var temporizador: float = 0.0
var reloj_dano: float = 0.0
var tween_movimiento: Tween = null


func _ready() -> void:
	lanzas.position.y = Y_OCULTO
	colision_peligro.set_deferred("disabled", true)
	area_peligro.body_entered.connect(_al_entrar_cuerpo)

	temporizador = tiempo_reposo + desfase_inicial
	estado = Estado.REPOSO


func _physics_process(delta: float) -> void:
	temporizador -= delta

	if estado == Estado.ACTIVO:
		reloj_dano -= delta
		if reloj_dano <= 0.0:
			_daniar_cuerpos_en_area()
			reloj_dano = 0.5

	if estado == Estado.ANTICIPACION:
		var temblor = (randf() - 0.5) * 0.03
		lanzas.position.x = temblor
		lanzas.position.z = temblor
	else:
		lanzas.position.x = 0.0
		lanzas.position.z = 0.0

	if temporizador <= 0.0:
		_avanzar_fase()


func _avanzar_fase() -> void:
	match estado:
		Estado.REPOSO:
			_entrar_anticipacion()
		Estado.ANTICIPACION:
			_entrar_activo()
		Estado.ACTIVO:
			_entrar_retraccion()
		Estado.RETRACCION:
			_entrar_reposo()


func _entrar_reposo() -> void:
	estado = Estado.REPOSO
	temporizador = tiempo_reposo
	colision_peligro.set_deferred("disabled", true)
	_animar_altura(Y_OCULTO, 0.1, Tween.TRANS_SINE, Tween.EASE_IN)


func _entrar_anticipacion() -> void:
	estado = Estado.ANTICIPACION
	temporizador = tiempo_anticipacion
	colision_peligro.set_deferred("disabled", true)
	_reproducir_sonido(sonido_aviso)
	_animar_altura(Y_ANTICIPACION, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)


func _entrar_activo() -> void:
	estado = Estado.ACTIVO
	temporizador = tiempo_activo
	reloj_dano = 0.5
	colision_peligro.set_deferred("disabled", false)
	_reproducir_sonido(sonido_disparo)
	_animar_altura(Y_ACTIVO, 0.08, Tween.TRANS_BACK, Tween.EASE_OUT)
	_daniar_cuerpos_en_area()


func _entrar_retraccion() -> void:
	estado = Estado.RETRACCION
	temporizador = tiempo_retraccion
	colision_peligro.set_deferred("disabled", true)
	_animar_altura(Y_OCULTO, tiempo_retraccion, Tween.TRANS_QUAD, Tween.EASE_IN)


func _animar_altura(y_objetivo: float, duracion: float, trans: Tween.TransitionType, ease_tipo: Tween.EaseType) -> void:
	if tween_movimiento != null and tween_movimiento.is_valid():
		tween_movimiento.kill()
	tween_movimiento = create_tween()
	tween_movimiento.tween_property(lanzas, "position:y", y_objetivo, duracion).set_trans(trans).set_ease(ease_tipo)


func _al_entrar_cuerpo(cuerpo: Node3D) -> void:
	if estado == Estado.ACTIVO:
		_aplicar_danio(cuerpo)


func _daniar_cuerpos_en_area() -> void:
	for cuerpo in area_peligro.get_overlapping_bodies():
		_aplicar_danio(cuerpo)


func _aplicar_danio(cuerpo: Node3D) -> void:
	if not cuerpo.is_in_group("jugador"):
		return
	var salud = cuerpo.get_node_or_null("Salud")
	if salud != null and salud.has_method("recibir_golpe"):
		salud.recibir_golpe(danio)


func _reproducir_sonido(stream: AudioStream) -> void:
	if audio == null:
		return
	if stream != null:
		audio.stream = stream
		audio.play()
