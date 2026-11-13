extends CanvasLayer

@onready var texto = $Texto

func _ready():
	var pj = get_tree().get_first_node_in_group("jugador")
	if pj != null and pj.has_node("Salud"):
		var salud = pj.get_node("Salud")
		salud.cambio.connect(mostrar)
		mostrar(salud.vida)

func mostrar(vida):
	texto.text = "Vida: " + str(vida)
	print("HUD -> ", texto.text)
