extends CharacterBody3D

enum Estado { PATRULLA, ACERCARSE, AVISO, GOLPE, RECARGA, HUIR }

# Configuración de patrulla y visión (Taller 7)
@export var rapidez = 2.0
@export var radio_ver = 6.0
@export var radio_perder = 9.0
@export var puntos: Array[Vector3] = [
	Vector3(-6, 0, -3),
	Vector3(6, 0, -3)
]

# Configuración de combate (Taller 9)
@export var rango_ataque = 1.5
@export var tiempo_aviso = 1.0
@export var tiempo_recarga = 1.0
@export var alcance_golpe = 1.6
@export var danio = 15

# Vida y huida
@export var vida = 100.0
@export var vida_huida = 30.0
@export var danio_prueba = 25.0

@export var objetivo: Node3D = null

var estado = Estado.PATRULLA
var punto = 0
var reloj = 0.0
var jugador: Node3D = null

@onready var anim: AnimationPlayer = _buscar_anim()


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
	if objetivo != null:
		jugador = objetivo
	else:
		jugador = get_tree().get_first_node_in_group("jugador")


func _physics_process(delta):
	velocity += get_gravity() * delta
	reloj = maxf(reloj - delta, 0.0)

	# Tecla Enter para pruebas de daño al enemigo
	if Input.is_action_just_pressed("ui_accept"):
		recibir_golpe(danio_prueba)

	var nuevo = decidir()
	if nuevo != estado:
		cambiar_a(nuevo)

	match estado:
		Estado.PATRULLA:
			if puntos.size() > 0:
				ir_a(puntos[punto])
				if global_position.distance_to(puntos[punto]) < 0.4:
					punto = (punto + 1) % puntos.size()
			else:
				frenar("idle")

		Estado.ACERCARSE:
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

		Estado.HUIR:
			if jugador != null:
				# Huir es alejarse en la dirección opuesta al jugador
				var lejos = global_position - jugador.global_position
				lejos.y = 0.0
				ir_a(global_position + lejos)
			else:
				frenar("idle")

	move_and_slide()


func decidir() -> Estado:
	# Huir tiene máxima prioridad si la vida está baja
	if vida <= vida_huida and vida > 0.0:
		return Estado.HUIR

	var d = distancia()

	match estado:
		Estado.PATRULLA:
			if jugador != null and d <= radio_ver:
				return Estado.ACERCARSE
			return Estado.PATRULLA

		Estado.ACERCARSE:
			if d > radio_perder:
				return Estado.PATRULLA
			if d <= rango_ataque:
				return Estado.AVISO
			return Estado.ACERCARSE

		Estado.AVISO:
			if reloj <= 0.001:
				return Estado.GOLPE
			return Estado.AVISO

		Estado.GOLPE:
			return Estado.RECARGA

		Estado.RECARGA:
			if reloj <= 0.001:
				if d <= rango_ataque:
					return Estado.AVISO
				elif d <= radio_perder:
					return Estado.ACERCARSE
				else:
					return Estado.PATRULLA
			return Estado.RECARGA

		Estado.HUIR:
			return Estado.HUIR

	return estado


func cambiar_a(nuevo: Estado):
	estado = nuevo
	print(name, " -> ", Estado.keys()[estado], " a ", snappedf(distancia(), 0.01), " m")
	if estado == Estado.AVISO:
		reloj = tiempo_aviso
	elif estado == Estado.RECARGA:
		reloj = tiempo_recarga


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


func distancia() -> float:
	if jugador == null:
		return 999.0
	var p = jugador.global_position
	var o = global_position
	return Vector2(p.x - o.x, p.z - o.z).length()
