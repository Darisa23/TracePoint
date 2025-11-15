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
# Dijkstra - Camino más corto entre dos nodos
# Retorna un array con los nodos del camino más corto desde nodo_inicio hasta nodo_destino
static func dijkstra(grafo: Grafo, nodo_inicio: Nodo, nodo_destino: Nodo) -> Array:
	var distancias = {}
	var no_visitados = []
	
	# Resetear estado de todos los nodos
	grafo.resetear_todos_nodos()
	
	# Inicializar distancias
	for nodo in grafo.nodos:
		distancias[nodo] = INF
		no_visitados.append(nodo)
	
	distancias[nodo_inicio] = 0
	nodo_inicio.distancia = 0
	
	while no_visitados.size() > 0:
		# Encontrar nodo con menor distancia
		var nodo_actual = null
		var menor_distancia = INF
		
		for nodo in no_visitados:
			if distancias[nodo] < menor_distancia:
				menor_distancia = distancias[nodo]
				nodo_actual = nodo
		
		# Si no hay más nodos alcanzables o ya llegamos al destino
		if nodo_actual == null or distancias[nodo_actual] == INF:
			break
		
		# Si llegamos al destino, podemos terminar
		if nodo_actual == nodo_destino:
			break
		
		# Marcar como visitado
		nodo_actual.visitado = true
		no_visitados.erase(nodo_actual)
		
		# Actualizar distancias de vecinos
		for vecino in nodo_actual.vecinos:
			if not vecino.visitado:
				var peso = grafo.obtener_peso(nodo_actual, vecino)
				var nueva_distancia = distancias[nodo_actual] + peso
				
				if nueva_distancia < distancias[vecino]:
					distancias[vecino] = nueva_distancia
					vecino.distancia = nueva_distancia
					vecino.padre = nodo_actual
	
	# Reconstruir el camino desde el destino hasta el inicio
	return obtener_camino(nodo_destino)

# Prim - Árbol de Expansión Mínima desde nodo inicial
# Retorna un array con los nodos en el orden que fueron agregados al MST
static func prim(grafo: Grafo, nodo_inicio: Nodo = null) -> Array:
	var orden_mst = []
	var en_mst = {}  # Nodos ya incluidos en el MST
	var aristas_disponibles = []  # [{origen: Nodo, destino: Nodo, peso: float}]
	
	# Resetear estado de todos los nodos
	grafo.resetear_todos_nodos()
	
	# Si no se especifica nodo inicial, usar el primero
	if nodo_inicio == null:
		nodo_inicio = grafo.nodos[0]
	
	# Agregar el nodo inicial al MST
	nodo_inicio.visitado = true
	nodo_inicio.tiene_coleccionable = false
	en_mst[nodo_inicio] = true
	orden_mst.append(nodo_inicio)
	
	# Agregar todas las aristas del nodo inicial
	for vecino in nodo_inicio.vecinos:
		var peso = grafo.obtener_peso(nodo_inicio, vecino)
		aristas_disponibles.append({
			"origen": nodo_inicio,
			"destino": vecino,
			"peso": peso
		})
	
	# Mientras haya nodos por agregar
	while orden_mst.size() < grafo.nodos.size() and aristas_disponibles.size() > 0:
		# Ordenar aristas por peso (menor primero)
		aristas_disponibles.sort_custom(func(a, b): return a.peso < b.peso)
		
		# Buscar la arista de menor peso que conecte a un nodo nuevo
		var arista_elegida = null
		var indice_eliminar = -1
		
		for i in range(aristas_disponibles.size()):
			var arista = aristas_disponibles[i]
			if not en_mst.has(arista.destino):
				arista_elegida = arista
				indice_eliminar = i
				break
		
		# Si no hay más aristas válidas, terminar
		if arista_elegida == null:
			break
		
		# Eliminar la arista elegida de las disponibles
		aristas_disponibles.remove_at(indice_eliminar)
		
		# Agregar el nuevo nodo al MST
		var nodo_nuevo = arista_elegida.destino
		nodo_nuevo.visitado = true
		nodo_nuevo.padre = arista_elegida.origen
		en_mst[nodo_nuevo] = true
		
		# CRITERIO DEL COLECCIONABLE:
		# Si el nodo nuevo NO es vecino directo del último nodo agregado
		var ultimo_nodo = orden_mst[orden_mst.size() - 1]
		if not ultimo_nodo.vecinos.has(nodo_nuevo):
			nodo_nuevo.tiene_coleccionable = true
		else:
			nodo_nuevo.tiene_coleccionable = false
		
		orden_mst.append(nodo_nuevo)
		
		# Agregar las aristas del nuevo nodo a las disponibles
		for vecino in nodo_nuevo.vecinos:
			if not en_mst.has(vecino):
				var peso = grafo.obtener_peso(nodo_nuevo, vecino)
				aristas_disponibles.append({
					"origen": nodo_nuevo,
					"destino": vecino,
					"peso": peso
				})
	
	return orden_mst
