extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/hospital.tscn")
	
		


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/tristeza_v_2.tscn")


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://3dmodels/plantaelectrica.tscn")


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/niveles/abierto.tscn")
