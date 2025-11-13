@tool
class_name FlickerEffect
extends RichTextEffect

# Syntax: [flicker speed=5.0 intensity=0.3]
var bbcode = "flicker"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed: float = char_fx.env.get("speed", 5.0)
	var intensity: float = char_fx.env.get("intensity", 0.3)
	
	# Parpadeo con ruido aleatorio
	var flicker = 1.0 - intensity + sin(char_fx.elapsed_time * speed) * intensity * 0.5
	flicker += (sin(char_fx.elapsed_time * speed * 3.7) * 0.5 + 0.5) * intensity * 0.5
	
	char_fx.color.a *= flicker
	
	return true
