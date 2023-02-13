class_name SellStack extends Sprite

onready var area2d: Area2D = $Area2D

signal add_item

func _ready():
	connect('add_item', get_parent(), '_add_item')


func _get_stack_valid(stack: Card):
	var valid = true
	var current = stack
	while valid and current != null and is_instance_valid(current):
		if current.type == 'goblin' or current.type == 'corpse':
			valid = false
		current = current.next
	return valid


func _get_stack_cost(stack: Card):
	var total = 0
	var current = stack
	while current != null and is_instance_valid(current):
		total += current.cost
		current = current.next
	return total

func sell(stack: Card):
	var cost = _get_stack_cost(stack)
	var cards = []
	for i in cost:
		var card = CardFactory.new_card(500)
		cards.append(card)
		emit_signal('add_item', card, global_position, Vector2(rand_range(-0.25, 0.25), rand_range(0, 1)).normalized() * 150.0)
	
	for i in range(1, len(cards)):
		#TODO: do this with signals
		get_tree().get_current_scene()._drop_card(cards[i], cards[i-1])
