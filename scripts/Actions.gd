class_name Actions extends Node

var stack: Card
var stack_id: String
var stacks: Array
var actions: Array
var time: float

signal action_completed
signal remove_card
signal add_card

func _ready():
	connect('action_completed', get_parent(), 'on_action_completed')
	connect('remove_card', get_parent(), 'on_remove_card')
	connect('add_card', get_parent(), 'on_add_card')

func _init(stack: Card, stacks: Array, actions: Array, time: float):
	self.stack = stack
	self.stacks = stacks
	self.actions = actions
	self.time = time
	stacks.remove(stacks.find(stack))
	stack_id = RecipeFactory.get_stack_id(stack.get_head())

func _process(delta):
	if stack_id != RecipeFactory.get_stack_id(stack.get_head()):
		emit_signal('action_completed', stack)
		queue_free()

	time -= delta
	if time <= 0:
		for action in actions:
			call(action[0], action[1])
		emit_signal('action_completed', stack)
		queue_free()

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
		emit_signal('remove_card', card)

func add(card_ids):
	for id in card_ids:
		emit_signal('add_card', CardFactory.new_card(id))

func get_card_in_stack(id: int) -> Card:
	var current = stack
	while current != null:
		if current.id == id:
			break
		current = current.next
	return current
