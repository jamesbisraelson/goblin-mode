extends Control


func _on_exit_pressed():
	get_tree().quit()


func _on_credits_pressed():
	pass


func _on_play_pressed():
	get_tree().change_scene('res://scenes/Game.tscn')