extends Node2D # O el tipo de nodo que sea tu raíz (Control, etc.)

# Duración del fundido de entrada (Fade In)
const DURACION_FADE_IN = 0.8 

# REFERENCIA AL COLORRECT (Asegúrate que el nodo se llama "ColorRect" en el Inspector)
@onready var fade_screen = $ColorRect 

func _ready():
	# 1. Aseguramos que la pantalla de fundido esté completamente negra (opaca) al inicio.
	if is_instance_valid(fade_screen):
		fade_screen.modulate.a = 1.0
		
	# 2. Iniciamos la transición suave (Fade In)
	# Usamos call_deferred para asegurar que el motor termine de dibujar el ColorRect antes de iniciar el Tween.
	call_deferred("iniciar_fade_in")

func iniciar_fade_in():
	# Solo inicia el Tween si la pantalla de fundido existe.
	if is_instance_valid(fade_screen):
		var tween = create_tween()
		
		# 3. Animación: Lleva la opacidad del ColorRect de 1.0 (Negro Total) a 0.0 (Transparente)
		tween.tween_property(fade_screen, "modulate:a", 0.0, DURACION_FADE_IN)
		
		# Aquí iría el código para iniciar la carga asíncrona de recursos.
		# Ejemplo: tween.tween_callback(self.iniciar_carga_de_recursos)
	else:
		print("ADVERTENCIA: No se encontró el ColorRect. Iniciando carga de forma inmediata.")
