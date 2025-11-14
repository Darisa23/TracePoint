extends Node
# Singleton - Configurar como Autoload en Project Settings

# Estado global del juego
var nivel_actual: int = 1
var puntuacion_total: int = 0
var vidas_actuales : int = 3
var vidas_maximas : int = 3
# Nivel actual
var grafo: Grafo = null
var tipo_recorrido: String = "null"  # "BFS" o "DFS"
var recorrido_correcto: Array = []
var indice_actual: int = 0
var juego_iniciado: bool = false
var puede_saltar: bool = true

# Referencias (se asignan cuando se carga el nivel)
var player: Node3D = null
var spawner: Node3D = null

# Señales
signal nodo_visitado_correcto(nodo_id: int)
signal nodo_visitado_incorrecto(nodo_id: int)
signal vida_perdida()
signal game_over()
signal mision_completada()
signal nivel_reiniciado()

func _ready():
	print("GameManager inicializado como singleton")

# ============================================
# CONFIGURACIÓN DE NIVELES
# ============================================

func cargar_nivel_1():
	print("\n=== CARGANDO NIVEL 1: NETWORK TRACER ===")
	nivel_actual = 1
	tipo_recorrido = "null"
	
	# Matriz de adyacencia del nivel 1
	var matriz = [
		[0, 0, 1, 0, 0, 0],
		[0, 0, 1, 0, 1, 0],
		[1, 1, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 1],
		[0, 1, 0, 0, 0, 0],
		[0, 0, 1, 1, 0, 0]
	]
	
	# Crear grafo
	grafo = Grafo.new(matriz, false)
	
	# Posiciones 3D de cada nodo
	var posiciones = [
		Vector3(0, 0, 0),
		Vector3(5, 0, 0),
		Vector3(2.5, 0, 5),
		Vector3(7.5, 0, 5),
		Vector3(10, 0, 0),
		Vector3(5, 0, 10)
	]
	
	# Asignar posiciones
	for i in range(grafo.nodos.size()):
		grafo.nodos[i].posicion_3d = posiciones[i]
	
	grafo.imprimir_grafo()

func cargar_nivel_2():
	print("\n=== CARGANDO NIVEL 2: SAFEROUTE ===")
	nivel_actual = 2
	tipo_recorrido = "DIJKSTRA"
	
	# Matriz de adyacencia del nivel 2
	var matriz = [
		[0, 1, 1, 1, 0, 0, 0],
		[1, 0, 1, 0, 0, 0, 0],
		[1, 1, 0, 0, 1, 1, 0],
		[1, 0, 0, 0, 1, 0, 0],
		[0, 0, 1, 1, 0, 1, 1],
		[0, 0, 1, 0, 1, 0, 0],
		[0, 0, 0, 0, 1, 0, 0]
	]
	
	# Matriz de pesos del nivel 2
	var pesos = [
		[0, 8, 3, 5, 0, 0, 0],
		[8, 0, 11, 0, 0, 0, 0],
		[3, 11, 0, 0, 1, 1, 0],
		[5, 0, 0, 0, 4, 0, 0],
		[0, 0, 1, 4, 0, 2, 6],
		[0, 0, 1, 0, 2, 0, 0],
		[0, 0, 0, 0, 6, 0, 0]
	]
	
	print("Creando grafo con matriz ", matriz.size(), "x", matriz[0].size())
	
	# Crear grafo CON pesos
	grafo = Grafo.new(matriz, false, pesos)
	
	print("Grafo creado con ", grafo.nodos.size(), " nodos")
	
	# Posiciones 3D (8 nodos en círculo)
	var posiciones = [
		Vector3(0, 0, 0),      # A
		Vector3(0, 0, 5),      # B
		Vector3(5, 0, 5),      # C
		Vector3(5, 0, 0),     # D
		Vector3(13, 0, 5),     # E
		Vector3(5, 0, 13),     # F
		Vector3(13, 0, 13),     # G
	]
	
	for i in range(grafo.nodos.size()):
		grafo.nodos[i].posicion_3d = posiciones[i]
	
	grafo.imprimir_grafo()
	# Para Dijkstra calcularíamos el camino mínimo (lo implementamos después)

func calcular_recorrido_correcto(nodo_inicio_id: int):
	if not grafo:
		push_error("No hay grafo cargado")
		return
	
	var nodo_inicio = grafo.obtener_nodo(nodo_inicio_id)
	
	if tipo_recorrido == "BFS":
		recorrido_correcto = RecorridosGrafo.bfs(grafo, nodo_inicio)
	else:
		recorrido_correcto = RecorridosGrafo.dfs(grafo, nodo_inicio)
	
	indice_actual = 0

# ============================================
# LÓGICA DE JUEGO
# ============================================

func iniciar_juego(type:String):
	if not grafo:
		push_error("Debes cargar un nivel primero con cargar_nivel_1()")
		return
	if type == "null":
		return
	tipo_recorrido = type
	juego_iniciado = true
	puede_saltar = true
	indice_actual = 0
	grafo.obtener_nodo(0).marcar_correcto()
	print("Juego iniciado - Sigue el recorrido ", tipo_recorrido)
	calcular_recorrido_correcto(0)
	
	print("Orden correcto: ", obtener_ids_recorrido())

func validar_salto_a_nodo(nodo_id: int) -> bool:
	if not juego_iniciado:
		print("inicia juego")
		iniciar_juego(tipo_recorrido)
		return true
	
	if not puede_saltar:
		#print("psalt")
		
		return false
	
	var nodo = grafo.obtener_nodo(nodo_id)
	if not nodo:
		#print("not nodo")
		return false
	
	# Verificción
	if (indice_actual+1) < recorrido_correcto.size():
		var nodo_esperado = recorrido_correcto[indice_actual+1]
		#para que pueda devolverse por los que ya visitó correctamente
		if nodo.vc:
			#print("lol")
			return true
		if nodo.id == nodo_esperado.id:
			print("nodo %d correcto (%d/%d)" % [nodo.id, indice_actual + 1, recorrido_correcto.size()])
			nodo.marcar_correcto()
			emit_signal("nodo_visitado_correcto", nodo.id)
			indice_actual += 1
			
			# Verificar victoria
			if (indice_actual+1) >= recorrido_correcto.size():
				completar_mision()
			
			return true
		else:
			print("nodo incorrecto: %d (se esperaba: %d)" % [nodo.id, nodo_esperado.id])
			nodo.marcar_incorrecto()
			emit_signal("nodo_visitado_incorrecto", nodo.id)
			perder_vida()
			return false
	
	return false

func completar_mision():
	print("fin nivel")
	puede_saltar = false
	puntuacion_total += 100
	emit_signal("mision_completada")

func perder_vida():
	vidas_actuales -= 1
	print("LA VAINA: ",vidas_actuales)
	print("Vida perdida! Vidas restantes: %d/%d" % [vidas_actuales, vidas_maximas])
	emit_signal("vida_perdida")	
	if vidas_actuales <= 0:
		print("Sin vidas! GAME OVER")
		gameOver()
	else:
		await get_tree().create_timer(0.8).timeout
		reiniciar_nivel()


func gameOver():
	puede_saltar = false
	emit_signal("game_over")
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://escenas/game_over.tscn")

func reiniciar_nivel():
	indice_actual = 0
	juego_iniciado = false
	puede_saltar = true
	
	# Resetear grafo
	if grafo:
		grafo.resetear_todos_nodos()
		for nodo in grafo.nodos:
			nodo.restaurar_color()
	
	# Reposicionar jugador
	if player and grafo:
		player.global_position = grafo.nodos[0].posicion_3d + Vector3(0, 2, 0)
	
	emit_signal("nivel_reiniciado")

# ============================================
# UTILIDADES
# ============================================

func cambiar_tipo_recorrido(nuevo_tipo: String):
	if nuevo_tipo in ["BFS", "DFS"]:
		tipo_recorrido = nuevo_tipo
		calcular_recorrido_correcto(0)
		print("Tipo de recorrido cambiado a: ", tipo_recorrido)
		print("Nuevo orden: ", obtener_ids_recorrido())

func obtener_ids_recorrido() -> Array:
	var ids = []
	for nodo in recorrido_correcto:
		ids.append(nodo.id)
	print(ids)
	return ids
	

func obtener_siguiente_nodo_esperado() -> Nodo:
	if indice_actual < recorrido_correcto.size():
		return recorrido_correcto[indice_actual]
	return null

func obtener_progreso() -> String:
	return "%d/%d nodos" % [indice_actual, recorrido_correcto.size()]

func registrar_player(p_player: Node3D):
	player = p_player
	print("Player registrado en GameManager")

func registrar_spawner(p_spawner: Node3D):
	spawner = p_spawner
	print("Spawner registrado en GameManager")
