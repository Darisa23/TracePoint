extends Panel

@onready var sprite = $Sprite2D

func _ready():
	# Asegurarnos que el sprite tenga el material del shader
	if sprite.material == null:
		var shader_material = ShaderMaterial.new()
		shader_material.shader = preload("res://scripts/hrt.gdshader")
		sprite.material = shader_material
	
	# Inicializar los parámetros del shader en 0
	sprite.material.set_shader_parameter("glitch_strength", 0.0)

func update(whole: bool):
	if whole:
		sprite.frame = 0
	else:
		# Cambiar el frame PRIMERO
		sprite.frame = 1
		# Luego activar el efecto glitch sobre el corazón perdido
		play_glitch_effect()

func play_glitch_effect():
	var material = sprite.material as ShaderMaterial
	
	if material == null:
		print("ERROR: No hay material shader asignado")
		return
	
	# Crear tween para animar el shader
	var tween = create_tween()
	
	# Subir el glitch rápidamente
	tween.tween_method(set_glitch_strength, 0.0, 1.0, 0.08)
	# Mantener un momento
	tween.tween_interval(0.05)
	# Segundo pulso
	tween.tween_method(set_glitch_strength, 1.0, 0.3, 0.1)
	tween.tween_method(set_glitch_strength, 0.3, 0.8, 0.08)
	# Bajar gradualmente
	tween.tween_method(set_glitch_strength, 0.8, 0.0, 0.25)

func set_glitch_strength(value: float):
	if sprite.material:
		sprite.material.set_shader_parameter("glitch_strength", value)
		# Debug para ver si está funcionando
		print("Glitch strength: ", value)
