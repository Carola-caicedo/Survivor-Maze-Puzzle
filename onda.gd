class_name Onda
extends RefCounted

static func k(longitud: float) -> float:
	return TAU / longitud

# w: frecuencia angular. Dice cuántas vueltas completas (TAU) ocurren en un periodo.
# Si el periodo es 2 s, w = 3.1416. La onda se repite cada 2 segundos.
static func w(periodo: float) -> float:
	return TAU / periodo

static func altura(x: float, t: float, amplitud: float, longitud: float, periodo: float) -> float:
	return amplitud * sin(k(longitud) * x - w(periodo) * t)
