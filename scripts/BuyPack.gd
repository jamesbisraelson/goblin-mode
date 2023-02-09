class_name BuyPack extends Sprite

export var pack_id: int
var pack_cost: int

onready var area2d: Area2D = $Area2D

signal add_item
signal remove_item

func _ready():
	self.pack_cost = PackFactory.get_cost(pack_id)


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

	while pack_cost > 0:
		pack_cost -= 1
		stack_cost -= 1
	
	var pack = PackFactory.new_pack(pack_id)
	emit_signal("add_item", pack, global_position, Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 150.0)

	for i in stack_cost - 1:
		var card = CardFactory.new_card(500)
		emit_signal('add_item', card, global_position, Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 150.0)
			
