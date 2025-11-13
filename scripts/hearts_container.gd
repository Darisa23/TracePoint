extends HBoxContainer

func update_hearts(currentHealth):
	var hearts = get_children()
	for i in hearts:
		i.update(true)
	for i in range(currentHealth,hearts.size()):
		hearts[i].update(false)
