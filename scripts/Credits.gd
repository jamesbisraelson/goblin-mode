extends Control

var tween: SceneTreeTween
var end_pos: Vector2
var skipped: bool


func _ready():
	skipped = false
	end_pos = Vector2($CreditsPosition.global_position.x, -$CreditsPosition/Text.rect_size.y)
	scroll_credits(20.0)


func _input(event):
	if event is InputEventKey:
		if not skipped and event.pressed:
			_skip()
	elif event is InputEventMouseButton:
		if not skipped:
			_skip()


func _skip():
	skipped = true

	tween.kill()
	scroll_credits(5.0)


func scroll_credits(time: float):
	tween = get_tree().create_tween()
	tween.tween_property($CreditsPosition, 'global_position', end_pos, time)
	tween.tween_callback(get_tree(), 'change_scene', ['res://scenes/MainMenu.tscn'])
