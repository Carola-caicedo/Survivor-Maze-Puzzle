extends Node3D

func _ready() -> void:
	print(Toon.fresnel(1.0, 3.0), " ", Toon.fresnel(0.866, 3.0), " ", Toon.fresnel(0.5, 3.0))
