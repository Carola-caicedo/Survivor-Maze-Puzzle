extends Node

var sfx_curar = preload("res://sonidos/curar.ogg")
var sfx_derrota = preload("res://sonidos/derrota.ogg")
var sfx_llave = preload("res://sonidos/llave.ogg")
var sfx_musica = preload("res://sonidos/musica.ogg")
var sfx_paso = preload("res://sonidos/paso.ogg")
var sfx_respawn = preload("res://sonidos/respawn.ogg")
var sfx_victoria = preload("res://sonidos/victoria.ogg")

var repro_musica: AudioStreamPlayer
var repro_paso: AudioStreamPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	repro_musica = AudioStreamPlayer.new()
	repro_musica.stream = sfx_musica
	repro_musica.volume_db = -8.0
	add_child(repro_musica)

	repro_paso = AudioStreamPlayer.new()
	repro_paso.stream = sfx_paso
	repro_paso.volume_db = -6.0
	add_child(repro_paso)

	play_musica()

func play_musica():
	if repro_musica != null and not repro_musica.playing:
		repro_musica.play()

func stop_musica():
	if repro_musica != null and repro_musica.playing:
		repro_musica.stop()

func play_paso():
	if repro_paso != null and not repro_paso.playing:
		repro_paso.play()

func play_curar():
	_reproducir(sfx_curar)

func play_llave():
	_reproducir(sfx_llave)

func play_respawn():
	_reproducir(sfx_respawn)

func play_victoria():
	_reproducir(sfx_victoria)

func play_derrota():
	_reproducir(sfx_derrota)

func _reproducir(stream: AudioStream):
	if stream == null:
		return
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
