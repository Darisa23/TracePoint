extends Node
func _on_texture_button_pressed():
	$AnimationPlayer.play("popup_appear") 

func _on_button_pressed() -> void:
	$AnimationPlayer.play("popup_disappear") 
