extends CanvasLayer
# Autoload para transiciones entre escenas

@onready var anim_player = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var color_rect = $ColorRect

# Estado
var transicionando: bool = false

func _ready():
	# Configurar ColorRect para cubrir toda la pantalla
	if color_rect:
		color_rect.color = Color.BLACK
		color_rect.modulate.a = 0.0  # Iniciar transparente

func transicion_a_nivel(nivel: int, tipo_recorrido: String = "null"):
	if transicionando:
		return
	
	print("Iniciando transición a nivel %d" % nivel)
	transicionando = true
	
	# Configurar el nivel en GameManager
	GameManager.tipo_recorrido = tipo_recorrido
	
	# Fade out
	await fade_out()
	
	# Cambiar escena
	match nivel:
		1, 2, 3:
			get_tree().change_scene_to_file("res://scenes/CyberQuest.tscn")
			# Después del cambio, el CyberQuestController cargará el nivel correcto
		_:
			push_error("Nivel inválido: ", nivel)
	
	# Fade in
	await fade_in()
	
	transicionando = false

func transicion_a_mundo():
	if transicionando:
		return
	
	print("Regresando al mundo")
	transicionando = true
	
	await fade_out()
	
	# Cambiar a escena del hub
	get_tree().change_scene_to_file("res://scenes/CyberQuest.tscn")
	
	await fade_in()
	
	transicionando = false

func fade_out(duracion: float = 0.5) -> void:
	if not color_rect:
		await get_tree().create_timer(duracion).timeout
		return
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duracion)
	await tween.finished

func fade_in(duracion: float = 0.5) -> void:
	if not color_rect:
		await get_tree().create_timer(duracion).timeout
		return
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duracion)
	await tween.finished

# Efecto de "caída del cielo"
func transicion_caida_cielo(posicion_destino: Vector3):
	print("Transición: Caída del cielo")
	
	var player = GameManager.player
	if not player:
		return
	
	# Posicionar al player alto en el cielo
	player.global_position = posicion_destino + Vector3(0, 50, 0)
	
	# Fade in mientras cae
	await fade_in(0.3)
	
	# El player caerá naturalmente por la gravedad
	# Opcional: agregar efecto de partículas o estela

# Efecto de teletransporte
func transicion_teleport(posicion_destino: Vector3):
	print("teletransporte")
	
	await fade_out(0.3)
	
	var player = GameManager.player
	if player:
		player.global_position = posicion_destino
		if "velocity" in player:
			player.velocity = Vector3.ZERO
	
	await fade_in(0.3)
