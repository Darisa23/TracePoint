extends TextureButton

func _on_mouse_entered():
	$AnimationPlayer.play("3")

func _on_mouse_exited():
	$AnimationPlayer.play("3.1")

func _on_pressed():
	var path = "res://escenas/niveles/nivel_3_rebuild_net.tscn"
	get_tree().change_scene_to_file(path)
