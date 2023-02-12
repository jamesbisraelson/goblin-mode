class_name Card extends KinematicBody2D

const SNAP_SPEED: float = 20.0
const DISPLACE_SPEED: float = 150.0
const DECELERATION: float = 20.0

var next: Card
var prev: Card
var following: Card

var id: int
var title: String
var icon: String
var type: String
var cost: int

var held: bool
var offset: Vector2
var velocity: Vector2

onready var area2d: Area2D = $Area2D
onready var next_card_pos: Node2D = $NextCardPosition
onready var progress_bar_pos: Node2D = $ProgressBarPosition

const GoblinModeTimer = preload("res://scenes/GoblinModeTimer.tscn")

signal clicked

func init(id: int, title: String, cost: int, card_back: String, icon: String, type: String):
	self.id = id
	self.icon = icon
	self.type = type
	self.cost = cost
	
	velocity = Vector2.ZERO
	add_to_group(type)

	if id in CardFactory.card_types['goblin']:
		add_child(GoblinModeTimer.instance())

	$TitlePosition/Title.text = title
	$CostPosition/Title.text = (str(cost) if cost != 0 else '')
	$Sprite.texture = load('res://assets/%s' % card_back)
	return self

func _ready():
	connect("clicked", get_parent(), "_item_clicked")

	held = false
	next = null
	prev = null

func _input_event(_viewport, event, _shape_idx):
	var intersecting_cards = get_world_2d().direct_space_state.intersect_point(get_global_mouse_position())
	var covered = false

	for card in intersecting_cards:
		if card.collider.z_index > z_index:
			covered = true

	if event is InputEventMouseButton:
		if !covered and event.is_action_pressed('game_select'):
			emit_signal("clicked", self)
			offset = get_global_mouse_position() - global_position


func _physics_process(delta):
	if held:
		velocity = Vector2.ZERO
		global_position = get_global_mouse_position() - offset
	elif prev != null:
		# if the card is part of a stack
		global_position = global_position.linear_interpolate(prev.next_card_pos.global_position, delta * SNAP_SPEED)
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


func get_tail():
	if next:
		return next.get_tail()
	return self


func get_head():
	if prev:
		return prev.get_head()
	return self
