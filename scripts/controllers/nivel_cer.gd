extends Node3D
# Script para adjuntar a cada nivel

@export var nivel_numero: int = 1
@export var activo: bool = true  # Desactiva niveles que no estés usando
@onready var graf = $GrafoSpawner
func _ready():
	# Si el nivel no está activo, desactivarlo
	if not activo:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	# Cargar el nivel correspondiente en GameManager
	match nivel_numero:
		1:
			print("HOLAAA, se hizo el ready para nivel 1")
			GameManager.cargar_nivel_1()
			graf.instanciar_grafo()
			if graf.dibujar_conexiones:
				graf.instanciar_conexiones()
		2:
			print("HOLAAA, se hizo el ready para novel 2")
			push_warning("Nivel 2 aún no implementado")
			GameManager.cargar_nivel_2()
			graf.instanciar_grafo()
			if graf.dibujar_conexiones:
				graf.instanciar_conexiones()
			#GameManager.iniciar_juego("dijkstra")
		3:
			push_warning("Nivel 3 aún no implementado")
			# GameManager.cargar_nivel_3()
		_:
			push_error("Nivel no implementado: ", nivel_numero)
			return
	
	# IMPORTANTE: Esperar a que el grafo esté listo
	await get_tree().process_frame
	await get_tree().process_frame

	
	# Conectar señales del GameManager
	if not GameManager.mision_completada.is_connected(_on_mision_completada):
		GameManager.mision_completada.connect(_on_mision_completada)
	if not GameManager.nivel_reiniciado.is_connected(_on_nivel_reiniciado):
		GameManager.nivel_reiniciado.connect(_on_nivel_reiniciado)


func _on_mision_completada():
	print("\n¡NIVEL %d COMPLETADO!" % nivel_numero)
	# Aquí puedes:
	# - Mostrar pantalla de victoria
	# - Desactivar este nivel y activar el siguiente
	# - Reproducir sonidos/animaciones

func _on_nivel_reiniciado():
	print("Nivel %d reiniciado" % nivel_numero)
	# El CyberQuestController reposicionará el player

# Método para activar/desactivar el nivel
func activar():
	self.activo = true
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	
	match nivel_numero:
		1:
			GameManager.cargar_nivel_1()
			graf.instanciar_grafo()
			if graf.dibujar_conexiones:
				graf.instanciar_conexiones()
		2:
			GameManager.cargar_nivel_2()
			graf.instanciar_grafo()
			if graf.dibujar_conexiones:
				graf.instanciar_conexiones()
			GameManager.iniciar_juego("dijkstra")
		3:
			GameManager.cargar_nivel_3()
	await get_tree().process_frame

func desactivar():
	self.activo = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
