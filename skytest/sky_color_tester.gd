extends Control

# ============================================================================
# SKY COLOR TESTER - Herramienta de prueba para colores del cielo
# ============================================================================
# Este script permite probar diferentes colores del cielo en tiempo real
# Presiona las teclas 1-7 para cambiar entre diferentes paletas de colores
# ============================================================================

# ----------------------------------------------------------------------------
# REFERENCIAS A LOS ELEMENTOS DE LA INTERFAZ (UI)
# ----------------------------------------------------------------------------
# Estos @onready buscan los nodos hijos cuando la escena esté lista
@onready var level_name = $Panel/VBoxContainer/LevelName  # Etiqueta que muestra el nombre del nivel
@onready var color_preview = $Panel/VBoxContainer/ColorPreview  # Rectángulo de color de previsualización
@onready var neon_label = $Panel/VBoxContainer/NeonColor  # Etiqueta que muestra el color neón
@onready var sky_label = $Panel/VBoxContainer/SkyColor  # Etiqueta que muestra el color del cielo
@onready var horizon_label = $Panel/VBoxContainer/HorizonColor  # Etiqueta que muestra el color del horizonte
@onready var instructions = $Panel/VBoxContainer/Instructions  # Instrucciones de uso

# ----------------------------------------------------------------------------
# DEFINICIÓN DE COLORES POR NIVEL
# ----------------------------------------------------------------------------
# Este diccionario contiene TODOS los colores para cada nivel
# Cada nivel tiene:
# - "name": Nombre descriptivo del nivel
# - "neon": Color de las partículas brillantes (Vector3 con valores RGB de 0.0 a 1.0)
# - "sky": Color del cielo superior
# - "horizon": Color del horizonte (parte baja del cielo)
# - "tint": Filtro de color que se aplica a la imagen de fondo
# - "tint_intensity": Qué tan fuerte es el filtro (0.0 = sin filtro, 1.0 = filtro total)
# - "glow": Intensidad del brillo de las partículas
var level_colors = {
	1: {
		"name": "Nivel 1 - Azul Neón",
		"neon": Vector3(0.4, 0.8, 1.0),  # Azul brillante
		"sky": Vector3(0.6, 0.7, 0.9),  # Azul cielo claro
		"horizon": Vector3(0.4, 0.5, 0.7),  # Azul más oscuro abajo
		"tint": Vector3(0.7, 0.9, 1.0),  # Tinte azulado para la imagen
		"tint_intensity": 0.85,  # 85% de intensidad del filtro
		"glow": 2.0  # Brillo de las partículas
	},
	2: {
		"name": "Nivel 2 - Cian Eléctrico",
		"neon": Vector3(0.0, 1.0, 0.9),  # Cian brillante
		"sky": Vector3(0.5, 0.8, 0.9),
		"horizon": Vector3(0.3, 0.6, 0.7),
		"tint": Vector3(0.5, 1.0, 0.95),  # Tinte cian
		"tint_intensity": 0.85,
		"glow": 2.0
	},
	3: {
		"name": "Nivel 3 - Púrpura Neón",
		"neon": Vector3(0.7, 0.3, 1.0),  # Púrpura brillante
		"sky": Vector3(0.6, 0.5, 0.8),
		"horizon": Vector3(0.4, 0.3, 0.6),
		"tint": Vector3(0.9, 0.6, 1.0),  # Tinte púrpura
		"tint_intensity": 0.85,
		"glow": 2.0
	},
	4: {
		"name": "Nivel 4 - Rosa/Magenta",
		"neon": Vector3(1.0, 0.2, 0.8),  # Rosa/magenta brillante
		"sky": Vector3(0.8, 0.4, 0.7),
		"horizon": Vector3(0.6, 0.2, 0.5),
		"tint": Vector3(1.0, 0.5, 0.9),  # Tinte rosa
		"tint_intensity": 0.85,
		"glow": 2.0
	},
	5: {
		"name": "Nivel 5 - Verde Matriz",
		"neon": Vector3(0.3, 1.0, 0.4),  # Verde brillante estilo Matrix
		"sky": Vector3(0.5, 0.8, 0.6),
		"horizon": Vector3(0.3, 0.6, 0.4),
		"tint": Vector3(0.6, 1.0, 0.6),  # Tinte verde
		"tint_intensity": 0.85,
		"glow": 2.0
	},
	6: {
		"name": "Nivel 6 - Naranja/Ámbar",
		"neon": Vector3(1.0, 0.6, 0.2),  # Naranja/ámbar brillante
		"sky": Vector3(0.8, 0.6, 0.5),
		"horizon": Vector3(0.6, 0.4, 0.3),
		"tint": Vector3(1.0, 0.8, 0.5),  # Tinte naranja
		"tint_intensity": 0.85,
		"glow": 2.5  # Brillo más intenso para dar sensación de peligro
	},
	7: {
		"name": "Boss - Blanco Brillante",
		"neon": Vector3(1.0, 1.0, 1.0),  # Blanco puro para nivel final
		"sky": Vector3(0.9, 0.95, 1.0),
		"horizon": Vector3(0.8, 0.85, 0.95),
		"tint": Vector3(1.0, 1.0, 1.0),  # Sin tinte de color
		"tint_intensity": 0.5,  # Menos intenso para mantener visibilidad
		"glow": 3.0  # Brillo máximo para dramatismo
	}
}

# ----------------------------------------------------------------------------
# VARIABLES PRINCIPALES
# ----------------------------------------------------------------------------
var world_environment: WorldEnvironment  # Referencia al nodo WorldEnvironment de la escena
var sky_material: ShaderMaterial  # Material del shader del cielo
var current_level = 1  # Nivel actual (empieza en 1)

# ============================================================================
# FUNCIÓN: _ready()
# Se ejecuta automáticamente cuando la escena está lista
# ============================================================================
func _ready():
	# Buscar el WorldEnvironment en toda la escena
	# El parámetro "true" hace que busque recursivamente en todos los nodos hijos
	world_environment = get_tree().root.find_child("WorldEnvironment", true, false)
	
	# Verificar si se encontró el WorldEnvironment
	if not world_environment:
		instructions.text = "ERROR: No se encontró WorldEnvironment"
		return
	
	# Verificar si el WorldEnvironment tiene un Environment con Sky configurado
	if world_environment.environment and world_environment.environment.sky:
		# Obtener el material del shader del cielo
		sky_material = world_environment.environment.sky.sky_material
		
		if sky_material:
			print("✓ Sky material encontrado - Listo para cambiar colores")
			# Aplicar el nivel 1 por defecto al iniciar
			change_level(1)
		else:
			instructions.text = "ERROR: Sky sin material"
	else:
		instructions.text = "ERROR: WorldEnvironment sin Sky"

# ============================================================================
# FUNCIÓN: _input(event)
# Se ejecuta cada vez que hay una entrada del usuario (teclado, mouse, etc.)
# ============================================================================
func _input(event):
	# Si no hay material del cielo, no hacer nada
	if not sky_material:
		return
	
	# Detectar si se presionó una tecla
	if event is InputEventKey and event.pressed:
		# Verificar si la tecla está entre 1 y 7
		if event.keycode >= KEY_1 and event.keycode <= KEY_7:
			# Convertir el código de la tecla al número del nivel
			# Ejemplo: KEY_1 - KEY_0 = 1, KEY_2 - KEY_0 = 2, etc.
			var level = event.keycode - KEY_0
			# Cambiar al nivel correspondiente
			change_level(level)

# ============================================================================
# FUNCIÓN: change_level(level)
# Cambia todos los colores del cielo al nivel especificado
# ============================================================================
# PARÁMETROS:
# - level: Número del nivel (1-7)
# 
# PARA TU COMPAÑERA: Esta es la función principal que cambia los colores
# Desde su GameManager, debería llamar a esta función así:
# 
#   $SkyColorTester.change_level(3)  # Cambiar al nivel 3
# 
# O si este script está en un nodo con otro nombre:
#   get_node("RutaAlNodo").change_level(numero_nivel)
# ============================================================================
func change_level(level: int):
	# Verificar si el nivel existe en el diccionario
	if not level_colors.has(level):
		print("⚠ Nivel ", level, " no existe")
		return
	
	# Guardar el nivel actual
	current_level = level
	
	# Obtener todos los colores de este nivel
	var colors = level_colors[level]
	
	# ----------------------------------------------------------------------------
	# ACTUALIZAR LA INTERFAZ (UI)
	# ----------------------------------------------------------------------------
	# Cambiar el texto del nombre del nivel
	level_name.text = colors["name"]
	
	# Mostrar los valores de los colores en las etiquetas
	neon_label.text = "Neón: " + vec3_to_string(colors["neon"])
	sky_label.text = "Cielo: " + vec3_to_string(colors["sky"])
	horizon_label.text = "Horizonte: " + vec3_to_string(colors["horizon"])
	
	# Actualizar el rectángulo de previsualización con el color neón
	var preview_color = Color(colors["neon"].x, colors["neon"].y, colors["neon"].z)
	color_preview.color = preview_color
	
	# ----------------------------------------------------------------------------
	# APLICAR LOS COLORES AL SHADER
	# ----------------------------------------------------------------------------
	# Estos son los parámetros que el shader usa para renderizar el cielo
	# Cada set_shader_parameter() envía un valor al shader
	
	# Color de las partículas brillantes
	sky_material.set_shader_parameter("neon_blue", colors["neon"])
	
	# Color del cielo (parte superior del degradado)
	sky_material.set_shader_parameter("skyColor", colors["sky"])
	
	# Color del horizonte (parte inferior del degradado)
	sky_material.set_shader_parameter("horizonColor", colors["horizon"])
	
	# Filtro de color que se aplica a la imagen de fondo
	sky_material.set_shader_parameter("texture_tint", colors["tint"])
	
	# Intensidad del filtro de color (0.0 a 1.0)
	sky_material.set_shader_parameter("tint_intensity", colors["tint_intensity"])
	
	# Intensidad del brillo de las partículas
	sky_material.set_shader_parameter("glow_intensity", colors["glow"])
	
	# Mensaje de confirmación en la consola
	print("✓ ", colors["name"], " aplicado con tint fuerte (", colors["tint_intensity"], ")")

# ============================================================================
# FUNCIÓN: vec3_to_string(v)
# Convierte un Vector3 a texto legible
# ============================================================================
# PARÁMETROS:
# - v: Vector3 con valores RGB
# 
# RETORNA:
# - String con formato "Vector3(x, y, z)"
# ============================================================================
func vec3_to_string(v: Vector3) -> String:
	return "Vector3(%.1f, %.1f, %.1f)" % [v.x, v.y, v.z]

# ============================================================================
# PARA TU COMPAÑERA - CÓMO USAR ESTO EN EL GAMEMANAGER:
# ============================================================================
#
# OPCIÓN 1: Si este script está en la escena del juego
# ------------------------------------------------------
# En el GameManager, obtener referencia al nodo y llamar change_level():
#
#   var sky_tester = get_node("UI/SkyColorTester")  # Ajustar ruta según tu escena
#   sky_tester.change_level(3)  # Cambiar al nivel 3
#
#
# OPCIÓN 2: Convertir esto en Autoload (Singleton)
# -------------------------------------------------
# 1. Project → Project Settings → Autoload
# 2. Agregar este script como "SkyTester"
# 3. Desde cualquier script llamar:
#
#   SkyTester.change_level(5)  # Cambiar al nivel 5
#
#
# OPCIÓN 3: Agregar función al GameManager
# -----------------------------------------
# Copiar level_colors{} y la función change_level() al GameManager
# y aplicar los colores directamente desde ahí
#
# ============================================================================
