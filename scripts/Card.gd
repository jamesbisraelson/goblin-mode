class_name Card extends KinematicBody2D

var next: Card
var prev: Card
var id: int

var held: bool
var offset: Vector2
onready var area2d: Area2D = $Area2D

signal clicked
signal dropped

func _ready():
	connect("clicked", get_parent(), "on_card_clicked")

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
		if !covered and event.pressed:
			emit_signal("clicked", self)
			offset = get_global_mouse_position() - global_position


func _physics_process(delta):
	if held:
		global_position = get_global_mouse_position() - offset
	elif prev != null:
		global_position = global_position.linear_interpolate(prev.global_position + Vector2(0, 50), delta * 20.0)
	else:
		var collisions = move_and_collide(Vector2.ZERO, true, true, true)
		if collisions:
			global_position -= global_position.direction_to(collisions.collider.global_position) * 5.0



func get_tail():
	if next:
		return next.get_tail()
	return self

func get_head():
	if prev:
		return prev.get_head()
	return self