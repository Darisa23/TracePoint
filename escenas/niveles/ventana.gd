extends Control

# Referencias a los nodos hijos según tu estructura
@export var textura_popup: Texture2D
@onready var texture_rect = $TextureRect
@onready var label_max = $TextureRect/VBoxContainer/max
@onready var label_entregados = $TextureRect/VBoxContainer/entregados
@onready var label_actuales = $TextureRect/VBoxContainer/actuales
@onready var label_nodo = $TextureRect/VBoxContainer/nodo
@onready var boton_cerrar = $TextureRect/VBoxContainer/TextureButton
@onready var vbox = $TextureRect/VBoxContainer
@onready var flowm = $"../../FlowManager"
var nodo_actual_id: int = -1
var tiempo_visible: float = 0.0
var duracion_auto_cierre: float = 999999.0  # No se cierra automáticamente
var material_glitch: ShaderMaterial
# Variables para arrastrar
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var r_n : bool = false
func ini():
	# Ocultar el popup al inicio
	hide()
	# textura configurable
	if textura_popup:
		#print("Aplicí textura")
		texture_rect.texture = textura_popup
	# Crear material con shader de glitch
	vbox.visible = true
	var shader = load("res://escenas/niveles/ventana.gdshader")  # Ruta corregida
	GameManager.connect("nodo_visitado_correcto",_actualizar_popUp)
	GameManager.connect("mision_completada",cerrar_popup)
	if GameManager.nivel_actual == 4:		
		flowm.connect("entrega",_recibe)
		flowm.connect("sacar",_saca)
	await get_tree().create_timer(1).timeout
	#if GameManager.nivel_actual == 1:
	_actualizar_popUp(0)
	
	if shader:
		material_glitch = ShaderMaterial.new()
		material_glitch.shader = shader
		material = material_glitch
		#print("Shader de glitch cargado correctamente")
	else:
		push_error(" No se pudo cargar el shader. Verifica la ruta: res://escenas/niveles/ventana.gdshader")
	
	# Conectar señal del botón de cerrar si existe
	if boton_cerrar:
		boton_cerrar.pressed.connect(_on_boton_cerrar_pressed)
		# Hacer que el botón no bloquee el arrastre
		boton_cerrar.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# La posición se define desde el Inspector, no forzamos nada aquí
	
	# Habilitar input para arrastrar
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Asegurar que todos los labels no bloqueen el mouse
	if label_nodo:
		label_nodo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if label_max:
		label_max.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if label_entregados:
		label_entregados.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if label_actuales:
		label_actuales.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if texture_rect:
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta):
	# Manejar arrastre
	if dragging:
		global_position = get_global_mouse_position() - drag_offset
	

func _actualizar_popUp(id:int):
	#print("HOLA ME LLAMOOOO")
	if GameManager.nivel_actual==1 or GameManager.nivel_actual==4:
		#print("ke")
		mostrar_info_nodo(id)
	else:
		visible = false
		hide()
		
func _recibe(id : int):
	if label_entregados:
		await get_tree().create_timer(0.65).timeout
		label_entregados.text = "Entregados: " + str(GameManager.grafo.obtener_nodo(id).nodo_visual.paquetes_entregados[id])
func _saca(id : int):
	if label_actuales:
		var entre = GameManager.grafo.obtener_nodo(id).nodo_visual.paquetes_entregados[id]
		var act = entre-GameManager.grafo.obtener_nodo(id).nodo_visual.paquetes_actuales[id]
		await get_tree().create_timer(0.65).timeout
		label_actuales.text = "Actuales: " + str(act)
		
func mostrar_info_nodo(nodo_id: int):
	"""Muestra el popup con información del nodo visitado"""
	
	nodo_actual_id = nodo_id
	#Info depende del nivel:
	if GameManager.nivel_actual == 1:
		var datos = GameManager.info_nodos[nodo_actual_id+1]
		if label_nodo:		
			label_nodo.text = GameManager.nombre_nodos[nodo_actual_id]
	
		if label_max:
			label_max.text = "Estado: " + datos["estado"]
		if label_entregados:
			label_entregados.text = "Servicios: " + ", ".join(datos["servicios"])
		if label_actuales:
			label_actuales.text = "Log: " + datos["log"]
	# Obtener información del GameManager
	else:
		var capacidad = 0
		#if GameManager.capacidades_nodos.has(nodo_id):
			#capacidad = GameManager.capacidades_nodos[nodo_id]
		
		# Obtener nombre del nodo (A, B, C, etc.)
		var nombre_nodo = char(65 + nodo_id)  # 65 = 'A' en ASCII
		
		# Actualizar textos según tu estructura
		if label_nodo:
			label_nodo.text = "Nodo: " + nombre_nodo
		
		if label_max:
			label_max.text = "Máximo: " + str(GameManager.flujo_maximo_calculado)
		
		#if label_entregados:
		var entre = GameManager.grafo.obtener_nodo(nodo_id).nodo_visual.paquetes_entregados[nodo_id]
		#print("ENTRE PRIMERO ES: ",entre)
		label_entregados.text = "Entregados: " + str(entre)
		
		if label_actuales:
			var act = entre-GameManager.grafo.obtener_nodo(nodo_id).nodo_visual.paquetes_actuales[nodo_id]
			label_actuales.text = "Actuales: " + str(act)
	
	# Mostrar el popup con animación
	show()
	mostrar_animacion()

func mostrar_animacion():
	"""Animación de entrada del popup con efecto glitch"""
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	
	# Activar glitch al máximo al inicio
	if material_glitch:
		material_glitch.set_shader_parameter("glitch_intensity", 1.0)
		material_glitch.set_shader_parameter("chromatic_aberration", 0.05)
		material_glitch.set_shader_parameter("noise_amount", 0.5)
		material_glitch.set_shader_parameter("scan_line_speed", 5.0)
		#print("Parámetros de glitch activados")
	
	
	# Crear tween para animar
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Reducir el glitch gradualmente
	if material_glitch:
		var tween_glitch = create_tween()
		tween_glitch.tween_method(
			func(value): material_glitch.set_shader_parameter("glitch_intensity", value),
			1.0, 0.3, 0.8
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
		tween_glitch.tween_method(
			func(value): material_glitch.set_shader_parameter("chromatic_aberration", value),
			0.05, 0.015, 0.8
		)

func cerrar_popup():
	"""Cierra el popup con animación y glitch final"""
	# Reactivar glitch al cerrar
	print("DIJERON CERRAR")
	if material_glitch:
		var tween_glitch = create_tween()
		tween_glitch.tween_method(
			func(value): material_glitch.set_shader_parameter("glitch_intensity", value),
			0.2, 1.0, 0.2
		)
		
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.3)
	tween.finished.connect(func(): hide())

func _on_boton_cerrar_pressed():
	"""Maneja el cierre manual del popup"""
	cerrar_popup()

# Detectar inicio de arrastre
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Verificar que NO esté sobre el botón de cerrar
				if boton_cerrar and boton_cerrar.get_global_rect().has_point(get_global_mouse_position()):
					return  # Dejar que el botón maneje el click
				
				# Iniciar arrastre
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
			else:
				# Soltar
				dragging = false

func _input(event: InputEvent):
	# Manejar el evento de soltar el mouse globalmente
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false

# Función para ser llamada desde el script del jugador o nodo
func actualizar_desde_nodo(nodo_id: int):
	"""Método público para actualizar y mostrar el popup"""
	mostrar_info_nodo(nodo_id)
