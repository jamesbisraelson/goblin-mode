class_name BuyPack extends Sprite

export var pack_id: int
var pack_cost: int

onready var area2d: Area2D = $Area2D

signal add_item
signal remove_item

func _ready():
	self.pack_cost = PackFactory.packs[pack_id].cost
	$TitlePosition/Title.text = PackFactory.packs[pack_id].title
	$CostPosition/Cost.text = str(pack_cost) + (' coins' if pack_cost != 1 else ' coins')

	connect('add_item', get_parent(), '_add_item')
	connect('remove_item', get_parent(), '_remove_item')

func _get_stack_cost(stack: Card):
	var total = 0
	var current = stack
	while current != null:
		total += current.cost
		current = current.next
	return total

func _get_stack_valid(stack: Card):
	var valid = true
	var current = stack
	while valid and current != null:
		if current.id != 500:
			valid = false
		current = current.next
	return valid

func buy(stack: Card):
	var stack_cost = _get_stack_cost(stack)

	while pack_cost > 0 and stack_cost > 0:
		pack_cost -= 1
		stack_cost -= 1

	if pack_cost == 0:
		pack_cost = PackFactory.packs[pack_id].cost
		var pack = PackFactory.new_pack(pack_id)
		emit_signal("add_item", pack, global_position, Vector2(rand_range(-0.5, 0.5), rand_range(0, 1)).normalized() * 150.0)

	var cards = []
	for i in stack_cost:
		var card = CardFactory.new_card(500)
		cards.append(card)
		emit_signal('add_item', card, global_position, Vector2(rand_range(-0.5, 0.5), rand_range(0, 1)).normalized() * 150.0)
	
	for i in range(1, len(cards)):
		#TODO: do this with signals
		get_tree().get_current_scene()._drop_card(cards[i], cards[i-1])

	$CostPosition/Cost.text = str(pack_cost) + (' coins' if pack_cost != 1 else ' coins')			
