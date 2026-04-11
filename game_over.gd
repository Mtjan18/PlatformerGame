extends Control 


func _on_ulangi_pressed() -> void:
	get_tree().change_scene_to_file("res://HUTAN.tscn")

func _on_keluar_pressed() -> void:
	get_tree().quit()
