class_name BuyStack extends Sprite

export var pack_id: int

onready var area2d: Area2D = $Area2D

signal add_item

func init(pack_id):
	self.pack_id = pack_id

func _ready():
    connect('add_item', get_parent(), '_add_item')

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
	if _get_stack_valid(stack) and _get_stack_cost(stack) >= PackFactory.get_cost(pack_id):
		var pack = PackFactory.new_pack(pack_id)
		emit_signal('add_item', pack, global_position, Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 150.0)