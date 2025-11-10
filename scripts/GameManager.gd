extends Node
# Singleton - Configurar como Autoload en Project Settings

# Estado global del juego
var nivel_actual: int = 1
var puntuacion_total: int = 0

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
	
	# Calcular recorrido desde nodo 0
	#calcular_recorrido_correcto(0)
	
	#print("Orden correcto: ", obtener_ids_recorrido())
	#print("Tipo de recorrido: ", tipo_recorrido)

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
	print("Juego iniciado - Sigue el recorrido ", tipo_recorrido)
	# Calcular recorrido desde nodo 0
	calcular_recorrido_correcto(0)
	
	print("Orden correcto: ", obtener_ids_recorrido())

func validar_salto_a_nodo(nodo_id: int) -> bool:
	if not juego_iniciado:
		iniciar_juego("null")
		return true
	
	if not puede_saltar:
		return false
	
	var nodo = grafo.obtener_nodo(nodo_id)
	if not nodo:
		return false
	
	# Verificar si es el nodo correcto
	if indice_actual < recorrido_correcto.size():
		var nodo_esperado = recorrido_correcto[indice_actual+1]
		#para que pueda devolverse por los que ya visitó correctamente
		if nodo.vc:
			return true
		if nodo.id == nodo_esperado.id:
			# CORRECTO
			print("nodo %d correcto (%d/%d)" % [nodo.id, indice_actual + 1, recorrido_correcto.size()])
			nodo.marcar_correcto()
			emit_signal("nodo_visitado_correcto", nodo.id)
			indice_actual += 1
			
			# Verificar victoria
			if indice_actual >= recorrido_correcto.size():
				completar_mision()
			
			return true
		else:
			# ¡INCORRECTO!
			print("nodo incorrecto: %d (se esperaba: %d)" % [nodo.id, nodo_esperado.id])
			nodo.marcar_incorrecto()
			emit_signal("nodo_visitado_incorrecto", nodo.id)
			game_over()
			return false
	
	return false

func completar_mision():
	print("\n¡MISIÓN COMPLETADA!")
	puede_saltar = false
	puntuacion_total += 100
	emit_signal("mision_completada")

func game_over():
	print("Game Over - Nodo incorrecto")
	puede_saltar = false
	await get_tree().create_timer(2.0).timeout
	reiniciar_nivel()

func reiniciar_nivel():
	print("\nReiniciando nivel...")
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
