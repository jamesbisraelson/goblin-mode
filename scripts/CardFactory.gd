extends Node

onready var Card = preload('res://scenes/Card.tscn')

var card_ids: Dictionary
var card_types: Dictionary
var json: Array

func _init():
	json = load_json()
	get_card_ids_from_json()
	print('--- CARD IDS LOADED ---')
	print()

	get_card_types_from_json()
	print('--- CARD TYPES LOADED ---')
	print()


func get_random_card_id():
	var keys = card_ids.keys()
	return card_ids[keys[randi() % keys.size()]].id


func new_card(id: int) -> Card:
	var card_info = card_ids[id]
	return Card.instance().init(card_info.id, card_info.title, card_info.cost, card_info.card_back, card_info.icon, card_info.type)


func get_card_ids_from_json():
	for card in json:
		card_ids[int(card.id)] = card


func get_card_types_from_json():
	for card in json:
		card_types[card.type] = card_types.get(card.type, [])
		card_types[card.type].append(card.id)

func load_json() -> Array:
	var file = File.new()
	file.open('res://json/cards.json', file.READ)

	var text = file.get_as_text()
	return parse_json(text)


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
