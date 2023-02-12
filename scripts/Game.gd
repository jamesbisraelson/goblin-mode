extends Node

var items: Array
var stacks: Array
var actions: Dictionary

var held_item: KinematicBody2D

const Actions = preload("res://scenes/Actions.tscn")
const Cycle = preload("res://scripts/Enums.gd").Cycle

onready var dn_prog_bar = get_node("HUD/ProgressBar")
onready var dn_label = get_node("HUD/Label")
onready var dn_timer = get_node("DayNightTimer")

signal items_changed


func _ready():
	randomize()
	
	held_item = null
	stacks = []
	items = []

	connect('items_changed', self, '_items_changed')
	_add_item(PackFactory.new_pack(0), $ZoomCamera.global_position + Vector2(0, 200), Vector2.LEFT)
	# _add_item(CardFactory.new_card(700), $ZoomCamera.global_position, Vector2.RIGHT)

func _process(delta):
	if not is_instance_valid(held_item):
		held_item = null
		
	for item in items:
		if not is_instance_valid(item):
			items.erase(item)

	for stack in stacks:
		if is_instance_valid(stack):
			var stack_id = RecipeFactory.get_stack_id(stack)
			var stack_recipe = RecipeFactory.recipes.get(stack_id)
			if not actions.has(stack.get_instance_id()) and stack_recipe:
				var action = Actions.instance().init(stack, stacks, stack_recipe.actions, stack_recipe.time)
				actions[stack.get_instance_id()] = action
		else:
			stacks.erase(stack)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_action_released('game_select') and held_item != null:
			_item_dropped(held_item)


func _action_created(stack: Card):
	stacks.remove(stacks.find(stack))


func _action_completed(stack: Card):
	actions.erase(stack.get_instance_id())
	stacks.append(stack)
	move_to_bottom(stack)


func _remove_item(item: KinematicBody2D):
	if item == held_item:
		_item_dropped(item)

	var index = items.find(item)
	if index:
		items.remove(index)
	item.queue_free()

func _remove_stack(stack: Card):
	var index = stacks.find(stack)
	if index:
		stacks.remove(index)

	var current = stack
	while current != null:
		_remove_item(current)
		current = current.next


func _add_item(item: KinematicBody2D, position: Vector2, velocity: Vector2):
	item.global_position = position
	item.velocity = velocity

	add_child(item)
	push_item(item)
	if item is Card:
		stacks.append(item)


func _item_clicked(item: KinematicBody2D):
	if !held_item:
		held_item = item
		item.held = true

		if item is Card:
			if item.prev != null:
				item.prev.next = null
				item.prev = null
				stacks.append(item)

		move_to_top(item)


func _item_dropped(item: KinematicBody2D):
	held_item = null
	item.held = false
	var collisions = item.area2d.get_overlapping_areas()
	
	if item is Card:
		_drop_card(item, _get_dropped_on(item, collisions))
	move_to_bottom(item)


	
func _drop_card(card: Card, dropped_on: Node2D):
		if dropped_on is Card:
			if card.type != 'recipe' and card.type != 'tutorial' and dropped_on.type != 'recipe' and dropped_on.type != 'tutorial':
				_add_to_stack(card, dropped_on)
		if dropped_on is SellStack:
			_sell_stack(card, dropped_on)
		if dropped_on is BuyPack:
			_buy_pack(card, dropped_on)

		
func _get_dropped_on(card: Card, collisions: Array) -> Node2D:
	var closest_dist = 1.79769e308
	var closest = null
	
	for collision in collisions:
		var col_item = collision.get_parent()
		var dist = card.area2d.global_position.distance_squared_to(col_item.area2d.global_position)
		if dist < closest_dist:			
			if col_item is Card and col_item.get_tail() != card.get_tail():
				closest = col_item.get_tail()
				closest_dist = dist
			if col_item is SellStack or col_item is BuyPack:
				closest = col_item
				closest_dist = dist
	return closest


func _add_to_stack(card: Card, stack: Card):
	stack.next = card
	card.prev = stack
	var index = stacks.find(card)
	if index >= 0:
		stacks.pop_at(index)


func _sell_stack(stack: Card, sell_stack: SellStack):
	if sell_stack._get_stack_valid(stack):
		sell_stack.sell(stack)
		_remove_stack(stack)


func _buy_pack(stack: Card, buy_pack: BuyPack):
	if buy_pack._get_stack_valid(stack):
		buy_pack.buy(stack)
		_remove_stack(stack)
	


func _items_changed():
	for i in items.size():
		items[i].z_index = i


func move_to_top(item: KinematicBody2D):
	var current = item
	while current != null:
		current.get_node("CollisionShape2D").disabled = true
		pop_item(current)
		push_item(current)
		if item is Card:
			current = current.next
		if item is Pack:
			current = null


func move_to_bottom(item: KinematicBody2D):
	var current = item
	while current != null:
		_set_collision_layers()
		current.get_node("CollisionShape2D").disabled = false
		if item is Card:
			current = current.next
		if item is Pack:
				current = null


func push_item(item: KinematicBody2D):
	items.push_back(item)
	emit_signal("items_changed")


func pop_item(item: KinematicBody2D):
	return items.pop_at(items.find(item))


func _set_collision_layers():
	for i in stacks.size():
		var current = stacks[i]
		while(current != null):
			current.set_collision_layer(0)
			current.set_collision_mask(0xffffffff)
			current.set_collision_layer_bit(i, true)
			current.set_collision_mask_bit(i, false)
			current = current.next


func _end_of_cycle(cycle):
	if cycle == Cycle.DAY:
		consume_food()
	else:
		$DayNightTimer.start()
		
		
func consume_food():
	var food = get_tree().get_nodes_in_group('food')
	var goblins = get_tree().get_nodes_in_group('goblin')
	var tween = get_tree().create_tween()
	
	for goblin in goblins:
		if len(food) > 0:
			var eaten = food.pop_back()
			
			if eaten.prev != null:
				eaten.prev.next = null
				eaten.prev = null
				stacks.append(eaten)
			if eaten.next != null:
				stacks.append(eaten.next)
				eaten.next.prev = null
				eaten.next = null
			
			tween.tween_callback(self, 'move_to_top', [eaten])
			tween.tween_property(eaten, 'global_position', goblin.global_position, 0.25)
			tween.tween_callback(self, '_remove_stack', [eaten])
		else:
			print('out of food')
	tween.tween_callback($DayNightTimer, 'start')
