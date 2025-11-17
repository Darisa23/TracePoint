extends CanvasLayer


func _on_start_pressed() -> void:
	if has_node("/root/TransitionManager"):
		get_node("/root/TransitionManager").transicion_a_hub()
	else:
		get_tree().change_scene_to_file("res://escenas/TracePoint.tscn")


func _on_exit_pressed() -> void:
	print("bye bye...")
	get_tree().quit()


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/controls.tscn")
