extends Node3D

func _ready() -> void:
	print(Onda.k(4.0), " ", Onda.w(2.0), " ", Onda.altura(1.0, 0.0, 0.3, 4.0, 2.0), " ", Onda.altura(1.0, 0.5, 0.3, 4.0, 2.0))
