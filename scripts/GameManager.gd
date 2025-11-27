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
var ca:bool = false
var nombre_nodos: Array = []
var iniciado_una_vez : bool = false
# En tu script, podrías tener algo así:

var info_nodos_n1 = {
	1: {
		"nombre": "Workstation_Recepcion",
		"estado": "LIMPIO",
		"servicios": ["HTTP"],
		"log": "Actividad normal. No hubo interacción sospechosa en las últimas horas.",
		"popup": "HTTP: Servicio web básico — no suele ser ruta de ransomware."
	},
	2: {
		"nombre": "Server_Email",
		"estado": "SOSPECHOSO",
		"servicios": ["SMTP", "IMAP"],
		"log": "Archivo adjunto abierto por Dra. Martínez. Posible phishing detectado.",
		"popup": "SMTP: Usado para enviar correos. Vector común de phishing."
	},
	3: {
		"nombre": "FileServer_Principal",
		"estado": "CIFRADO",
		"servicios": ["SMB"],
		"log": "50% de archivos cifrados. Ransomware activo.",
		"popup": "SMB: Protocolo de compartir archivos — objetivo favorito del ransomware."
	},
	4: {
		"nombre": "Backup_Server",
		"estado": "OFFLINE",
		"servicios": [],
		"log": "Servidor desconectado manualmente. Posible intento de sabotaje.",
		"popup": "Los atacantes deshabilitan backups para impedir recuperación."
	},
	5: {
		"nombre": "Admin_Workstation",
		"estado": "LIMPIO",
		"servicios": ["RDP"],
		"log": "Credenciales válidas. Sin actividad fuera de horario.",
		"popup": "RDP: Escritorio remoto — puerta común para movimientos laterales."
	},
	6: {
		"nombre": "Exchange_Server",
		"estado": "COMPROMETIDO",
		"servicios": ["SMTP", "RPC", "OWA"],
		"log": "Exploit detectado: CVE-2023-XXXX — ejecución remota vía correo malicioso.",
		"popup": "¡PATIENT ZERO encontrado! — El ransomware entró por una macro maliciosa."
	}
}
var info_nodos_n3 = {
	1: {
		"nombre":"SCADA_CORE",
		"estado": "ACTIVO",
		"servicios": ["SCADA", "HMI", "Monitoreo"],
		"log": "Nodo central de control. Todas las órdenes salen desde aquí."
	},
	2: {
		"nombre":"SUBESTACIÓN NORTE",
		"estado": "DESCONECTADO",
		"servicios": ["RTU", "Distribución Urbana"],
		"log": "Subestación norte sin comunicación tras el sabotaje."
	},
	3: {
		"nombre":"SUBESTACIÓN SUR",
		"estado": "INESTABLE",
		"servicios": ["RTU", "Zona Residencial"],
		"log": "Flujo irregular. Riesgo de sobrecarga si se conecta mal."
	},
	4: {
		
		"nombre":"SUBESTACIÓN INDUSTRIAL",
		"estado": "DESCONECTADO",
		"servicios": ["RTU", "Zona Industrial"],
		"log": "Consumo extremo. Conectar sólo por líneas seguras."
	},
	5: {
		"nombre":"TRANSFORMADOR A",
		"estado": "SOBRECARGA CRÍTICA",
		"servicios": ["IED", "Transformación 230kV"],
		"log": "Transformador al límite térmico. Un error lo destruye."
	},
	6: {
		"nombre":"ROUTER INDUSTRIAL",
		
		
		"estado": "INACTIVO",
		"servicios": ["IED", "Respaldo"],
		"log": "Transformador secundario. Puede absorber carga si se conecta bien."
	},
	7: {
		"nombre":"TRANSFORMADOR B",
		"estado": "COMPROMETIDO",
		"servicios": ["PLC", "Generación"],
		"log": "Valores de control alterados por malware ICS."
	},
	8: {
		"nombre":"PLC DE GENERACIÓN",
		"estado": "INTERMITENTE",
		"servicios": ["Router OT", "Comunicación"],
		"log": "Pérdida de paquetes constante entre subestaciones."
	},
	9: {
		"nombre":"ENLACE EXTERNO",
		"estado": "DISPONIBLE",
		"servicios": ["Interconexión Nacional"],
		"log": "Enlace externo para balanceo de carga crítico."
	}
}
var info_nodos: Dictionary = {} 
# Referencias (se asignan cuando se carga el nivel)
var player: Node3D = null
var spawner: Node3D = null
#Variable condición perder vide nivel 2:
var pv2:bool = false
# Datos específicos del nivel 4 (Flujo Máximo)
var flujo_maximo_calculado: int = 0
var caminos_aumentantes: Array = []  # Resultado de Ford-Fulkerson
var capacidades_nodos: Dictionary = {}  # {nodo_id: capacidad_maxima}
# Señales
signal nodo_visitado_correcto(nodo_id: int)
signal nodo_visitado_incorrecto(nodo_id: int)
signal vida_perdida()
signal game_over()
signal mision_completada()
signal nivel_reiniciado()
func _ready():
	print("GameManager inicializado como singleton")

func _process(_delta):
	# Detectar si el player se cayó del mapa
	if player and juego_iniciado and puede_saltar:
		if player.global_position.y < -10:  # Límite de caída
			print("Player se cayó del mapa!")
			puede_saltar = false
			ca=true
			gameOver()
# ============================================
# CONFIGURACIÓN DE NIVELES
# ============================================

func cargar_nivel_1():
	print("\n=== CARGANDO NIVEL 1: NETWORK TRACER ===")
	nivel_actual = 1
	tipo_recorrido = "null"
	info_nodos = info_nodos_n1
	nombre_nodos = ["Recepcion","Mail_Server","FileServer",
	"Backup_Server","Admin_Workstation","Exchange_Server"]
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
		Vector3(5, 0, 0),      # B
		Vector3(5, 0, 5),      # C
		Vector3(0, 0, 5),     # D
		Vector3(5, 0, 10),     # E
		Vector3(10, 0, 5),     # F
		Vector3(10, 0, 10),     # G
	]
	
	for i in range(grafo.nodos.size()):
		grafo.nodos[i].posicion_3d = posiciones[i]
	
	#grafo.imprimir_grafo()
	# Para Dijkstra calcularíamos el camino mínimo (lo implementamos después)

func cargar_nivel_3():
	print("\n=== CARGANDO NIVEL 3: REBUILDNET ===")
	nivel_actual = 3
	info_nodos = info_nodos_n3
	tipo_recorrido = "PRIM"
	nombre_nodos = [
	"SCADA_CORE",                # 0
	"SUBESTACIÓN NORTE",         # 1
	"SUBESTACIÓN SUR",           # 2
	"SUBESTACIÓN INDUSTRIAL",    # 3
	"TRANSFORMADOR A",           # 4
	"TRANSFORMADOR B",           # 5
	"PLC DE GENERACIÓN",         # 6
	"ROUTER INDUSTRIAL",         # 7
	"ENLACE EXTERNO"             # 8
		]
	# Matriz de adyacencia del nivel 3
	var matriz = [
		[0, 1, 0, 0, 0, 0, 0, 1,0],
		[1, 0, 1, 0, 0, 0, 0, 1,0],
		[0, 1, 0, 1, 0, 1, 0, 0,1],
		[0, 0, 1, 0, 1, 1, 0, 0,0],
		[0, 0, 0, 1, 0, 1, 0, 0,0],
		[0, 0, 1, 1, 1, 0, 1, 0,0],
		[0, 0, 0, 0, 0, 1, 0, 1,1],
		[1, 1, 0, 0, 0, 0, 1, 0,1],
		[0,0, 1, 0, 0, 0, 1, 1,0],
	]
	
	var pesos = [
		[0, 4, 0, 0, 0, 0, 0, 8,0],
		[4, 0, 8, 0, 0, 0, 0, 11,0],
		[0, 8, 0, 7, 0, 4, 0, 0,2],
		[0, 0, 7, 0, 9, 14, 0, 0,0],
		[0, 0, 0, 9, 0, 14, 0, 0,0],
		[0, 0, 4, 14, 10, 0, 2, 0,0],
		[0, 0, 0, 0, 0, 2, 0, 1,6],
		[8, 11, 0, 0, 0, 0, 1, 0,7],
		[0, 0, 2, 0, 0, 0, 6, 7, 0], 
		]

	
	print("Creando grafo con matriz ", matriz.size(), "x", matriz[0].size())
	
	grafo = Grafo.new(matriz, false, pesos)
	
	print("Grafo creado con ", grafo.nodos.size(), " nodos")

	var posiciones = [
	Vector3(0, 0, 0),     # A
	Vector3(5, 0, 5),     # B
	Vector3(12, 0, 5),    # C
	Vector3(19, 0, 5),    # D
	Vector3(24, 0, 0),    # E
	Vector3(19, 0, -5),   # F
	Vector3(12, 0, -5),   # G
	Vector3(5, 0, -5),    # H
	Vector3(12, 0, 0),    # I	
	]
	for i in range(grafo.nodos.size()):
		grafo.nodos[i].posicion_3d = posiciones[i]
	
	#grafo.imprimir_grafo()

func cargar_nivel_4():
	print("\n=== CARGANDO NIVEL 4: FLOWCONTROL ===")
	nivel_actual = 4
	tipo_recorrido = "FORD_FULKERSON"
	
	var matriz = [  #A  B  C  D  E  F  G  
					[0, 1, 0, 0, 1, 0, 1],#A
					[0, 0, 1, 0, 1, 0, 0],#B
					[0, 0, 0, 1, 0, 0, 0],#C
					[0, 0, 0, 0, 0, 0, 0],#D
					[0, 0, 1, 0, 0, 1, 1],#E
					[0, 0, 1, 1, 0, 0, 0],#F
					[0, 0, 0, 0, 0, 1, 0] #G
	]
	
	var capacidades = [
		#A  B  C  D  E  F  G 
		[0, 5, 0, 0, 7, 0, 4],#A
		[0, 0, 3, 0, 1, 0, 0],#B
		[0, 0, 0, 9, 0, 0, 0],#C
		[0, 0, 0, 0, 0, 0, 0],#D
		[0, 0, 4, 0, 0, 5, 2],#E
		[0, 0, 1, 6, 0, 0, 0],#F
		[0, 0, 0, 0, 0, 4, 0],#G
		

	]
	grafo = Grafo.new(matriz, true, capacidades)  # TRUE = dirigido
	print("Grafo creado con ", grafo.nodos.size(), " nodos")
	
	# Posiciones en línea (source a sink)
	var posiciones = [
		Vector3(0, 0, 0), # A
		Vector3(5, 0, 0), # B
		Vector3(10, 0, 0),# C
		Vector3(15, 0, 0),# D
		Vector3(5, 0, -5),# E
		Vector3(10, 0,-5),# F
		Vector3(5, 0,-10),# G
	]
	for i in range(grafo.nodos.size()):
		grafo.nodos[i].posicion_3d = posiciones[i]
	#grafo.imprimir_grafo()
	
	# Calcular flujo máximo
	var resultado = RecorridosGrafo.calcular_flujo_maximo(grafo, 0, 3)
	flujo_maximo_calculado = resultado.flujo_maximo
	print("Flujo máximo: ", flujo_maximo_calculado)
	print("Caminos posibles: ", resultado.caminos.size())
	#calcular_capacidades_nodos()
	capacidades_nodos = RecorridosGrafo.calcular_flujo_por_nodo(resultado.caminos)

func calcular_recorrido_correcto(nodo_inicio_id: int):
	if not grafo:
		push_error("No hay grafo cargado")
		return
	
	var nodo_inicio = grafo.obtener_nodo(nodo_inicio_id)
	
	if tipo_recorrido == "BFS":
		recorrido_correcto = RecorridosGrafo.bfs(grafo, nodo_inicio)
	elif tipo_recorrido == "DFS":
		recorrido_correcto = RecorridosGrafo.dfs(grafo, nodo_inicio)
	elif tipo_recorrido == "dijkstra":
		var nodo_destino = grafo.obtener_nodo(6)
		recorrido_correcto = RecorridosGrafo.dijkstra(grafo,nodo_inicio,nodo_destino)
		print("Camino más corto:")
		for nodo in recorrido_correcto:
			print("Nodo %d, distancia: %f" % [nodo.id, nodo.distancia])
	elif tipo_recorrido == "prim":
		recorrido_correcto = RecorridosGrafo.prim(grafo,nodo_inicio)
	elif tipo_recorrido == "fordfulkerson":
		print("oki FF")
		

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
	grafo.obtener_nodo(0).vc = true
	tipo_recorrido = type
	juego_iniciado = true
	puede_saltar = true
	iniciado_una_vez = true
	indice_actual = 0
	grafo.obtener_nodo(0).marcar_correcto()
	
	print("Juego iniciado - Sigue el recorrido ", tipo_recorrido)
	calcular_recorrido_correcto(0)
	if not nivel_actual == 4:
		print("Orden correcto: ", obtener_ids_recorrido())
	
	
	#print("vc en iniciar juego:",grafo.obtener_nodo(0).vc)
	
func validar_salto_a_nodo(nodo_id: int) -> bool:
	if not juego_iniciado:
		print("ESCOGE UN BOTON PARA inicia juego")
		return true	
	if not puede_saltar:
		#print("psalt")	
		return false
	if nivel_actual == 3 and nodo_id == 0:
		grafo.obtener_nodo(0).marcar_correcto()
		return true
	var nodo = grafo.obtener_nodo(nodo_id)
	if not nodo:
		print("not nodo")
		return false
	if nivel_actual == 4:
		#print("nivel 4 otra dinámica")
		emit_signal("nodo_visitado_correcto", nodo.id)
		return true
	# Verificción para 3 primeros niveles:
	if (indice_actual+1) < recorrido_correcto.size():
		var nodo_esperado = recorrido_correcto[indice_actual+1]
		#para que pueda devolverse por los que ya visitó correctamente
		if nodo.vc:
			print("lol")
			if nivel_actual == 1 or nivel_actual == 3:
				nodo.marcar_correcto()
				emit_signal("nodo_visitado_correcto", nodo.id)
			return true
		if nodo.id == nodo_esperado.id:
			print("nodo %d correcto (%d/%d)" % [nodo.id, indice_actual + 1, recorrido_correcto.size()])
			if nivel_actual != 2:
				nodo.marcar_correcto()
			emit_signal("nodo_visitado_correcto", nodo.id)
			indice_actual += 1
			 ##Verificar victoria
			if (indice_actual+1) >= recorrido_correcto.size():
				completar_mision()
			
			return true
		else:
			print("nodo incorrecto: %d (se esperaba: %d)" % [nodo.id, nodo_esperado.id])
			if nivel_actual != 2 and not pv2:
				nodo.marcar_incorrecto()
			emit_signal("nodo_visitado_incorrecto", nodo.id)
			if nivel_actual != 2 or pv2:
				perder_vida()
			return false
	
	return false

func completar_mision():
	print("fin nivel")
	puede_saltar = false
	iniciado_una_vez = false
	puntuacion_total += 100
	emit_signal("mision_completada")

func perder_vida():
	vidas_actuales -= 1
	#print("LA VAINA: ",vidas_actuales)
	print("Vida perdida! Vidas restantes: %d/%d" % [vidas_actuales, vidas_maximas])
	emit_signal("vida_perdida")	
	if vidas_actuales <= 0:
		print("Sin vidas! GAME OVER")
		gameOver()
	else:
		await get_tree().create_timer(1).timeout
		reiniciar_nivel()


func gameOver():
	puede_saltar = false
	iniciado_una_vez = false
	emit_signal("game_over")
	var t = 3
	if ca:
		t=0.3
	await get_tree().create_timer(t).timeout
	get_tree().change_scene_to_file("res://escenas/game_over.tscn")

func reiniciar_nivel():
	indice_actual = 0
	pv2 = false
	#juego_iniciado = false
	puede_saltar = true
	ca = false
	# Resetear grafo
	if grafo:
		grafo.resetear_todos_nodos()
		for nodo in grafo.nodos:
			nodo.restaurar_color()
	grafo.obtener_nodo(0).vc = true
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
	if typeof(recorrido_correcto[0]) == TYPE_INT:
		return recorrido_correcto
	else:
		var ids = []
		for nodo in recorrido_correcto:
			ids.append(nodo.id)
		#print(ids)
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
