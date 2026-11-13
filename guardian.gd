extends CharacterBody3D

enum Estado { PATRULLAR, ESPERAR, PERSEGUIR, AVISO, GOLPE, RECARGA, BUSCAR, HUIR }

@export var rapidez = 2.0
@export var espera = 1.0
@export var ruta: Array[Vector3] = [Vector3.ZERO, Vector3(0, 0, -6)]

@export var rango_vision = 7.0

@export var rango_perder = 10.0
@export var tiempo_busqueda = 3.0

@export var rango_ataque = 1.2
@export var tiempo_aviso = 1.0
@export var tiempo_recarga = 1.0
@export var alcance_golpe = 1.6
@export var danio = 15

@export var vida = 100.0
@export var vida_huida = 30.0
@export var danio_prueba = 25.0

@export var objetivo: Node3D = null

var estado = Estado.PATRULLAR
var puntos: Array[Vector3] = []
var indice = 0
var reloj = 0.0
var busca = 0.0
var ultimo_visto = Vector3.ZERO
var jugador: Node3D = null

@onready var anim: AnimationPlayer = _buscar_anim()
@onready var vision: RayCast3D = $Vision if has_node("Vision") else null


func _buscar_anim() -> AnimationPlayer:
	if has_node("Modelo/AnimationPlayer"):
		return get_node("Modelo/AnimationPlayer")
	elif has_node("modelo/AnimationPlayer"):
		return get_node("modelo/AnimationPlayer")
	var encontrados = find_children("*", "AnimationPlayer", true, false)
	if encontrados.size() > 0:
		return encontrados[0]
	return null


func _ready():
	puntos.clear()
	for d in ruta:
		puntos.append(global_position + d)

	if objetivo != null:
		jugador = objetivo
	else:
		jugador = get_tree().get_first_node_in_group("jugador")


func _physics_process(delta):
	velocity += get_gravity() * delta
	reloj = maxf(reloj - delta, 0.0)
	busca = maxf(busca - delta, 0.0)

	if Input.is_action_just_pressed("ui_accept"):
		recibir_golpe(danio_prueba)

	var d = distancia()
	var ve = lo_ve()
	if ve and jugador != null:
		ultimo_visto = jugador.global_position

	var nuevo = decidir(d, ve)
	if nuevo != estado:
		cambiar_a(nuevo, d)

	match estado:
		Estado.PATRULLAR:
			patrullar()

		Estado.ESPERAR:
			frenar("idle")

		Estado.PERSEGUIR:
			if jugador != null:
				ir_a(jugador.global_position)
			else:
				frenar("idle")

		Estado.AVISO:
			frenar("interact-right")

		Estado.GOLPE:
			frenar("attack-melee-right")
			golpear()

		Estado.RECARGA:
			frenar("idle")

		Estado.BUSCAR:
			if distancia_a(ultimo_visto) > 0.1:
				ir_a(ultimo_visto)
			else:
				frenar("idle")

		Estado.HUIR:
			if jugador != null:
				var lejos = global_position - jugador.global_position
				lejos.y = 0.0
				ir_a(global_position + lejos)
			else:
				frenar("idle")

	move_and_slide()


func decidir(d: float, ve: bool) -> Estado:
	if vida <= vida_huida and vida > 0.0:
		return Estado.HUIR

	var alerta = estado == Estado.PERSEGUIR or estado == Estado.AVISO or estado == Estado.GOLPE or estado == Estado.RECARGA
	var limite = rango_perder if alerta else rango_vision

	if estado == Estado.AVISO:
		if reloj <= 0.001:
			return Estado.GOLPE
		return Estado.AVISO

	if estado == Estado.GOLPE:
		return Estado.RECARGA

	if estado == Estado.RECARGA:
		if reloj <= 0.001:
			if ve and d <= rango_ataque:
				return Estado.AVISO
			elif ve and d <= limite:
				return Estado.PERSEGUIR
			elif alerta:
				busca = tiempo_busqueda
				return Estado.BUSCAR
		return Estado.RECARGA

	if ve and d <= rango_ataque:
		return Estado.AVISO

	if ve and d <= limite:
		return Estado.PERSEGUIR

	if alerta:
		busca = tiempo_busqueda
		return Estado.BUSCAR

	if busca > 0.001:
		return Estado.BUSCAR

	if reloj > 0.001:
		return Estado.ESPERAR

	return Estado.PATRULLAR


func lo_ve() -> bool:
	if jugador == null:
		return false
	if vision == null:
		return true

	var pecho = jugador.global_position + Vector3(0, 0.9, 0)
	vision.target_position = vision.to_local(pecho)
	vision.force_raycast_update()

	if vision.is_colliding():
		return vision.get_collider() == jugador
	return true


func cambiar_a(nuevo: Estado, d: float = -1.0):
	estado = nuevo
	var dist_str = (" a " + str(snappedf(d, 0.01)) + " m") if d >= 0.0 else (" en " + str(global_position.snappedf(0.01)))
	print(name, " -> ", Estado.keys()[estado], " cuadro ",
		Engine.get_physics_frames(), dist_str)

	if estado == Estado.AVISO:
		reloj = tiempo_aviso
	elif estado == Estado.RECARGA:
		reloj = tiempo_recarga


func patrullar():
	if puntos.is_empty():
		frenar("idle")
		return

	var destino = puntos[indice]
	if distancia_a(destino) < 0.1:
		indice = (indice + 1) % puntos.size()
		reloj = espera
		frenar("idle")
		return

	ir_a(destino)


func golpear():
	if distancia() > alcance_golpe:
		print(name, " falla a ", snappedf(distancia(), 0.01), " m")
		return

	if jugador != null:
		var salud = jugador.get_node_or_null("Salud")
		if salud != null:
			salud.recibir_golpe(danio)


func recibir_golpe(cuanto):
	vida -= cuanto
	print(name, " vida ", vida)
	if vida <= 0.0:
		print(name, " vencido")
		queue_free()


func ir_a(destino: Vector3):
	var hacia = destino - global_position
	hacia.y = 0.0
	if hacia.length() < 0.05:
		velocity.x = 0.0
		velocity.z = 0.0
		reproducir_anim("idle")
		return
	var dir = hacia.normalized()
	velocity.x = dir.x * rapidez
	velocity.z = dir.z * rapidez
	basis = Basis.looking_at(dir)
	reproducir_anim("walk")


func frenar(animacion: String = "idle"):
	velocity.x = 0.0
	velocity.z = 0.0
	reproducir_anim(animacion)


func reproducir_anim(nombre: String):
	if anim != null and anim.has_animation(nombre):
		anim.play(nombre)


func distancia_a(p: Vector3) -> float:
	var o = global_position
	return Vector2(p.x - o.x, p.z - o.z).length()


func distancia() -> float:
	if jugador == null:
		return 999.0
	return distancia_a(jugador.global_position)
