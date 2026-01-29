extends Node

signal midlevel_tween_finished

@export var MIDLEVEL_TWEEN_DURATION = 2.0
@export var EXIT_TWEEN_DURATION = 1.0
@export var next_level: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	# Reset visibility of TileMapLayers (not sure if needed)
	$TileMaps/Part1.show()
	$TileMaps/Part1Goal.show()
	$TileMaps/Masking.show()


func _on_player_reached_midlevel() -> void:
	# Hide and deactivate Part 1
	$TileMaps/Part1.hide()
	$TileMaps/Part1Goal.hide()
	$TileMaps/Masking.hide()
	
	# Tween the player down to the midlevel spawn point
	var tween = create_tween()
	tween.tween_property($Player, "position", $Part2SpawnPoint.position, MIDLEVEL_TWEEN_DURATION)
	midlevel_tween_finished.emit()


func _on_player_reached_exit() -> void:
	# Tween the player into the exit
	var tween = create_tween()
	tween.tween_property($Player, "position", $"Final Goal".position, EXIT_TWEEN_DURATION)
	tween.tween_property($Player/Sprite2D, "modulate:a", 0, EXIT_TWEEN_DURATION)
	await get_tree().create_timer(EXIT_TWEEN_DURATION * 2).timeout
	get_tree().change_scene_to_packed(next_level)


func _on_pause_level_reset() -> void:
	get_tree().reload_current_scene()


func _on_pause_level_quit() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
