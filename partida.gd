extends Node

enum Estado { JUGANDO, GANO, PERDIO }

@export var tiempo_limite = 30.0
# false: al acabarse el tiempo se pierde. true: sobrevivir gana.
@export var gana_con_tiempo = false

var estado = Estado.JUGANDO
var tiempo = 0.0

func _ready():
	add_to_group("partida")
	tiempo = tiempo_limite

func _physics_process(delta):
	# Guarda: si la partida ya terminó, no descuenta más tiempo
	if estado != Estado.JUGANDO:
		return
	tiempo = maxf(tiempo - delta, 0.0)
	if tiempo <= 0.001:
		if gana_con_tiempo:
			ganar()
		else:
			perder("se acabó el tiempo")

func ganar():
	terminar(Estado.GANO, "ganó")

func perder(motivo: String):
	terminar(Estado.PERDIO, motivo)

# La guarda: la partida termina una sola vez.
func terminar(nuevo: Estado, motivo: String):
	if estado != Estado.JUGANDO:
		return
	estado = nuevo
	print("fin: ", Estado.keys()[estado], " cuadro ", Engine.get_physics_frames(), " (", motivo, ")")
