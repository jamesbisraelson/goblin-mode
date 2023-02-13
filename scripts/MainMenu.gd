extends Control


func _on_exit_pressed():
	get_tree().quit()


func _on_credits_pressed():
	get_tree().change_scene('res://scenes/Credits.tscn')


func _on_play_pressed():
	get_tree().change_scene('res://scenes/Intro.tscn')
