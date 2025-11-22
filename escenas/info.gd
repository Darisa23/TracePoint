extends TextureButton

# Nombres de los nodos de instrucciones en el HUD
var nodos_instrucciones = {
	1: "instrucciones1",
	2: "instrucciones2",
	3: "instrucciones3",
	4: "instrucciones4",
	5: "instrucciones5"
}

# Panel actual abierto
var panel_actual: Control = null

func _ready():
	print("Botón de instrucciones inicializado")
	print("Nombre del botón: ", name)
	print("Tipo: ", get_class())
	print("Ruta del nodo: ", get_path())
	
	# Desactivar el foco visual del botón
	focus_mode = Control.FOCUS_NONE
	
	# Asegurarse de que no esté en toggle mode
	if self is TextureButton :
		toggle_mode = false
		button_pressed = false
	
	print("Toggle mode: ", toggle_mode)
	
	# Conectar la señal de múltiples formas para asegurar
	if not button_down.is_connected(_on_button_pressed):
		button_down.connect(_on_button_pressed)
		print("✓ Señal button_down conectada")
	
	if not pressed.is_connected(_on_button_pressed):
		pressed.connect(_on_button_pressed)
		print("✓ Señal pressed conectada")
	
	# Ocultar todos los paneles al inicio
	ocultar_todos_paneles()

func _on_button_pressed():
	print("=== BOTÓN PRESIONADO (via señal) ===")
	
	# Liberar el estado pressed del botón inmediatamente
	release_focus()
	
	if panel_actual and panel_actual.visible:
		# Si hay un panel abierto, cerrarlo
		print("Cerrando panel...")
		cerrar_panel()
	else:
		# Si no hay panel, abrir el correspondiente al nivel actual
		print("Abriendo panel...")
		abrir_panel()

func _input(event):
	# Presionar ESC para liberar/capturar el cursor (solo si no hay panel abierto)
	if event.is_action_pressed("ui_cancel"):
		# Si hay un panel abierto, cerrar el panel en lugar de capturar cursor
		if panel_actual and panel_actual.visible:
		#	print("ESC presionado - Cerrando panel")
			cerrar_panel()
			get_viewport().set_input_as_handled()  # Marcar el input como manejado
			return
		
		#print("ESC presionado")
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#	print("Cursor liberado")
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#	print("Cursor capturado")

func ocultar_todos_paneles():
	var hud = get_tree().current_scene.find_child("HUD", true, false)
	if not hud:
		return
	
	for nombre in nodos_instrucciones.values():
		var panel = hud.find_child(nombre, false, false)
		if panel:
			panel.visible = false
			#print("Panel ", nombre, " oculto al inicio")

func abrir_panel():
	
	# Obtener el nivel actual desde GameManager
	var nivel = GameManager.nivel_actual
	print("Nivel actual: ", nivel)
	
	# Verificar si existe un nodo para este nivel
	if not nodos_instrucciones.has(nivel):
		print("❌ No hay instrucciones para el nivel ", nivel)
		print("Niveles disponibles: ", nodos_instrucciones.keys())
		return
	
	#print("✓ Nivel encontrado en diccionario")
	
	# Buscar el HUD
	#print("Buscando HUD en la escena...")
	var hud = get_tree().current_scene.find_child("HUD", true, false)
	if not hud:
		push_error("No se encontró el nodo HUD")
		return
	
	#print("✓ HUD encontrado: ", hud.get_path())
	
	# Buscar el panel de instrucciones
	var nombre_panel = nodos_instrucciones[nivel]
	print("Buscando panel con nombre: ", nombre_panel)
	panel_actual = hud.find_child(nombre_panel, false, false)
	
	if not panel_actual:
		push_error("❌ No se encontró el panel: ", nombre_panel)
		#print("Hijos del HUD:")
		for child in hud.get_children():
			print("  - ", child.name, " (", child.get_class(), ")")
		return
	
	#print("✓ Panel encontrado: ", panel_actual.name)
	
	# Liberar el cursor para poder interactuar con el panel
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#print("✓ Cursor liberado")
	
	# Hacer visible el panel
	panel_actual.visible = true
	#print("✓ Panel visible")
	
	# Buscar el AnimationPlayer
	var anim_player: AnimationPlayer = null
	for child in panel_actual.get_children():
		if child is AnimationPlayer:
			anim_player = child
			break
	
	#print("AnimationPlayer encontrado: ", anim_player != null)
	
	if anim_player:
		#print("Animaciones disponibles: ", anim_player.get_animation_list())
		if anim_player.has_animation("popup_appear"):
			#print("Reproduciendo animación 'popup_appear'")
			anim_player.play("popup_appear")
			await anim_player.animation_finished
			#print("Animación finalizada")
		elif anim_player.has_animation("scale"):
			#print("Reproduciendo animación 'scale'")
			anim_player.play("scale")
			await anim_player.animation_finished
			#print("Animación finalizada")
		else:
			print("No se encontró ninguna animación de apertura")
	else:
		print("No se encontró AnimationPlayer")
	
	# Buscar el botón de cerrar
	var boton_cerrar: BaseButton = null
	for child in panel_actual.get_children():
		if child is Control:
			boton_cerrar = child.find_child("Button", false, false)
			if boton_cerrar:
				break
	
	#print("Botón cerrar encontrado: ", boton_cerrar != null)
	
	if boton_cerrar and boton_cerrar is BaseButton:
		# Desactivar el foco visual del botón de cerrar también
		boton_cerrar.focus_mode = Control.FOCUS_NONE
		
		# Asegurarse de que no esté en toggle mode
		boton_cerrar.toggle_mode = false
		boton_cerrar.button_pressed = false
		
		# Desconectar si ya estaba conectado
		if boton_cerrar.pressed.is_connected(_on_cerrar_pressed):
			boton_cerrar.pressed.disconnect(_on_cerrar_pressed)
		
		boton_cerrar.pressed.connect(_on_cerrar_pressed)
		#print("Botón cerrar conectado (toggle mode: ", boton_cerrar.toggle_mode, ")")
	else:
		print("No se encontró el botón cerrar")

func cerrar_panel():
	if not panel_actual:
		#print("⚠️ No hay panel para cerrar")
		return
	
	# Buscar el AnimationPlayer
	var anim_player: AnimationPlayer = null
	for child in panel_actual.get_children():
		if child is AnimationPlayer:
			anim_player = child
			break
	
	#print("AnimationPlayer encontrado: ", anim_player != null)
	
	if anim_player and anim_player.has_animation("popup_disappear"):
		#print("Reproduciendo animación 'popup_disappear'")
		anim_player.play("popup_disappear")
		await anim_player.animation_finished
		#print("Animación de cierre finalizada")
	elif anim_player and anim_player.has_animation("modulate"):
		#print("Reproduciendo animación 'modulate'")
		anim_player.play("modulate")
		await anim_player.animation_finished
		#print("Animación de cierre finalizada")
	else:
		print("No se encontró AnimationPlayer o animación de cierre")
	
	# Ocultar el panel DESPUÉS de la animación
	panel_actual.visible = false
	panel_actual = null
	
	# Capturar el cursor nuevamente
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_cerrar_pressed():
	
	# Liberar el estado pressed del botón de cerrar
	if panel_actual:
		var boton_cerrar: BaseButton = null
		for child in panel_actual.get_children():
			if child is Control:
				boton_cerrar = child.find_child("Button", false, false)
				if boton_cerrar:
					boton_cerrar.release_focus()
					break
	
	cerrar_panel()
