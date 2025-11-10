extends Node
class_name RecorridosGrafo

# BFS - Búsqueda en Anchura
# Retorna un array con el orden de visita de los nodos
static func bfs(grafo: Grafo, nodo_inicio: Nodo) -> Array:
	var orden_visita = []
	var cola = []
	
	# Resetear estado de todos los nodos
	grafo.resetear_todos_nodos()
	
	# Iniciar desde nodo_inicio
	nodo_inicio.visitado = true
	cola.append(nodo_inicio)
	orden_visita.append(nodo_inicio)
	
	while cola.size() > 0:
		var nodo_actual = cola.pop_front()
		
		# Explorar vecinos
		for vecino in nodo_actual.vecinos:
			if not vecino.visitado:
				vecino.visitado = true
				vecino.padre = nodo_actual
				cola.append(vecino)
				orden_visita.append(vecino)
	
	return orden_visita

# DFS - Búsqueda en Profundidad (versión iterativa)
static func dfs(grafo: Grafo, nodo_inicio: Nodo) -> Array:
	var orden_visita = []
	var pila = []
	
	# Resetear estado de todos los nodos
	grafo.resetear_todos_nodos()
	
	# Iniciar desde nodo_inicio
	pila.append(nodo_inicio)
	
	while pila.size() > 0:
		var nodo_actual = pila.pop_back()
		
		if not nodo_actual.visitado:
			nodo_actual.visitado = true
			orden_visita.append(nodo_actual)
			
			# Agregar vecinos a la pila (en orden inverso para mantener orden lógico)
			for i in range(nodo_actual.vecinos.size() - 1, -1, -1):
				var vecino = nodo_actual.vecinos[i]
				if not vecino.visitado:
					pila.append(vecino)
	
	return orden_visita

# DFS recursivo (alternativa)
static func dfs_recursivo(grafo: Grafo, nodo_inicio: Nodo) -> Array:
	grafo.resetear_todos_nodos()
	var orden_visita = []
	_dfs_recursivo_helper(nodo_inicio, orden_visita)
	return orden_visita

static func _dfs_recursivo_helper(nodo: Nodo, orden_visita: Array) -> void:
	nodo.visitado = true
	orden_visita.append(nodo)
	
	for vecino in nodo.vecinos:
		if not vecino.visitado:
			_dfs_recursivo_helper(vecino, orden_visita)

# Función útil para obtener el camino desde inicio hasta un nodo
static func obtener_camino(nodo_destino: Nodo) -> Array:
	var camino = []
	var nodo_actual = nodo_destino
	
	while nodo_actual != null:
		camino.push_front(nodo_actual)
		nodo_actual = nodo_actual.padre
	
	return camino

# Verificar si existe un camino entre dos nodos
static func existe_camino(grafo: Grafo, nodo_inicio: Nodo, nodo_destino: Nodo) -> bool:
	var visitados = bfs(grafo, nodo_inicio)
	return visitados.has(nodo_destino)
