class_name Pack extends KinematicBody2D

const DISPLACE_SPEED: float = 150.0
const DECELERATION: float = 20.0

var id: int
var title: String
var icon: String
var num_cards: int
var card_ids: Array
var random: bool

var held: bool
var offset: Vector2
var velocity: Vector2

onready var area2d: Area2D = $Area2D

signal clicked
signal add_item
signal remove_item

func init(id: int, title: String, icon: String, num_cards: int, card_ids: Array, random: bool):
	self.id = id
	self.title = title
	self.icon = icon
	self.num_cards = num_cards
	self.card_ids = card_ids.duplicate()
	self.random = random
	velocity = Vector2.ZERO

	$TitlePosition/Title.text = title
	return self

func _ready():
	connect("clicked", get_parent(), "_item_clicked")
	connect('add_item', get_parent(), '_add_item')
	connect('remove_item', get_parent(), '_remove_item')
	held = false


func _input_event(_viewport, event, _shape_idx):
	if not get_parent().feeding_time:
		var intersecting_cards = get_world_2d().direct_space_state.intersect_point(get_global_mouse_position())
		var covered = false

		for card in intersecting_cards:
			if card.collider.z_index > z_index:
				covered = true


		if event is InputEventMouseButton:
			if !covered and event.is_action_pressed('game_select'):
				emit_signal("clicked", self)
				offset = get_global_mouse_position() - global_position
			if !covered and event.is_action_pressed('game_select') and event.doubleclick:
				create_card()


func _physics_process(delta):
	if held:
		velocity = Vector2.ZERO
		global_position = get_global_mouse_position() - offset

	else:
		# move the card away from collisions
		var collisions = move_and_collide(Vector2.ZERO, true, true, true)
		if collisions:
			velocity -= global_position.direction_to(collisions.collider.global_position) * DISPLACE_SPEED * delta
	
		# deceleration
		global_position += velocity
		velocity = velocity.linear_interpolate(Vector2.ZERO, DECELERATION * delta)

	# clamp to board
	var board = get_parent().get_node('Board').get_rect()
	var pack_rect = $Sprite.get_rect()
	global_position.x = clamp(global_position.x, board.position.x + pack_rect.size.x/2, board.size.x - pack_rect.size.x/2)
	global_position.y = clamp(global_position.y, board.position.y + pack_rect.size.y/2, board.size.y - pack_rect.size.y/2)


func create_card():
	if random:
		emit_signal(
			'add_item', 
			CardFactory.new_card(card_ids[randi() % len(card_ids)]),
			global_position,
			Vector2(rand_range(-1, 1),
			rand_range(-1, 1)).normalized() * 150.0
		)
	else:
		emit_signal(
			'add_item',
			CardFactory.new_card(card_ids.pop_front()),
			global_position,
			Vector2(rand_range(-1, 1),
			rand_range(-1, 1)).normalized() * 150.0
		)

	num_cards -= 1
	if num_cards <= 0:
		emit_signal('remove_item', self)
