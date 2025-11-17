extends TextureButton

func _on_mouse_entered():
	$AnimationPlayer.play("2")

func _on_mouse_exited():
	$AnimationPlayer.play("2.1")

func _on_pressed():
	var path = "res://escenas/niveles/nivel_2_safe_route.tscn"
	get_tree().change_scene_to_file(path)
