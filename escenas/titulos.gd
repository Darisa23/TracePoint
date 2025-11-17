extends Node

# Duración de cada título en pantalla (segundos)
@export var duracion_titulo: float = 3.0

# Control de estado
var titulo_actual: Node = null
var animacion_actual: AnimationPlayer = null
var nivel_cargado: bool = false

func _ready():
	# Ocultar todos los títulos al inicio
	ocultar_todos_titulos()
	
	# Debug: Mostrar información de los hijos
	print("\n=== DEBUG TITULOS MANAGER ===")
	print("Nodo Titulos tiene ", get_child_count(), " hijos")
	for i in range(get_child_count()):
		var child = get_child(i)
		print("  [", i, "] Nombre: ", child.name, " | Tipo: ", child.get_class())
		var anim = child.get_node_or_null("AnimationPlayer")
		if anim:
			print("      - Tiene AnimationPlayer con animaciones: ", anim.get_animation_list())
		else:
			print("      - NO tiene AnimationPlayer")
	print("=============================\n")
	
	# Conectar señales del GameManager si existen
	if GameManager.has_signal("mision_completada"):
		GameManager.connect("mision_completada", Callable(self, "_on_mision_completada"))
	
	print("TitulosManager listo")
	
	# Test automático - DESACTIVADO (ya probado, funciona correctamente)
	# await get_tree().create_timer(1.0).timeout
	# print("[DEBUG] Iniciando test automático...")
	# iniciar_nivel(1)

func ocultar_todos_titulos():
	"""Oculta todos los nodos de título"""
	print("[DEBUG] Ocultando todos los títulos...")
	for child in get_children():
		if child is Node:
			child.visible = false
			# Detener animación si tiene AnimationPlayer
			var anim_player = child.get_node_or_null("AnimationPlayer")
			if anim_player and anim_player is AnimationPlayer:
				anim_player.stop()
				print("  - Ocultado: ", child.name)
	
	titulo_actual = null
	animacion_actual = null

func mostrar_titulo_nivel(nivel: int):
	"""Muestra el título correspondiente al nivel"""
	print("\n[DEBUG] mostrar_titulo_nivel() llamado con nivel: ", nivel)
	ocultar_todos_titulos()
	
	# Buscar el título por índice (nivel - 1)
	var children = get_children()
	print("[DEBUG] Hijos disponibles: ", children.size())
	
	if nivel > 0 and nivel <= children.size():
		titulo_actual = children[nivel - 1]
		print("[DEBUG] Seleccionado hijo índice ", nivel - 1, ": ", titulo_actual.name)
	else:
		push_warning("Nivel no válido: " + str(nivel) + " (solo hay " + str(children.size()) + " títulos)")
		return
	
	if titulo_actual:
		print("[DEBUG] Haciendo visible: ", titulo_actual.name)
		titulo_actual.visible = true
		print("[DEBUG] ¿Es visible?: ", titulo_actual.visible)
		
		# Reproducir animación "Title"
		animacion_actual = titulo_actual.get_node_or_null("AnimationPlayer")
		print("[DEBUG] AnimationPlayer encontrado: ", animacion_actual != null)
		
		if animacion_actual and animacion_actual is AnimationPlayer:
			print("[DEBUG] Animaciones disponibles: ", animacion_actual.get_animation_list())
			if animacion_actual.has_animation("Title"):
				print("[DEBUG] Reproduciendo animación 'Title'")
				animacion_actual.play("Title")
			else:
				push_warning("AnimationPlayer no tiene animación 'Title' en nivel " + str(nivel))
		
		print("[DEBUG] Esperando ", duracion_titulo, " segundos...")
		# Iniciar temporizador para ocultar el título
		await get_tree().create_timer(duracion_titulo).timeout
		print("[DEBUG] Tiempo cumplido, cargando nivel...")
		ocultar_titulo_y_cargar_nivel(nivel)

func ocultar_titulo_y_cargar_nivel(nivel: int):
	"""Oculta el título y carga el nivel correspondiente"""
	ocultar_todos_titulos()
	print("[DEBUG] Cargando nivel ", nivel)
	
	# Cargar el nivel correspondiente en el GameManager
	match nivel:
		1:
			GameManager.cargar_nivel_1()
			# El nivel 1 no tiene tipo predefinido (el jugador elige BFS/DFS)
			# GameManager.tipo_recorrido queda en "null"
		2:
			GameManager.cargar_nivel_2()
			# Nivel 2 usa Dijkstra automáticamente (ya configurado en cargar_nivel_2)
		3:
			GameManager.cargar_nivel_3()
			# Nivel 3 usa Prim automáticamente (ya configurado en cargar_nivel_3)
		_:
			push_warning("Nivel sin implementación de carga: " + str(nivel))
	
	await get_tree().process_frame
	nivel_cargado = true
	print("[DEBUG] Nivel ", nivel, " cargado y listo para jugar")

func iniciar_nivel(nivel: int):
	"""Función pública para iniciar un nivel con su título"""
	print("\n[DEBUG] ===== INICIAR_NIVEL(", nivel, ") LLAMADO =====")
	nivel_cargado = false
	mostrar_titulo_nivel(nivel)

func _on_mision_completada():
	"""Cuando se completa una misión, pasar al siguiente nivel"""
	var siguiente_nivel = GameManager.nivel_actual + 1
	
	# Verificar si hay más niveles
	if siguiente_nivel <= 4:  # Ajusta según cuántos niveles tengas CAMBIE ESTOOO A 4
		await get_tree().create_timer(1.0).timeout
		iniciar_nivel(siguiente_nivel)
	else:
		print("¡Juego completado!")
		# Aquí puedes cargar una escena de victoria o créditos

# Funciones auxiliares para llamar desde otros scripts
func saltar_titulo():
	"""Permite saltar el título actual inmediatamente"""
	if titulo_actual and titulo_actual.visible:
		var nivel = GameManager.nivel_actual
		ocultar_titulo_y_cargar_nivel(nivel)

func esta_mostrando_titulo() -> bool:
	"""Verifica si actualmente se está mostrando algún título"""
	return titulo_actual != null and titulo_actual.visible

func reiniciar_titulo_nivel_actual():
	"""Reinicia el título del nivel actual"""
	if GameManager.nivel_actual > 0:
		iniciar_nivel(GameManager.nivel_actual)
