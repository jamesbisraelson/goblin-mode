class_name Pack extends KinematicBody2D

const DISPLACE_SPEED: float = 20.0

var id: int
var title: String
var icon: String
var pack_back: String
var num_cards: int
var card_ids: Array

var held: bool
var offset: Vector2

onready var area2d: Area2D = $Area2D

signal clicked

func init(id: int, title: String, icon: String, pack_back: String, num_cards: int, card_ids: Array):
    self.id = id
    self.title = title
    self.icon = icon
    self.pack_back = pack_back
    self.num_cards = num_cards
    self.card_ids = card_ids
    return self

func _ready():
    connect("clicked", get_parent(), "on_item_clicked")
    held = false


func _input_event(_viewport, event, _shape_idx):
    var intersecting_cards = get_world_2d().direct_space_state.intersect_point(get_global_mouse_position())
    var covered = false

    for card in intersecting_cards:
        if card.collider.z_index > z_index:
            covered = true


    if event is InputEventMouseButton:
        if !covered and event.pressed:
            print('clicked')
            emit_signal("clicked", self)
            offset = get_global_mouse_position() - global_position


func _physics_process(delta):
    if held:
        global_position = get_global_mouse_position() - offset
    else:
        var collisions = move_and_collide(Vector2.ZERO, true, true, true)
        if collisions:
            global_position -= global_position.direction_to(collisions.collider.global_position) * DISPLACE_SPEED