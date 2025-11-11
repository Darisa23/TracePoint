extends Node3D
# Script para adjuntar a cada nivel

@export var nivel_numero: int = 1
@export var activo: bool = true  # Desactiva niveles que no estés usando

func _ready():
	# Si el nivel no está activo, desactivarlo
	if not activo:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	# Cargar el nivel correspondiente en GameManager
	match nivel_numero:
		1:
			GameManager.cargar_nivel_1()
		2:
			push_warning("Nivel 2 aún no implementado")
			# GameManager.cargar_nivel_2()
		3:
			push_warning("Nivel 3 aún no implementado")
			# GameManager.cargar_nivel_3()
		_:
			push_error("Nivel no implementado: ", nivel_numero)
			return
	
	# IMPORTANTE: Esperar a que el grafo esté listo
	await get_tree().process_frame
	await get_tree().process_frame
	
	# El CyberQuestController se encargará de posicionar el player
	
	print("Nivel %d cargado" % nivel_numero)
	
	# Conectar señales del GameManager
	if not GameManager.mision_completada.is_connected(_on_mision_completada):
		GameManager.mision_completada.connect(_on_mision_completada)
	if not GameManager.nivel_reiniciado.is_connected(_on_nivel_reiniciado):
		GameManager.nivel_reiniciado.connect(_on_nivel_reiniciado)
	
	print("Nivel %d listo para jugar" % nivel_numero)

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
	activo = true
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT

func desactivar():
	activo = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
