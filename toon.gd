class_name Toon
extends RefCounted

static func banda(nl: float, bandas: float) -> float:
	return floorf(maxf(nl, 0.0) * bandas) / bandas
