extends Node

var recipes: Dictionary

func _init():
	get_recipes_from_json()
	print('--- RECIPES LOADED ---')
	print()


func get_recipes_from_json():
	for recipe in load_json():
		recipe.stack.sort()
		recipes[get_hash(recipe.stack)] = recipe


func load_json() -> Array:
	var file = File.new()
	file.open('res://json/recipes.json', file.READ)

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
	if current_card and is_instance_valid(current_card):
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
