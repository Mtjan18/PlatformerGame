extends Control
	

func _on_mulai_game_pressed() -> void:
	get_tree().change_scene_to_file("res://HUTAN.tscn")
	pass # Replace with function body.


func _on_button_keluar_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
