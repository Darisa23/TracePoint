extends Node3D

@onready var anim = $AnimationPlayer

func _ready():
	anim.play("Intro")
	await get_tree().create_timer(13.5).timeout
	cycle_animations()

	


func cycle_animations():
		var i := 1
		while true:
			var name := "%s%d" % ["Notification_", i]
			if not anim.has_animation(name):
				break
			anim.play(name)
			await anim.animation_finished
			await get_tree().create_timer(1.0).timeout
			i += 1
