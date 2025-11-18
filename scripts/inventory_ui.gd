extends PanelContainer

@onready var container := $HBoxContainer
@export var item_scene: PackedScene  # inventory_item_ui.tscn

var item_count := 0
var item_node: Panel = null


func add_item(icon: Texture):

	if item_node == null:
		# Crear primer slot
		item_node = item_scene.instantiate()
		container.add_child(item_node)

		# Poner icono solo la primera vez
		item_node.get_node("TextureRect").texture = icon

	# Aumentar stack
	item_count += 1
	item_node.get_node("Label").text = str(item_count)


func remove_item():
	if item_count == 0:
		return

	item_count -= 1

	if item_count <= 0:
		item_node.queue_free()
		item_node = null
	else:
		item_node.get_node("Label").text = str(item_count)


func clear_items():
	item_count = 0
	if item_node:
		item_node.queue_free()
		item_node = null
