extends Control

@onready var titles := {
	1: $Titulo1NetworkTracer,
	2: $Titulo2SafeRoute,
	3: $Titulo3RebuildNet,
	4: $Titulo4FlowControl
}

	
func show_level(level: int) -> void:
	# Ocultar todos primero (máxima seguridad)
	for t in titles.values():
		t.visible = false

	# Activar el que corresponde
	var title = titles.get(level)
	if not title:
		print("Error: no existe título para nivel ", level)
		return
	
	title.visible = true

	# Si tiene AnimationPlayer, lo corremos
	var anim = title.get_node_or_null("AnimationPlayer")
	if anim:
		anim.play("Title")
		await anim.animation_finished
		title.visible = false
	else:
		# Si no tiene animación, lo mostramos 2 segundos y lo apagamos
		await get_tree().create_timer(2.0).timeout
		title.visible = false
