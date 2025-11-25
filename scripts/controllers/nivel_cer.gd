extends Node3D
# Script para adjuntar a cada nivel

@export var nivel_numero: int = 1
@export var activo: bool = true  # Desactiva niveles que no estés usando
@onready var graf = $GrafoSpawner
@onready var pack = $PlataformaPaquetes if has_node("PlataformaPaquetes") else null
@onready var titulo = $Titulo1NetworkTracer
@onready var flowm = $FlowManager if has_node("FlowManager") else null
@onready var venN1 =  $ventana
@onready var venN4 = $CanvasLayer/ventana

func _ready():
# Conectar señales del GameManager
	if not GameManager.mision_completada.is_connected(_on_mision_completada) and nivel_numero == GameManager.nivel_actual:
		GameManager.mision_completada.connect(_on_mision_completada)
	if not GameManager.nivel_reiniciado.is_connected(_on_nivel_reiniciado) and nivel_numero == GameManager.nivel_actual:
		GameManager.nivel_reiniciado.connect(_on_nivel_reiniciado)
	match nivel_numero:
		1:	
			GameManager.cargar_nivel_1()
			graf.instanciar_grafo()
			if graf.dibujar_conexiones:
				graf.instanciar_conexiones()
			await get_tree().create_timer(1.5).timeout
			titulo.chou()
			venN1.ini()
		2:	
			titulo.show_level(nivel_numero)
			GameManager.cargar_nivel_2()
			graf.instanciar_grafo()
			if graf.dibujar_conexiones:
				graf.instanciar_conexiones()
			GameManager.iniciar_juego("dijkstra")
		3:	
			titulo.show_level(nivel_numero)
			GameManager.cargar_nivel_3()
			graf.instanciar_grafo()
			if graf.dibujar_conexiones:
				graf.instanciar_conexiones()
			GameManager.iniciar_juego("prim")
		4:	
			titulo.show_level(nivel_numero)
			GameManager.cargar_nivel_4()		
			graf.instanciar_grafo()
			if graf.dibujar_conexiones:
				graf.instanciar_conexiones()
			flowm.inicializar_nivel()
			#pack.generar_paquetes()
			GameManager.iniciar_juego("fordfulkerson")
			venN4.ini()
			
	await get_tree().process_frame

func _on_mision_completada():
	print("\n¡NIVEL %d COMPLETADO!" % nivel_numero)
	print("ACÁ SE CAMBIA A LA ESCENA DEL BANCO")
	# Aquí puedes:
	# - Mostrar pantalla de victoria
	# - Desactivar este nivel y activar el siguiente
	# - Reproducir sonidos/animaciones

func _on_nivel_reiniciado():
	print("Nivel %d reiniciado" % nivel_numero)
	# El CyberQuestController reposicionará el player
