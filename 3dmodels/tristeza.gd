extends Node3D


func _ready() -> void:	
	$AnimationPlayer.play("misiones/Intro_2")
	await get_tree().create_timer(13.5).timeout
	cycle_animations()

func cycle_animations():
		var i := 1
		while true:
			var name := "%s%d" % ["misiones/Notification_", i]
			if not $AnimationPlayer.has_animation(name):
				break
			$AnimationPlayer.play(name)
			await $AnimationPlayer.animation_finished
			await get_tree().create_timer(1.0).timeout
			i += 1
