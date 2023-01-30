extends Node2D

var recipes: Dictionary
var held_card: Card
var cards: Array
var stacks: Array
var count = 0

signal cards_changed

onready var Card = preload('res://scenes/Card.tscn')


func _ready():
	held_card = null
	stacks = []

	# populate recipes
	recipes = Recipes.get_recipes()
	connect('cards_changed', self, 'on_cards_changed')


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if not event.pressed and held_card != null:
			on_card_dropped(held_card)


func on_card_clicked(card: Card):
	if !held_card:
		held_card = card
		card.held = true

		if card.prev != null:
			card.prev.next = null
			card.prev = null
			stacks.append(card)

		lift_card(card)


func on_card_dropped(card: Card):
	held_card = null
	card.held = false
	
	var collisions = card.area2d.get_overlapping_areas()

	var closest_dist = 1.79769e308
	var closest_tail = null
	for collision in collisions:
		var dist = card.area2d.global_position.distance_squared_to(collision.global_position)
		var tail = collision.get_parent().get_tail()
		if dist < closest_dist and tail != card.get_tail():
			closest_tail = tail
			closest_dist = dist
	
	if closest_tail:
		closest_tail.next = card
		card.prev = closest_tail
		var index = stacks.find(card)
		if index >= 0:
			stacks.pop_at(index)

	drop_card(card)


func _input(event):
	if event is InputEventKey and event.is_action_pressed('ui_down'):
		var card = Card.instance()
		card.id = count
		count+=1
		add_child(card)
		push_card(card)
		stacks.append(card)
	if event is InputEventKey and event.is_action_pressed('ui_up'):
		for stack in stacks:
			print(Recipes.get_stack_id(stack))
		print()


func lift_card(card: Card):
	var current = card
	while current != null:
		current.get_node("CollisionShape2D").disabled = true
		pop_card(current)
		push_card(current)
		current = current.next

func drop_card(card: Card):
	var current = card
	while current != null:
		_set_collision_layers()
		current.get_node("CollisionShape2D").disabled = false
		current = current.next


func push_card(card: Card):
	cards.push_back(card)
	emit_signal("cards_changed")


func pop_card(card: Card):
	return cards.pop_at(cards.find(card))


func on_cards_changed():
	for i in cards.size():
		cards[i].z_index = i


func _set_collision_layers():
	for i in stacks.size():
		var current = stacks[i]
		while(current != null):
			current.set_collision_layer(0)
			current.set_collision_mask(0xffffffff)
			current.set_collision_layer_bit(i, true)
			current.set_collision_mask_bit(i, false)
			current = current.next
