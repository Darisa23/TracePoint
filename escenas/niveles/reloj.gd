extends Control

@onready var reloj = $ColorRect
@onready var label = $Label

var tiempo_total: float = 1200.0  # 2 minutos para nivel 4
var tiempo_actual: float = 1200.0
var activo: bool = false
var inicializado: bool = false
var ya_verifico_inicio: bool = false
var shader_material: ShaderMaterial

func _ready():

	# Ocultar por defecto
	visible = false
	
	# Configurar shader material
	if reloj and reloj.material and reloj.material is ShaderMaterial:
		shader_material = reloj.material
		shader_material.set_shader_parameter("progreso", 1.0)
	
	# Conectar señales del GameManager
	GameManager.connect("mision_completada", _on_mision_completada)
	GameManager.connect("nivel_reiniciado", _on_nivel_reiniciado)
	GameManager.connect("game_over", _on_game_over)

func _process(delta):
	# SOLO verificar UNA VEZ cuando el juego se inicia
	if not ya_verifico_inicio and not inicializado:
		if GameManager.nivel_actual == 4 and GameManager.juego_iniciado:
			inicializar_reloj()
			ya_verifico_inicio = true
	
	# Actualizar tiempo si está activo
	if activo and inicializado:
		tiempo_actual -= delta
		
		# Verificar si se acabó el tiempo
		if tiempo_actual <= 0:
			tiempo_actual = 0
			activo = false
			_on_tiempo_agotado()
		
		actualizar_ui()
	
	# Ocultar si ya no estamos en nivel 4
	if GameManager.nivel_actual != 4 and visible:
		visible = false
		inicializado = false
		activo = false
		ya_verifico_inicio = false

func inicializar_reloj():
	if inicializado:
		return
	
	# Resetear tiempo
	tiempo_actual = tiempo_total
	activo = true
	inicializado = true
	visible = true
	
	# Configurar shader inicial
	if shader_material:
		shader_material.set_shader_parameter("progreso", 1.0)
		shader_material.set_shader_parameter("color_neon", Vector3(0.0, 1.0, 1.0))  # Cyan inicial
	
	actualizar_ui()

func actualizar_ui():
	if not shader_material or not label:
		return
	
	# Calcular progreso (1.0 = lleno, 0.0 = vacío)
	var progreso = tiempo_actual / tiempo_total if tiempo_total > 0 else 0.0
	shader_material.set_shader_parameter("progreso", progreso)
	
	# Actualizar texto del label
	var minutos = int(tiempo_actual) / 60
	var segundos = int(tiempo_actual) % 60
	label.text = "%02d:%02d" % [minutos, segundos]
	
	# Cambiar color según el tiempo restante
	if tiempo_actual < tiempo_total * 0.25:
		# Rojo cuando queda menos del 25%
		shader_material.set_shader_parameter("color_neon", Vector3(1.0, 0.0, 0.0))
		shader_material.set_shader_parameter("brillo", 3.0)  # Más brillo en rojo
	elif tiempo_actual < tiempo_total * 0.5:
		# Amarillo cuando queda menos del 50%
		shader_material.set_shader_parameter("color_neon", Vector3(1.0, 1.0, 0.0))
		shader_material.set_shader_parameter("brillo", 2.5)
	else:
		# Cyan cuando hay tiempo suficiente
		shader_material.set_shader_parameter("color_neon", Vector3(0.0, 1.0, 1.0))
		shader_material.set_shader_parameter("brillo", 2.5)

func pausar():
	"""Pausa el reloj"""
	activo = false

func reanudar():
	"""Reanuda el reloj"""
	if inicializado:
		activo = true

func agregar_tiempo(segundos: float):
	"""Agrega tiempo adicional al reloj"""
	tiempo_actual = min(tiempo_actual + segundos, tiempo_total)
	actualizar_ui()

func _on_tiempo_agotado():
	"""Llamado cuando el tiempo se agota"""
	print("\n⏰ ¡TIEMPO AGOTADO!")
	activo = false
	
	# Game Over por tiempo agotado
	if GameManager.nivel_actual == 4:
		GameManager.perder_vida()

func _on_mision_completada():
	"""Detener reloj cuando se completa la misión"""
	if visible and GameManager.nivel_actual == 4:
		activo = false
		await get_tree().create_timer(2.0).timeout
		visible = false
		inicializado = false
		ya_verifico_inicio = false

func _on_nivel_reiniciado():
	"""Reiniciar reloj cuando se reinicia el nivel"""
	if GameManager.nivel_actual == 4:
		inicializado = false
		ya_verifico_inicio = false
		visible = false
		tiempo_actual = tiempo_total
		activo = false
		
		# Esperar un frame para que el GameManager termine de reiniciar
		await get_tree().process_frame
		
		# Si el juego ya está iniciado, activar el reloj
		if GameManager.juego_iniciado:
			inicializar_reloj()

func _on_game_over():
	"""Detener reloj en game over"""
	activo = false
	visible = false
	inicializado = false
	ya_verifico_inicio = false
