extends TextureRect

@onready var shader_material: ShaderMaterial = material as ShaderMaterial

# --- Parámetros de Glitch (para control directo) ---

func set_glitch_intensity(intensity: float) -> void:
	if shader_material:
		shader_material.set_shader_parameter("glitch_intensity", intensity)

func set_glitch_offset(offset: float) -> void:
	if shader_material:
		shader_material.set_shader_parameter("glitch_offset", offset)

# --- Función Principal Caótica ---

func _ready() -> void:
	# Inicializa el generador de números aleatorios
	# Esto es crucial para que el glitch no sea siempre igual
	randomize() 
	
	if shader_material:
		# Llama a la función de glitch continuo. El 'await' permite que la pausa no congele el juego.
		glitch_loop()
	else:
		printerr("Error: No se encontró ShaderMaterial en TextureRect.")

# Esta función se ejecuta para siempre (o hasta que el nodo se elimine)
func glitch_loop() -> void:
	while true:
		# 1. Glitch Intenso
		# randf() genera un número entre 0.0 y 1.0. Esto lo hace más caótico.
		var intense_value = randf_range(0.2, 0.7) 
		var offset_value = randf_range(0.01, 0.04) 

		set_glitch_intensity(intense_value)
		set_glitch_offset(offset_value)
		
		# Pausa corta y aleatoria
		var pause_time = randf_range(0.05, 0.2) # Pausa entre 50ms y 200ms
		await get_tree().create_timer(pause_time).timeout
		
		# 2. Glitch de Reposo (Efecto de "Ruido")
		# Baja la intensidad para un parpadeo más sutil
		set_glitch_intensity(randf_range(0.0, 0.15))
		set_glitch_offset(randf_range(0.001, 0.008))
		
		# Pausa ligeramente más larga antes del siguiente gran glitch
		pause_time = randf_range(0.1, 0.5) 
		await get_tree().create_timer(pause_time).timeout
