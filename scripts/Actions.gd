class_name Actions extends ProgressBar

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
	connect('action_created', get_tree().get_current_scene(), '_action_created')
	connect('action_completed', get_tree().get_current_scene(), '_action_completed')
	connect('remove_item', get_tree().get_current_scene(), '_remove_item')
	connect('add_item', get_tree().get_current_scene(), '_add_item')

	emit_signal('action_created', stack)

func init(stack: Card, stacks: Array, actions: Array, time_to_complete: float):
	self.stack = stack
	self.stacks = stacks.duplicate()
	self.actions = actions.duplicate()
	self.time_to_complete = time_to_complete


	time_elapsed = 0.0
	stack_id = RecipeFactory.get_stack_id(stack)
	stack.progress_bar_pos.add_child(self)
	return self

func _process(delta):
	if stack_id != RecipeFactory.get_stack_id(stack.get_head()):
		emit_signal('action_completed', stack)
		queue_free()

	time_elapsed += delta
	if time_elapsed >= time_to_complete:
		for action in actions:
			call(action[0], action[1])
		emit_signal('action_completed', stack)
		queue_free()
	
	value = time_elapsed / time_to_complete * 100


func delete(card_ids: Array):
	for id in card_ids:
		var card = get_card_in_stack(id)
		break_connection(card)
		emit_signal('remove_item', card)

func add(card_ids: Array):
	for id in card_ids:
		emit_signal('add_item', CardFactory.new_card(id), stack.global_position, Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized() * 150.0)

func replace(card_ids: Array):
	var old_card_id = card_ids[0]
	var new_card_id = card_ids[1]
	var new_card = CardFactory.new_card(new_card_id)
	var old_card = get_card_in_stack(old_card_id)

	# TODO: make this better so that it doesn't flip the cards
	break_connection(old_card)
	emit_signal('remove_item', old_card)
	emit_signal('add_item', new_card, stack.global_position, Vector2.ZERO)
	get_tree().get_current_scene()._drop_card(new_card, stack)

func get_card_in_stack(id: int) -> Card:
	var current = stack
	while current != null and is_instance_valid(current):
		if current.id == id:
			break
		current = current.next
	return current


func break_connection(card: Card):
	if card.next == null and card.prev == null:
		return
	elif card.next == null:
		card.prev.next = null
	elif card.prev == null:
		card.next.prev = null
		stack = card.next
	else:
		card.prev.next = card.next
		card.next.prev = card.prev
