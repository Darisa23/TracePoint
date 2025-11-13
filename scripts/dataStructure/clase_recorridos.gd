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
# Kruskal - Árbol de Expansión Mínima
# Retorna un array de diccionarios con las aristas en orden: [{origen: Nodo, destino: Nodo, peso: float}]
static func kruskal(grafo: Grafo) -> Array:
	var aristas_mst = []
	var todas_aristas = []
	var conjuntos = {}
	
	# Resetear estado
	grafo.resetear_todos_nodos()
	
	# Recolectar todas las aristas desde la matriz de pesos
	for i in range(grafo.nodos.size()):
		for j in range(i + 1 if not grafo.es_dirigido else 0, grafo.nodos.size()):
			if grafo.existe_arista(grafo.nodos[i], grafo.nodos[j]):
				var peso = grafo.obtener_peso(grafo.nodos[i], grafo.nodos[j])
				todas_aristas.append({
					"origen": grafo.nodos[i],
					"destino": grafo.nodos[j],
					"peso": peso
				})
	
	# Ordenar aristas por peso
	todas_aristas.sort_custom(func(a, b): return a.peso < b.peso)
	
	# Inicializar conjuntos disjuntos (cada nodo es su propio conjunto)
	for nodo in grafo.nodos:
		conjuntos[nodo] = nodo
	
	# Función para encontrar el representante del conjunto
	var encontrar_conjunto = func(nodo):
		var raiz = nodo
		while conjuntos[raiz] != raiz:
			raiz = conjuntos[raiz]
		# Compresión de camino
		var actual = nodo
		while actual != raiz:
			var siguiente = conjuntos[actual]
			conjuntos[actual] = raiz
			actual = siguiente
		return raiz
	
	# Función para unir dos conjuntos
	var unir_conjuntos = func(nodo1, nodo2):
		var raiz1 = encontrar_conjunto.call(nodo1)
		var raiz2 = encontrar_conjunto.call(nodo2)
		conjuntos[raiz1] = raiz2
	
	# Procesar aristas
	for arista in todas_aristas:
		var conjunto1 = encontrar_conjunto.call(arista.origen)
		var conjunto2 = encontrar_conjunto.call(arista.destino)
		
		# Si no forman ciclo, agregar al MST
		if conjunto1 != conjunto2:
			aristas_mst.append(arista)
			unir_conjuntos.call(arista.origen, arista.destino)
			
			# Marcar los nodos como visitados en el orden en que se procesan
			if not arista.origen.visitado:
				arista.origen.visitado = true
			if not arista.destino.visitado:
				arista.destino.visitado = true
			
			# Si ya tenemos n-1 aristas, terminamos
			if aristas_mst.size() == grafo.nodos.size() - 1:
				break
	
	return aristas_mst


# Función para obtener solo los nodos del MST de Kruskal en orden
static func kruskal_nodos(grafo: Grafo) -> Array:
	var aristas_mst = kruskal(grafo)
	var nodos_ordenados = []
	
	for arista in aristas_mst:
		if not nodos_ordenados.has(arista.origen):
			nodos_ordenados.append(arista.origen)
		if not nodos_ordenados.has(arista.destino):
			nodos_ordenados.append(arista.destino)
	
	return nodos_ordenados
