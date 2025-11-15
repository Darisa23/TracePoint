extends Label

var num_puntos = 0
var timer_puntos = 0.0
var timer_parpadeo = 0.0

const INTERVALO_PUNTOS = 0.5  # Cambia los puntos cada 0.5 segundos
const INTERVALO_PARPADEO = 0.05 # Frecuencia de cambio de transparencia

# Propiedades para el parpadeo
var alpha_visible = 1.0  # Totalmente visible
var alpha_oculto = 0.6  # Un poco transparente (para el efecto de fade)
var parpadeo_activo = true

func _process(delta):
	# --- 1. Animación de Puntos Suspensivos ---
	timer_puntos += delta
	if timer_puntos >= INTERVALO_PUNTOS:
		timer_puntos = 0.0
		
		num_puntos = (num_puntos + 1) % 4
		
		var puntos = ""
		for i in range(num_puntos):
			puntos += "."
			
		self.text = "Cargando" + puntos

	# --- 2. Animación de Parpadeo (Flicker) ---
	timer_parpadeo += delta
	if timer_parpadeo >= INTERVALO_PARPADEO:
		timer_parpadeo = 0.0
		
		# Invertir el estado de parpadeo
		parpadeo_activo = not parpadeo_activo
		
		# Aplicar el cambio de transparencia (Módulo)
		var new_alpha = alpha_visible if parpadeo_activo else alpha_oculto
		
		# Crear un nuevo color (manteniendo el color original, solo cambiando el alpha)
		var nuevo_color = self.modulate
		nuevo_color.a = new_alpha
		
		self.modulate = nuevo_color
