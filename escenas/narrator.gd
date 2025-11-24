extends Control
@onready var label := $RichTextLabel

func _ready():
	label.bbcode_enabled = true
	label.visible_characters = 0
	type_text()

func type_text():
	while label.visible_characters < label.get_total_character_count():
		label.visible_characters += 1
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(5.0).timeout
	untype_text()

func untype_text():
	while label.visible_characters > 0:
		label.visible_characters -= 1
		await get_tree().create_timer(0.05).timeout
