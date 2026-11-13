extends CharacterBody3D

enum Estado { ACERCARSE, AVISO, GOLPE, RECARGA, HUIR }

@export var rapidez = 2.0
@export var rango_ataque = 1.5
@export var tiempo_aviso = 1.0
@export var tiempo_recarga = 1.0

@export var alcance_golpe = 1.6
@export var danio = 15

@export var vida = 100.0
@export var vida_huida = 30.0
@export var danio_prueba = 25.0

var estado = Estado.ACERCARSE
var reloj = 0.0
var jugador = null

@onready var anim = $Modelo/AnimationPlayer


func _ready():
	jugador = get_tree().get_first_node_in_group("jugador")


func _physics_process(delta):
	velocity += get_gravity() * delta
	reloj = maxf(reloj - delta, 0.0)
	
	# Prueba: Enter le quita vida. Borren estas dos líneas al terminar.
	if Input.is_action_just_pressed("ui_accept"):
		recibir_golpe(danio_prueba)
	var nuevo = decidir()
	if nuevo != estado:
		cambiar_a(nuevo)
	
	match estado:
		Estado.ACERCARSE:
			if jugador != null:
				ir_a(jugador.global_position)
		Estado.AVISO:
			frenar("interact-right")
		Estado.GOLPE:
			frenar("attack-melee-right")
			golpear()
		Estado.RECARGA:
			frenar("idle")
		Estado.HUIR:
			if jugador != null:
				# Huir es perseguir con el vector director invertido
				var lejos = global_position - jugador.global_position
				lejos.y = 0.0
				ir_a(global_position + lejos)
	
	move_and_slide()

# Desde cada estado solo se puede pasar a uno: el ciclo del ataque.
func decidir():
	 # Va primero: le gana a cualquier estado, también al AVISO.
	if vida <= vida_huida and vida > 0.0:
		return Estado.HUIR
	
	match estado:
		Estado.ACERCARSE:
			if distancia() <= rango_ataque:
				return Estado.AVISO
		Estado.AVISO:
			if reloj <= 0.001:
				return Estado.GOLPE
		Estado.GOLPE:
			return Estado.RECARGA
		Estado.RECARGA:
			if reloj <= 0.001:
				return Estado.ACERCARSE
		Estado.HUIR:
			return Estado.HUIR
	return estado

# Se llama igual que en la diana del Taller 8: el rayo ya la sabe usar.
func recibir_golpe(cuanto):
	vida -= cuanto
	print(name, " vida ", vida)
	if vida <= 0.0:
		print(name, " vencido")
		queue_free()


func cambiar_a(nuevo):
	estado = nuevo
	print(name, " -> ", Estado.keys()[estado], " cuadro ",
		Engine.get_physics_frames(), " a ",
		snappedf(distancia(), 0.01), " m")
	if estado == Estado.AVISO:
		reloj = tiempo_aviso
	elif estado == Estado.RECARGA:
		reloj = tiempo_recarga

# El aviso le da tiempo al jugador: el golpe mira DÓNDE ESTÁ AHORA.
func golpear():
	if distancia() > alcance_golpe:
		print(name, " falla a ", snappedf(distancia(), 0.01), " m")
		return
	
	var salud = jugador.get_node_or_null("Salud")
	if salud != null:
		salud.recibir_golpe(danio)


func ir_a(destino):
	var hacia = destino - global_position
	hacia.y = 0.0
	var dir = hacia.normalized()
	velocity.x = dir.x * rapidez
	velocity.z = dir.z * rapidez
	if dir.length() > 0.001:
		basis = Basis.looking_at(dir)
	anim.play("walk")


func frenar(animacion):
	velocity.x = 0.0
	velocity.z = 0.0
	anim.play(animacion)


func distancia():
	if jugador == null:
		return 999.0
	var p = jugador.global_position
	var o = global_position
	return Vector2(p.x - o.x, p.z - o.z).length()
