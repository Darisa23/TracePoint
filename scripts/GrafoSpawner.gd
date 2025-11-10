extends Node3D

# Configuración
@export var nodo_prefab: PackedScene  # Arrastra Nodo3D.tscn aquí
@export var dibujar_conexiones: bool = true

var nodos_instanciados: Array = []

func _ready():
	print("GrafoSpawner._ready() iniciado")
	
	# Registrarse en el GameManager
	GameManager.registrar_spawner(self)
	
	# Esperar un frame
	await get_tree().process_frame
	
	print("Verificando grafo en GameManager...")
	print("  GameManager.grafo existe: ", GameManager.grafo != null)
	if GameManager.grafo:
		print("  Número de nodos: ", GameManager.grafo.nodos.size())
	
	# Instanciar el grafo del nivel actual
	if GameManager.grafo:
		instanciar_grafo()
		if dibujar_conexiones:
			instanciar_conexiones()
	else:
		push_error("GameManager no tiene un grafo cargado")
		push_error("Asegúrate de que LevelController llame a GameManager.cargar_nivel_X() primero")

func instanciar_grafo():
	print("Instanciando nodos del grafo...")
	
	if not nodo_prefab:
		push_error("No se asignó el prefab del nodo en GrafoSpawner")
		return
	
	var grafo = GameManager.grafo
	
	# Limpiar nodos previos si existen
	for nodo in nodos_instanciados:
		if is_instance_valid(nodo):
			nodo.queue_free()
	nodos_instanciados.clear()
	
	# Crear cada nodo visual
	for nodo_logico in grafo.nodos:
		var nodo_visual = nodo_prefab.instantiate()
		add_child(nodo_visual)
		
		# Inicializar el nodo visual
		nodo_visual.inicializar(nodo_logico)
		
		nodos_instanciados.append(nodo_visual)
		
		print("  ✓ Nodo %d en %s" % [nodo_logico.id, nodo_logico.posicion_3d])
	
	print("%d nodos creados" % nodos_instanciados.size())

func instanciar_conexiones():
	print("Dibujando conexiones...")
	
	var grafo = GameManager.grafo
	var conexiones_dibujadas = 0
	
	for nodo_logico in grafo.nodos:
		for vecino in nodo_logico.vecinos:
			# Evitar duplicados en grafos no dirigidos
			if not grafo.es_dirigido and nodo_logico.id > vecino.id:
				continue
			
			crear_linea_conexion(nodo_logico.posicion_3d, vecino.posicion_3d)
			conexiones_dibujadas += 1
	
	print("%d conexiones dibujadas" % conexiones_dibujadas)

func crear_linea_conexion(pos_inicio: Vector3, pos_fin: Vector3):
	var linea = MeshInstance3D.new()
	add_child(linea)
	
	# Cilindro delgado como línea
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = 0.05
	mesh.height = pos_inicio.distance_to(pos_fin)
	linea.mesh = mesh
	
	# Material semi-transparente
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.5, 0.5, 0.3)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	linea.set_surface_override_material(0, material)
	
	# Posicionar entre los dos nodos
	linea.global_position = (pos_inicio + pos_fin) / 2.0
	linea.look_at(pos_fin, Vector3.UP)
	linea.rotate_object_local(Vector3.RIGHT, PI / 2)

func destacar_siguiente_nodo():
	var siguiente = GameManager.obtener_siguiente_nodo_esperado()
	if siguiente and siguiente.nodo_visual:
		siguiente.nodo_visual.mostrar_highlight()

func resetear_nodos_visuales():
	for nodo_visual in nodos_instanciados:
		if is_instance_valid(nodo_visual):
			nodo_visual.restaurar_color()
