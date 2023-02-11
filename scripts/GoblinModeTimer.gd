extends Timer

var following
var parent

func _ready():
	connect("timeout", self, "_goblin_mode")
	parent = get_parent()

func _goblin_mode():
	following = null
	var day_night = get_tree().get_current_scene().dn_timer
	var is_night = day_night.cycle == day_night.Cycle.NIGHT
	
	if is_night and not parent.held and parent.next == null and parent.prev == null:
		var cards = get_tree().get_nodes_in_group('cards')
		for card in cards:
			if card != parent and card.prev == null and card.next == null:
				if not following:
					following = card
				elif parent.global_position.distance_squared_to(card.global_position) < parent.global_position.distance_squared_to(following.global_position):
					following = card
	
	if following:
		parent.velocity += parent.global_position.direction_to(following.global_position).normalized() * 50.0
		var tween = get_tree().create_tween()
		var rot_amt = rand_range(3.0, 10.0)
		if randi() % 2 == 0:
			rot_amt *= -1

		tween.tween_property(parent, "rotation_degrees", rot_amt, 0.1)
		tween.tween_property(parent, "rotation_degrees", -rot_amt, 0.1)
		tween.tween_property(parent, "rotation_degrees", rot_amt/2, 0.1)
		tween.tween_property(parent, "rotation_degrees", -rot_amt/2, 0.1)
		tween.tween_property(parent, "rotation_degrees", 0.0, 0.1)
