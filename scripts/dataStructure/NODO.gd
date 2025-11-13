extends Node
class_name Nodo

# Propiedades del nodo
var id: int
var nombre: String
var posicion_3d: Vector3
var vecinos: Array = []  # Array de Nodo
var visitado: bool = false
var vc: bool = false
var esA: bool = false
var distancia: float = INF
var padre: Nodo = null

# Referencias visuales (si está en la escena)
var nodo_visual: Node3D = null
var material_original: StandardMaterial3D = null

func _init(p_id: int, p_nombre: String = "", p_posicion: Vector3 = Vector3.ZERO):
	id = p_id
	nombre = p_nombre if p_nombre != "" else "Nodo_" + str(p_id)
	posicion_3d = p_posicion

func agregar_vecino(vecino: Nodo) -> void:
	if not vecinos.has(vecino):
		vecinos.append(vecino)

func resetear_estado() -> void:
	visitado = false
	vc = false
	distancia = INF
	padre = null

# Métodos para visualización
func marcar_correcto() -> void:
	if nodo_visual:
		nodo_visual.marcar_correcto()
	vc = true

func marcar_incorrecto() -> void:
	if nodo_visual:
		nodo_visual.marcar_incorrecto()

func marcar_visitado() -> void:
	if nodo_visual:
		nodo_visual.marcar_visitado()


func restaurar_color() -> void:
	
	if nodo_visual and material_original:
		nodo_visual.restaurar_color()

func toString() -> String:
	return "Nodo[id=%d, nombre=%s, vecinos=%d]" % [id, nombre, vecinos.size()]
