extends TextureButton

func _on_mouse_entered():
	$AnimationPlayer.play("1")

func _on_mouse_exited():
	$AnimationPlayer.play("1.1")

func _on_pressed():
	var path = "res://escenas/niveles/nivel_1_network_tracer.tscn"
	get_tree().change_scene_to_file(path)
