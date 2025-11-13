extends Node
# Script para el Hub World (zona central que se expande)

@export var player_spawn_position: Vector3 = Vector3(0, 2, 0)
@onready var player = get_node("../Player") if has_node("../Player") else null

# Banderas/Portales para cada nivel
@onready var portal_nivel_1 = $Portal_Nivel1 if has_node("Portal_Nivel1") else null
@onready var portal_nivel_2 = $Portal_Nivel2 if has_node("Portal_Nivel2") else null
@onready var portal_nivel_3 = $Portal_Nivel3 if has_node("Portal_Nivel3") else null
@onready var portal_nemesis = $Portal_Nemesis if has_node("Portal_Nemesis") else null

# Secciones del hub que se desbloquean
@onready var seccion_1 = $Seccion1  # Inicial (siempre visible)
@onready var seccion_2 = $Seccion2 if has_node("Seccion2") else null  # Después de nivel 1
@onready var seccion_3 = $Seccion3 if has_node("Seccion3") else null  # Después de nivel 2
@onready var seccion_4 = $Seccion4 if has_node("Seccion4") else null  # Después de nivel 3

var nivel_actual_completado: int = 0

func _ready():
# Posicionar player en spawn
	if player:
		print("zi")
		player.global_position = player_spawn_position
	
	# Configurar estado inicial del hub
	configurar_mundo_segun_progreso()
	
	# Conectar señales
	GameManager.mision_completada.connect(_on_mision_completada)

func configurar_mundo_segun_progreso():
	# Cargar progreso guardado (por ahora hardcodeado)
	nivel_actual_completado = GameManager.nivel_actual - 1
	
	# Mostrar/ocultar secciones según progreso
	if seccion_2:
		seccion_2.visible = nivel_actual_completado >= 1
	if seccion_3:
		seccion_3.visible = nivel_actual_completado >= 2
	if seccion_4:
		seccion_4.visible = nivel_actual_completado >= 3
	
	# Activar portales correspondientes
	if portal_nivel_2:
		portal_nivel_2.visible = nivel_actual_completado >= 1
	if portal_nivel_3:
		portal_nivel_3.visible = nivel_actual_completado >= 2
	if portal_nemesis:
		portal_nemesis.visible = nivel_actual_completado >= 3
	
	print("Hub configurado - Niveles completados: %d" % nivel_actual_completado)

func _on_mision_completada():
	print("una misión completada")
	nivel_actual_completado += 1
	
	# Expandir el hub
	ampliar_mundo()

func ampliar_mundo():
	print("Expandiendo Hub World...")
	
	# Animación de expansión (puedes mejorar esto)
	match nivel_actual_completado:
		1:
			if seccion_2:
				animar_aparicion_seccion(seccion_2)
		2:
			if seccion_3:
				animar_aparicion_seccion(seccion_3)
		3:
			if seccion_4:
				animar_aparicion_seccion(seccion_4)

func animar_aparicion_seccion(seccion: Node3D):
	seccion.visible = true
	seccion.scale = Vector3.ZERO
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(seccion, "scale", Vector3.ONE, 1.0)
	
	print("nueva sección desbloqueada: ", seccion.name)

func teleportar_player(posicion_custom: Vector3 = player_spawn_position):
	if player:
		player.global_position = posicion_custom
		if "velocity" in player:
			player.velocity = Vector3.ZERO
		print("player teleportado al mundo: ", posicion_custom)
