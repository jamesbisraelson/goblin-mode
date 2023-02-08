class_name Card extends KinematicBody2D

const SNAP_SPEED: float = 20.0
const DISPLACE_SPEED: float = 150.0

var next: Card
var prev: Card

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

signal clicked

func init(id: int, title: String, cost: int, card_back: String, icon: String, type: String):
	self.id = id
	self.icon = icon
	self.type = type
	self.cost = cost

	$TitlePosition/Title.text = title
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
		global_position = global_position.linear_interpolate(prev.next_card_pos.global_position, delta * SNAP_SPEED)
	else:
		var collisions = move_and_collide(Vector2.ZERO, true, true, true)
		if collisions:
			velocity -= global_position.direction_to(collisions.collider.global_position) * DISPLACE_SPEED * delta
	
		global_position += velocity
		velocity = velocity.linear_interpolate(Vector2.ZERO, 20.0 * delta)

func get_tail():
	if next:
		return next.get_tail()
	return self


func get_head():
	if prev:
		return prev.get_head()
	return self
