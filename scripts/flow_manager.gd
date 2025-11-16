extends Node

# Referencias
@onready var packet_spawner = $"../PacketSpawner"
var player: CharacterBody3D
var source_nodo: Nodo
var sink_nodo: Nodo

# Estado del juego
var flujo_objetivo: int = 20
var flujo_actual: int = 0
var tiempo_restante: float = 120.0  # 2 minutos
var juego_activo: bool = false

# Señales
signal flujo_actualizado(flujo_actual: int, flujo_objetivo: int)
signal tiempo_actualizado(tiempo: float)
signal nivel_completado()
signal nivel_fallido()


func _process(delta):
	if not juego_activo:
		return
	
	# Countdown
	tiempo_restante -= delta
	emit_signal("tiempo_actualizado", tiempo_restante)
	
	if tiempo_restante <= 0:
		game_over()

func inicializar_nivel():
	if not GameManager.grafo:
		push_error("No hay grafo cargado para nivel 4")
		return
	
	# Obtener player
	player = GameManager.player
	
	# Identificar source y sink
	source_nodo = GameManager.grafo.nodos[0]
	sink_nodo = GameManager.grafo.nodos[3]
	
	print("Nivel 4 inicializadoOOO")
	print("  SOURCE: Nodo %d en %s" % [source_nodo.id, source_nodo.posicion_3d])
	print("  SINK: Nodo %d en %s" % [sink_nodo.id, sink_nodo.posicion_3d])
	print("  Objetivo: %d paquetes" % flujo_objetivo)
	
	# Marcar visualmente source y sink
	if source_nodo.nodo_visual:
		source_nodo.nodo_visual.material.albedo_color = Color.GREEN
		source_nodo.nodo_visual.material.emission_enabled = true
		source_nodo.nodo_visual.material.emission = Color.GREEN
		source_nodo.nodo_visual.material.emission_energy = 2.0
	
	if sink_nodo.nodo_visual:
		sink_nodo.nodo_visual.material.albedo_color = Color.BLUE
		sink_nodo.nodo_visual.material.emission_enabled = true
		sink_nodo.nodo_visual.material.emission = Color.BLUE
		sink_nodo.nodo_visual.material.emission_energy = 2.0
	
	# Agregar detector en SINK
	crear_detector_sink()
	
	# Spawn inicial de paquetes
	if packet_spawner:
		packet_spawner.spawn_paquetes(3)
	
	juego_activo = true

func crear_detector_sink():
	# Crear Area3D en el sink para detectar cuando player llega
	if not sink_nodo.nodo_visual:
		return
	
	var area = Area3D.new()
	area.name = "SinkDetector"
	sink_nodo.nodo_visual.add_child(area)
	
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 2.0
	collision.shape = shape
	area.add_child(collision)
	
	area.body_entered.connect(_on_sink_reached)

func _on_sink_reached(body):
	if body == player and player.paquetes_llevando > 0:
		depositar_paquetes()

func depositar_paquetes():
	var cantidad = player.depositar_paquetes()
	flujo_actual += cantidad
	
	print("+%d paquetes depositados | Total: %d/%d" % [cantidad, flujo_actual, flujo_objetivo])
	emit_signal("flujo_actualizado", flujo_actual, flujo_objetivo)
	
	# Spawn nuevos paquetes
	if packet_spawner:
		packet_spawner.spawn_paquetes(cantidad)
	
	# Verificar victoria
	if flujo_actual >= flujo_objetivo:
		victoria()

func victoria():
	juego_activo = false
	print("¡NIVEL 4 COMPLETADO!")
	emit_signal("nivel_completado")
	GameManager.completar_mision()

func game_over():
	juego_activo = false
	print("Tiempo agotado!")
	emit_signal("nivel_fallido")
	GameManager.gameOver()
