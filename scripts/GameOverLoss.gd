extends Control

func _ready():
	yield(get_tree().create_timer(10.0), 'timeout')
	get_tree().change_scene('res://scenes/MainMenu.tscn')