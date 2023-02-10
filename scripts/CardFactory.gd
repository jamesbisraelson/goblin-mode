extends Node

onready var Card = preload('res://scenes/Card.tscn')

var card_types: Dictionary

func _init():
	get_card_types_from_json()
	print('--- CARD TYPES LOADED ---')
	print(card_types)
	print()

func get_random_card_id():
	var keys = card_types.keys()
	return card_types[keys[randi() % keys.size()]].id

# WIP: make a card stack from an array of cards
# func new_stack(cards: Array) -> Card:
# 	var stack: Card = null
# 	var current = null

# 	for card in cards:
# 		if stack == null:
# 			stack = card
# 			current = card
# 		else:
# 			current.next = card
# 			card.prev = current
# 			current = current.next
# 	return stack


func new_card(id: int) -> Card:
	var card_info = card_types[id]
	return Card.instance().init(card_info.id, card_info.title, card_info.cost, card_info.card_back, card_info.icon, card_info.type)

func get_card_types_from_json():
	for card in load_json():
		card_types[int(card.id)] = card

func load_json() -> Array:
	var file = File.new()
	file.open('res://json/cards.json', file.READ)

	var text = file.get_as_text()
	return parse_json(text)
