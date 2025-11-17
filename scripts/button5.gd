extends TextureButton

func _on_mouse_entered():
	$AnimationPlayer.play("5")

func _on_mouse_exited():
	$AnimationPlayer.play("5.1")

func _on_pressed():
	var path = "res://escenas/niveles/nivel_5_the_core.tscn"
	get_tree().change_scene_to_file(path)
