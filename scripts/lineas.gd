extends Node2D

const LINE_COUNT = 80

var lines = []

func _ready():
	randomize()
	for i in LINE_COUNT:
		lines.append({
			"x": randf_range(0.0, get_viewport_rect().size.x),
			"y": randf_range(0.0, get_viewport_rect().size.y),
			"z": randf_range(0.2, 1.0), # profundidad falsa (0.2=lejos, 1=cerca)
			"speed": randf_range(30.0, 120.0)
		})

func _process(delta):
	for l in lines:
		l.y += l.speed * delta * l.z
		if l.y > get_viewport_rect().size.y:
			l.y = 0
			l.x = randf_range(0.0, get_viewport_rect().size.x)
			l.z = randf_range(0.2, 1.0)
	update()

func _draw():
	for l in lines:
		var depth_color = Color(0.3, 0.7, 1.0, lerp(0.2, 0.9, l.z)) # más brillante = más cerca
		var length = lerp(20.0, 80.0, l.z)
		draw_line(Vector2(l.x, l.y), Vector2(l.x, l.y - length), depth_color, lerp(1.0, 3.0, l.z))
