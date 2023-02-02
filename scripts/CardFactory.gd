extends Node

onready var Card = preload('res://scenes/Card.tscn')

var card_types: Dictionary

func _init():
	get_card_types()
	print('--- CARD TYPES LOADED ---')
	print(card_types)
	print()

func new_card(id: int) -> Card:
	var card_info = card_types[id]
	return Card.instance().init(card_info.id, card_info.title, card_info.icon, card_info.type)

func get_card_types():
	for card in load_json():
		card_types[int(card.id)] = card


func load_json() -> Array:
	var file = File.new()
	file.open('res://json/cards.json', file.READ)

	var text = file.get_as_text()
	return parse_json(text)
