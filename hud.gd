extends CanvasLayer

@onready var texto = $Texto
@onready var label_vida = $Margen/Arriba/Izquierda/Vida
@onready var label_vidas = $Margen/Arriba/Izquierda/Vidas
@onready var label_tiempo = $Margen/Arriba/Centro/Tiempo
@onready var label_enemigo = $Margen/Arriba/Centro/Enemigo
@onready var label_llaves = $Margen/Arriba/Derecha/Llaves
@onready var label_salida = $Margen/Arriba/Derecha/Salida
@onready var label_intentos = $Margen/Arriba/Derecha/Intentos
@onready var label_interaccion = $Margen/Abajo/Interaccion
@onready var centro_mensaje = $Margen/CentroMensaje
@onready var label_titulo = $Margen/CentroMensaje/Titulo
@onready var label_detalle = $Margen/CentroMensaje/Detalle
@onready var label_subdetalle = $Margen/CentroMensaje/Subdetalle

var jugador: CharacterBody3D = null
var salud: Node = null
var interactuar: Node = null
var partida: Node = null
var total_llaves = 3

func _ready():
	jugador = get_tree().get_first_node_in_group("jugador") as CharacterBody3D
	if jugador != null:
		if jugador.has_node("Salud"):
			salud = jugador.get_node("Salud")
			salud.cambio.connect(mostrar)
			mostrar(salud.vida)
		if jugador.has_node("Interactuar"):
			interactuar = jugador.get_node("Interactuar")

	partida = get_tree().get_first_node_in_group("partida")
	if partida != null and partida.has_signal("fin_partida"):
		partida.fin_partida.connect(_al_terminar_partida)

	var objs = get_tree().get_nodes_in_group("objetivos")
	if objs.size() > 0:
		total_llaves = objs.size()

	var clase_partida = load("res://partida.gd")
	if clase_partida != null and "intentos" in clase_partida:
		label_intentos.text = "Intento: " + str(clase_partida.intentos)

func _process(_delta):
	actualizar_tiempo()
	actualizar_objetivos()
	actualizar_enemigo()
	actualizar_interaccion()
	verificar_fin_partida()

func mostrar(vida):
	texto.text = "Vida: " + str(vida)
	label_vida.text = "Vida: " + str(vida)
	if salud != null and "reapariciones" in salud:
		label_vidas.text = "Vidas: " + str(salud.reapariciones + 1)

func actualizar_tiempo():
	if partida == null:
		partida = get_tree().get_first_node_in_group("partida")
	if partida != null and "tiempo" in partida:
		var t = maxf(partida.tiempo, 0.0)
		var min = int(t) / 60
		var sec = int(t) % 60
		label_tiempo.text = "Tiempo: %02d:%02d" % [min, sec]

func actualizar_objetivos():
	var restantes = get_tree().get_nodes_in_group("objetivos").size()
	var recogidas = clampi(total_llaves - restantes, 0, total_llaves)
	label_llaves.text = "Llaves: " + str(recogidas) + " / " + str(total_llaves)
	if restantes == 0:
		label_salida.text = "Salida: Abierta"
	else:
		label_salida.text = "Salida: Cerrada"

func actualizar_enemigo():
	var enemigo_cerca: Node3D = null
	var menor_dist = 14.0

	for ene in get_tree().get_nodes_in_group("enemigos"):
		if not is_instance_valid(ene):
			continue
		var dist = 999.0
		if jugador != null and is_instance_valid(jugador):
			dist = jugador.global_position.distance_to(ene.global_position)
		var alerta = ("estado" in ene) and (ene.estado != 0 and ene.estado != 1)
		if (dist <= menor_dist or alerta) and dist < 16.0:
			enemigo_cerca = ene
			menor_dist = dist
			break

	if enemigo_cerca != null and "vida" in enemigo_cerca and enemigo_cerca.vida > 0.0:
		label_enemigo.visible = true
		label_enemigo.text = str(enemigo_cerca.name) + ": " + str(int(enemigo_cerca.vida))
	else:
		label_enemigo.visible = false

func actualizar_interaccion():
	if interactuar != null and "progreso" in interactuar and interactuar.progreso > 0.01:
		label_interaccion.visible = true
		var pct = int(clampf(interactuar.progreso, 0.0, 1.0) * 100.0)
		label_interaccion.text = "Comiendo fruta... " + str(pct) + "%"
	else:
		label_interaccion.visible = false

func verificar_fin_partida():
	if partida != null and "estado" in partida and partida.estado != 0 and not centro_mensaje.visible:
		var motivo = partida.motivo_fin if "motivo_fin" in partida else ""
		_al_terminar_partida(partida.estado == 1, motivo)

func _al_terminar_partida(gano: bool, motivo: String):
	centro_mensaje.visible = true
	if gano:
		label_titulo.text = "VICTORIA"
		var t = maxf(partida.tiempo_limite - partida.tiempo, 0.0) if partida != null else 0.0
		var min = int(t) / 60
		var sec = int(t) % 60
		label_detalle.text = "Completado en %02d:%02d" % [min, sec]
	else:
		label_titulo.text = "DERROTA"
		if motivo == "sin vida":
			label_detalle.text = "Te quedaste sin vidas"
		elif motivo == "se acabó el tiempo":
			label_detalle.text = "Se acabo el tiempo"
		else:
			label_detalle.text = "Fin de la partida"
	label_subdetalle.text = "Reiniciando..."
