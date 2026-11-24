extends Node
## Pone una espada visible en la mano derecha del "Modelo" del nodo padre
## (sirve para el Personaje y para el Guardian). La espada va pegada a un hueso,
## así que sigue todas las animaciones, incluida la de ataque.

@export var hueso = "arm-right"
@export var escena: PackedScene = preload("res://espada_modelo.tscn")
@export var color_hoja = Color(0.82, 0.86, 0.9)
# Ajustes finos (en el espacio del hueso del brazo). Si la espada se ve movida,
# cambien estos tres valores en el Inspector.
@export var posicion = Vector3(-0.26, 0.0, 0.05)
@export var rotacion_grados = Vector3(0.0, 30.0, 0.0)
@export var escala = 2.0


func _ready():
	var modelo = get_parent().get_node_or_null("Modelo")
	if modelo == null:
		modelo = get_parent().get_node_or_null("modelo")
	if modelo == null:
		push_warning("EspadaEnMano: no encuentro el nodo 'Modelo' en " + str(get_parent().name))
		return

	var esqueletos = modelo.find_children("*", "Skeleton3D", true, false)
	if esqueletos.is_empty():
		push_warning("EspadaEnMano: el modelo no tiene Skeleton3D")
		return
	var esqueleto: Skeleton3D = esqueletos[0]

	var nombre = hueso
	if esqueleto.find_bone(nombre) == -1:
		nombre = _hueso_parecido(esqueleto)
	if nombre == "":
		push_warning("EspadaEnMano: no encuentro el hueso '" + hueso + "'")
		return

	var mano = BoneAttachment3D.new()
	mano.name = "ManoEspada"
	mano.bone_name = nombre
	esqueleto.add_child(mano)

	var espada = escena.instantiate()
	espada.position = posicion
	espada.rotation_degrees = rotacion_grados
	espada.scale = Vector3.ONE * escala
	mano.add_child(espada)

	# Cada espada puede tener su propio color de hoja
	var hoja = espada.get_node_or_null("Hoja")
	if hoja is MeshInstance3D:
		var mat = hoja.get_active_material(0)
		if mat is StandardMaterial3D:
			mat = mat.duplicate()
			mat.albedo_color = color_hoja
			hoja.material_override = mat


func _hueso_parecido(esqueleto: Skeleton3D) -> String:
	for i in esqueleto.get_bone_count():
		var n = esqueleto.get_bone_name(i).to_lower()
		if n.contains("arm") and n.contains("right"):
			return esqueleto.get_bone_name(i)
	return ""
