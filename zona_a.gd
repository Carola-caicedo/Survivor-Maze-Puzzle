extends Node3D

func _ready() -> void:
	print(Onda.k(4.0), " ", Onda.w(2.0), " ", Onda.altura(1.0, 0.0, 0.3, 4.0, 2.0), " ", Onda.altura(1.0, 0.5, 0.3, 4.0, 2.0))
	print(Onda.pendiente(0.0, 0.0, 0.3, 4.0, 2.0), " ", Onda.normal(0.4712))
	print(Onda.mezcla_altura(0.0, 0.4), " ", Onda.mezcla_altura(0.4, 0.4), " ", Onda.mezcla_altura(0.2, 0.4))
