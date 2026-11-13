class_name Toon
extends RefCounted

static func banda(nl: float, bandas: float) -> float:
	return floorf(maxf(nl, 0.0) * bandas) / bandas

static func fresnel(nv: float, potencia: float) -> float:
	return pow(1.0 - clampf(nv, 0.0, 1.0), potencia)
