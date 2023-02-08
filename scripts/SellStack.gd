class_name SellStack extends Sprite

signal add_item

func _ready():
    connect('add_item', get_parent(), '_add_item')

func _get_stack_cost(stack: Card):
	var total = 0
	var current = stack
	while current != null:
		total += current.cost
		current = current.next
	return total

func sell(stack: Card):
	var cost = _get_stack_cost(stack)
	for i in cost:
		var card = CardFactory.new_card(500)
		emit_signal('add_item', card, global_position, Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 150.0)