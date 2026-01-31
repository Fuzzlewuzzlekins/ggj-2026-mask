extends Node

func _ready() -> void:
	$Label.text = "Mad King Tape\nhas been dethroned!\n\nCONGRATULATIONS"
	await get_tree().create_timer(2.0).timeout
	$Label.text = "Made in Godot by:\nWilliam Crawford\nAmanda Crawford"
	await get_tree().create_timer(3.0).timeout
	$Label.text = "THANKS FOR PLAYING"
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://main.tscn")
