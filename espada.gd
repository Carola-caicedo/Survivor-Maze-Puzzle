extends Node

enum Estado { LISTA, ACTIVA, RECARGA }

@export var tecla = "espada"
@export var duracion = 0.3
@export var recarga = 0.5
@export var rapidez = 0.0
@export var multiplicador_activa = 0.0
@export var animacion = "attack-melee-right"
@export var dano = 25
@export var vida_enemigo = 100

@onready var pj = get_parent()
var estado = Estado.LISTA
var tiempo = 0.0
var vida_restante = 0


func _ready():
	vida_restante = vida_enemigo
	var golpes = ceili(float(vida_enemigo) / dano)
	print("espada: daño ", dano, " · ", golpes, " golpes vencen ", vida_enemigo,
		" HP · tiempo mínimo ", snappedf(golpes * duracion + (golpes - 1) * recarga, 0.01), " s")


func _physics_process(delta):
	tiempo -= delta
	match estado:
		Estado.LISTA:
			if Input.is_action_just_pressed(tecla) and puede():
				empezar()
		Estado.ACTIVA:
			if tiempo <= 0.001:	# 0.001 y no 0: restar 1/60 no da exacto
				terminar()
		Estado.RECARGA:
			if tiempo <= 0.001:
				estado = Estado.LISTA


# La regla: solo se golpea con los pies en el suelo
func puede():
	return pj.is_on_floor()


func empezar():
	estado = Estado.ACTIVA
	tiempo = duracion
	# -basis.z = hacia donde mira el Personaje
	pj.empuje = -pj.basis.z * rapidez
	pj.multiplicador = multiplicador_activa
	pj.accion = animacion
	vida_restante -= dano
	print("empieza: ", tecla, " · daño ", dano, " · vida del enemigo ", max(vida_restante, 0))
	if vida_restante <= 0:
		print("enemigo vencido")
		vida_restante = vida_enemigo


func terminar():
	estado = Estado.RECARGA
	tiempo = recarga
	pj.empuje = Vector3.ZERO
	pj.multiplicador = 1.0
	pj.accion = ""
	print("termina: ", tecla)
