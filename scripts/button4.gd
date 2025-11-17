extends TextureButton

func _on_mouse_entered():
	$AnimationPlayer.play("4")

func _on_mouse_exited():
	$AnimationPlayer.play("4.1")

func _on_pressed():
	var path = "res://escenas/niveles/nivel_4_flow_control.tscn"
	get_tree().change_scene_to_file(path)
