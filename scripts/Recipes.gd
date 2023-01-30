class_name Recipes

static func get_recipes() -> Dictionary:
	var recipes = {}
	for recipe in load_json():
		recipes[get_hash(recipe.input)] = recipe.output
	return recipes


static func load_json() -> Array:
	var file = File.new()
	file.open('res://json/cards.json', file.READ)

	var text = file.get_as_text()
	return parse_json(text)


static func get_stack_id(head: Card):
	return get_hash(get_ids(head))


static func get_ids(head: Card):
	var ids = []
	_get_ids_rec(ids, head)
	ids.sort()
	return ids


static func _get_ids_rec(ids: Array, current_card: Card):
	ids.append(current_card.id)
	if current_card.next != null:
		_get_ids_rec(ids, current_card.next)
	


static func get_hash(ids: Array) -> String:
	var stack_hash = ''

	for i in ids.size():
		var card_id = ids[i]
		stack_hash += '%03d-' % card_id

	stack_hash = stack_hash.left(stack_hash.length() - 1)
	return stack_hash
