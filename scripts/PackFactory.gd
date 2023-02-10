extends Node

onready var Pack = preload('res://scenes/Pack.tscn')

var packs: Dictionary

func _init():
	get_pack_types_from_json()
	print('--- Pack TYPES LOADED ---')
	print(packs)
	print()


func get_cost(id: int) -> int:
	return packs[id].cost

func new_pack(id: int) -> Pack:
	var pack_info = packs[id]
	return Pack.instance().init(
		pack_info.id,
		pack_info.title,
		pack_info.icon,
		pack_info.pack_back,
		pack_info.num_cards,
		pack_info.card_ids,
		pack_info.random
	)


func get_pack_types_from_json():
	for pack in load_json():
		packs[int(pack.id)] = pack


func load_json() -> Array:
	var file = File.new()
	file.open('res://json/packs.json', file.READ)

	var text = file.get_as_text()
	return parse_json(text)
