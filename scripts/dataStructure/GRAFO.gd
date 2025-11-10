extends Node
class_name Grafo

var nodos: Array = []  # Array de Nodo
var es_dirigido: bool = false
var matriz_adyacencia: Array = []
var matriz_pesos: Array = []  # Opcional, para algoritmos que necesiten pesos

func _init(p_matriz_adyacencia: Array, p_dirigido: bool = false, p_matriz_pesos: Array = []):
	es_dirigido = p_dirigido
	matriz_adyacencia = p_matriz_adyacencia
	matriz_pesos = p_matriz_pesos
	
	# Crear nodos basados en la matriz
	var num_nodos = matriz_adyacencia.size()
	for i in range(num_nodos):
		var nodo = Nodo.new(i)
		nodos.append(nodo)
	
	# Construir conexiones
	construir_grafo()

func construir_grafo() -> void:
	for i in range(matriz_adyacencia.size()):
		for j in range(matriz_adyacencia[i].size()):
			if matriz_adyacencia[i][j] == 1:
				# Agregar arista de i a j
				nodos[i].agregar_vecino(nodos[j])
				
				# Si no es dirigido, agregar también de j a i
				if not es_dirigido and i != j:
					nodos[j].agregar_vecino(nodos[i])

func obtener_nodo(id: int) -> Nodo:
	if id >= 0 and id < nodos.size():
		return nodos[id]
	return null

func obtener_peso(nodo_a: Nodo, nodo_b: Nodo) -> float:
	if matriz_pesos.size() > 0:
		return matriz_pesos[nodo_a.id][nodo_b.id]
	return 1.0  # Peso por defecto si no hay matriz de pesos

func resetear_todos_nodos() -> void:
	for nodo in nodos:
		nodo.resetear_estado()

func obtener_num_nodos() -> int:
	return nodos.size()

func obtener_vecinos(nodo: Nodo) -> Array:
	return nodo.vecinos

func existe_arista(nodo_a: Nodo, nodo_b: Nodo) -> bool:
	return nodo_a.vecinos.has(nodo_b)

# Método útil para debugging
func imprimir_grafo() -> void:
	print("=== GRAFO ===")
	print("Dirigido: ", es_dirigido)
	print("Nodos: ", nodos.size())
	for nodo in nodos:
		var vecinos_ids = []
		for vecino in nodo.vecinos:
			vecinos_ids.append(vecino.id)
		print("Nodo %d -> %s" % [nodo.id, str(vecinos_ids)])

# Método para obtener información de la matriz
func obtener_info() -> Dictionary:
	return {
		"num_nodos": nodos.size(),
		"es_dirigido": es_dirigido,
		"tiene_pesos": matriz_pesos.size() > 0
	}
