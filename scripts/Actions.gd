class_name Actions extends Node2D

var stack: Card
var stack_id: String
var stacks: Array
var actions: Array
var time_to_complete: float
var time_elapsed: float

signal action_created
signal action_completed
signal remove_item
signal add_item

func _ready():
	connect('action_created', get_parent(), '_action_created')
	connect('action_completed', get_parent(), '_action_completed')
	connect('remove_item', get_parent(), '_remove_item')
	connect('add_item', get_parent(), '_add_item')

	emit_signal('action_created', stack)

func _init(stack: Card, stacks: Array, actions: Array, time_to_complete: float):
	self.stack = stack
	self.stacks = stacks
	self.actions = actions
	self.time_to_complete = time_to_complete

	time_elapsed = 0.0
	z_index = 2

	position = stack.position
	stack_id = RecipeFactory.get_stack_id(stack)

func _process(delta):
	global_position = stack.global_position - Vector2(0, 275)
	if stack_id != RecipeFactory.get_stack_id(stack):
		emit_signal('action_completed', stack)
		queue_free()

	time_elapsed += delta
	if time_elapsed >= time_to_complete:
		for action in actions:
			call(action[0], action[1])
		emit_signal('action_completed', stack)
		queue_free()
	update()


func _draw():
	var background_rect = Rect2(Vector2(-150, 0), Vector2(300, 50))
	var loading_rect = Rect2(Vector2(-145, 5), Vector2(290 * (time_elapsed/time_to_complete), 40))
	draw_rect(background_rect, Color('141414'))
	draw_rect(loading_rect, Color.white)


func delete(card_ids: Array):
	for id in card_ids:
		var card = get_card_in_stack(id)
		if card.next == null:
			card.prev.next = null
		elif card.prev == null:
			card.next.prev = null
			stack = card.next
		else:
			card.prev.next = card.next
			card.next.prev = card.prev
		emit_signal('remove_item', card)

func add(card_ids):
	for id in card_ids:
		emit_signal('add_item', CardFactory.new_card(id), stack.global_position, Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 150.0)

func get_card_in_stack(id: int) -> Card:
	var current = stack
	while current != null:
		if current.id == id:
			break
		current = current.next
	return current
