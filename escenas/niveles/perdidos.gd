extends Label

var paquetes_perdidos: int = 0
var max_paquetes_perdidos: int = 3
var inicializado: bool = false
var ya_verifico_inicio: bool = false
var tween_parpadeo: Tween = null
@onready var  flm = $"../../FlowManager"
func _ready():
	
	# Ocultar por defecto
	visible = false
	
	# Configurar estilo por defecto
	configurar_estilo_defecto()
	
	# Conectar señales del GameManager
	flm.connect("paquetes_perdidos_actualizado", _on_paquete_perdido)
	GameManager.connect("mision_completada", _on_mision_completada)
	GameManager.connect("nivel_reiniciado", _on_nivel_reiniciado)
	GameManager.connect("game_over", _on_game_over)
	
	print("Señales conectadas con GameManager")

func configurar_estilo_defecto():
	"""Configura el estilo visual del label"""
	# Color de texto blanco por defecto
	add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))  # #FFFFFF
	
	# Sombra: #008E86 con alpha A1 (convertido: 0.631)
	var shadow_color = Color(0.0, 0.557, 0.525, 0.631)  # #008E86A1
	add_theme_color_override("font_shadow_color", shadow_color)
	add_theme_constant_override("shadow_offset_x", 2)
	add_theme_constant_override("shadow_offset_y", 2)
	
	# Outline: #00BEFE con alpha E7 (convertido: 0.906)
	var outline_color = Color(0.0, 0.745, 0.996, 0.906)  # #00BEFEE7
	add_theme_color_override("font_outline_color", outline_color)
	add_theme_constant_override("outline_size", 4)

func _process(_delta):
	# SOLO verificar UNA VEZ cuando el juego se inicia
	if not ya_verifico_inicio and not inicializado:
		if GameManager.nivel_actual == 4 and GameManager.juego_iniciado:
			#print("\n_process detectó que el nivel 4 inició - Activando label paquetes")
			inicializar_label()
			ya_verifico_inicio = true
	
	# Ocultar si ya no estamos en nivel 4
	if GameManager.nivel_actual != 4 and visible:
		visible = false
		inicializado = false
		ya_verifico_inicio = false
		print("Label paquetes ocultado - Ya no estamos en nivel 4")

func inicializar_label():
	if inicializado:
		return
	
	# Resetear paquetes
	paquetes_perdidos = 0
	inicializado = true
	visible = true
	
	actualizar_label()

func actualizar_label():
	"""Actualiza el label de paquetes perdidos con color dinámico"""
	
	# Actualizar texto
	text = "Paquetes perdidos: %d/%d" % [paquetes_perdidos, max_paquetes_perdidos]
	
	# Calcular color basado en proximidad al límite
	var color_final: Color
	
	if paquetes_perdidos == 0:
		# Blanco seguro (color por defecto)
		color_final = Color(1.0, 1.0, 1.0, 1.0)  # #FFFFFF
	elif paquetes_perdidos == 1:
		# Amarillo - Advertencia
		color_final = Color(1.0, 1.0, 0.0, 1.0)  # Amarillo
	elif paquetes_perdidos == 2:
		# Naranja - Peligro
		color_final = Color(1.0, 0.5, 0.0, 1.0)  # Naranja
	else:
		# Rojo - Crítico (último paquete)
		color_final = Color(1.0, 0.0, 0.0, 1.0)  # Rojo
	
	# Aplicar color al texto
	add_theme_color_override("font_color", color_final)
	
	# Detener parpadeo anterior si existe
	if tween_parpadeo:
		tween_parpadeo.kill()
		modulate.a = 1.0
	
	# Efecto de parpadeo cuando está en 3
	if paquetes_perdidos >= max_paquetes_perdidos:
		tween_parpadeo = create_tween()
		tween_parpadeo.set_loops()
		tween_parpadeo.tween_property(self, "modulate:a", 0.3, 0.5)
		tween_parpadeo.tween_property(self, "modulate:a", 1.0, 0.5)
	
	#print("Paquetes actualizados: %d/%d" % [paquetes_perdidos, max_paquetes_perdidos])

func _on_paquete_perdido():
	"""Se llama cuando se pierde un paquete (nodo incorrecto)"""
	#if not visible or not inicializado:
		#return
	#print("LLEGO HASTA ACA BABY")
	paquetes_perdidos += 1
	#print("Paquete perdido! Total: %d/%d" % [paquetes_perdidos, max_paquetes_perdidos])
	
	actualizar_label()
	
	# El GameManager ya maneja el game over con perder_vida()

func _on_mision_completada():
	"""Ocultar cuando se completa la misión"""
	if visible and GameManager.nivel_actual == 4:
		#print("✓ Misión completada - Label paquetes oculto")
		await get_tree().create_timer(2.0).timeout
		visible = false
		inicializado = false
		ya_verifico_inicio = false

func _on_nivel_reiniciado():
	"""Reiniciar cuando se reinicia el nivel"""
	if GameManager.nivel_actual == 4:
		inicializado = false
		ya_verifico_inicio = false
		visible = false
		paquetes_perdidos = 0
		
		# Detener parpadeo si existe
		if tween_parpadeo:
			tween_parpadeo.kill()
		modulate.a = 1.0
		
		# Esperar un frame para que el GameManager termine de reiniciar
		await get_tree().process_frame
		
		# Si el juego ya está iniciado, activar el label
		if GameManager.juego_iniciado:
			inicializar_label()

func _on_game_over():
	"""Detener en game over"""
	visible = false
	inicializado = false
	ya_verifico_inicio = false
	
	if tween_parpadeo:
		tween_parpadeo.kill()
