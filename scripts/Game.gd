extends Node

var items: Array
var stacks: Array
var actions: Dictionary

var held_item: KinematicBody2D
var count = 0

signal items_changed


func _ready():
	randomize()
	
	held_item = null
	stacks = []
	items = []

	connect('items_changed', self, '_items_changed')
	_add_item(PackFactory.new_pack(0), $ZoomCamera.global_position, Vector2.ZERO)

func _process(_delta):
	for stack in stacks:
		var stack_id = RecipeFactory.get_stack_id(stack)
		var stack_recipe = RecipeFactory.recipes.get(stack_id)
		if not actions.has(stack.get_instance_id()) and stack_recipe:
			var action = Actions.new(stack, stacks, stack_recipe.actions, stack_recipe.time)
			actions[stack.get_instance_id()] = action
			add_child(action)


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
	items.remove(items.find(item))
	item.queue_free()

func _remove_stack(stack: Card):
	stacks.remove(stacks.find(stack))

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
