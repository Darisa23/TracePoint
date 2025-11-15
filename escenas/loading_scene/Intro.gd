extends Control

@export var escena_siguiente: PackedScene

# Referencias a los Nodos 
@onready var logo_antenas = $LogoAntenas
@onready var logo_tiny_tardigrade = $tinytardigrade
@onready var logo_tracepoint = $tracepoint
@onready var color_rect_fade = $ColorRect

# Constantes de Tiempo
const DURACION_FADE_IN = 1.0
const DURACION_MOSTRAR = 1.5
const DURACION_FADE_OUT = 0.5
const DURACION_NEGRO_FINAL = 1.0

func _ready():
	# Configurar para pantalla completa
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Engine.max_fps = 120
	
	logo_antenas.modulate.a = 0.0
	logo_antenas.stop()
	logo_antenas.frame = 0
	
	logo_tiny_tardigrade.modulate.a = 0.0
	logo_tracepoint.modulate.a = 0.0
	color_rect_fade.modulate.a = 1.0
	
	iniciar_secuencia_intro()

func iniciar_secuencia_intro():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	# NEGRO INICIAL
	tween.tween_interval(0.5)
	
	# -----------------------------------------------------
	# 1. Logo tiny_tardigrade
	# -----------------------------------------------------
	tween.tween_property(logo_tiny_tardigrade, "modulate:a", 1.0, DURACION_FADE_IN)
	tween.tween_interval(DURACION_MOSTRAR)
	tween.tween_property(logo_tiny_tardigrade, "modulate:a", 0.0, DURACION_FADE_OUT)
	tween.tween_interval(0.5)
	
	# -----------------------------------------------------
	# 2. Logo ANTENAS - Animación con parpadeo
	# -----------------------------------------------------
	
	# Aparecer antenas
	tween.tween_property(logo_antenas, "modulate:a", 1.0, DURACION_FADE_IN)
	
	# Configurar y reproducir animación rápida
	tween.tween_callback(func(): 
		if logo_antenas.sprite_frames:
			logo_antenas.sprite_frames.set_animation_loop("default", false)
		logo_antenas.speed_scale = 5.0
		logo_antenas.play()
	)
	
	# Esperar fase rápida
	tween.tween_interval(2)
	
	# Cambiar a velocidad normal
	tween.tween_callback(func(): 
		logo_antenas.speed_scale = 1.0
	)
	
	# Esperar resto de animación
	tween.tween_interval(1)
	
	# Pausar en el último frame (cuando deja de parpadear)
	tween.tween_callback(func():
		logo_antenas.pause()
		logo_antenas.frame = logo_antenas.sprite_frames.get_frame_count("default") - 1
	)
	
	# Mantener visible medio segundo
	tween.tween_interval(0.5)
	
	# -----------------------------------------------------
	# 3. SUBIR antenas Y aparecer logo SIMULTÁNEAMENTE
	# -----------------------------------------------------
	
	# Las 3 cosas pasan AL MISMO TIEMPO en 0.5 segundos:
	tween.tween_property(logo_antenas, "position:y", logo_antenas.position.y - 65, 0.5)
	tween.tween_property(logo_antenas, "scale", Vector2(0.3, 0.3), 0.5).set_delay(-0.5)
	tween.tween_property(logo_tracepoint, "modulate:a", 1.0, 0.5).set_delay(-0.5)
	
	# -----------------------------------------------------
	# 4. Mantener ambos logos visibles
	# -----------------------------------------------------
	tween.tween_interval(4.0)
	
	# Desaparecer ambos
	tween.tween_property(logo_tracepoint, "modulate:a", 0.0, DURACION_FADE_OUT)
	tween.tween_property(logo_antenas, "modulate:a", 0.0, DURACION_FADE_OUT).set_delay(-DURACION_FADE_OUT)
	
	# -----------------------------------------------------
	# 5. Fade a negro y cambiar escena
	# -----------------------------------------------------
	tween.tween_interval(DURACION_NEGRO_FINAL)
	tween.tween_property(color_rect_fade, "modulate:a", 1.0, 0.5)
	
	# Cambiar de escena
	tween.tween_callback(func():
		if escena_siguiente:
			get_tree().change_scene_to_packed(escena_siguiente)
		else:
			push_error("No hay escena siguiente asignada")
	)
	
