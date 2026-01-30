extends Node

signal midlevel_tween_finished

@export var MIDLEVEL_TWEEN_DURATION = 3.0
@export var EXIT_TWEEN_DURATION = 1.0
@export var next_level: PackedScene
@export var IS_SPLIT_LEVEL: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	# Reset visibility of TileMapLayers (not sure if needed). 
	$TileMaps/Part1.show()
	if IS_SPLIT_LEVEL:
		$TileMaps/Part1Goal.show()
	$TileMaps/Masking.show()


func _on_player_reached_midlevel() -> void:
	$LevelPeelSound.play()
	
	# Reparent nodes into LevelPeel (a Polygon2D clipping mask) for peel animation
	$TileMaps/Masking.reparent($LevelPeel)
	$TileMaps/Part1.reparent($LevelPeel)
	$TileMaps/Part1Goal.reparent($LevelPeel)
	$Player.show_behind_parent = true
	$Player.reparent($LevelPeel/Part1Goal)
	$LevelPeel.move_child($"LevelPeel/LevelPeel Sprite", 4)
	
	# Peel animation starts here
	var tween = create_tween().set_parallel()
	var peel_height = $LevelPeel.polygon[2].y # Height of a vertical side of the parallelogram, e.g. viewport height + 88 pixels
	# Peel animation: parent (clipping mask)
	tween.tween_property($LevelPeel, "position:y", $LevelPeel.position.y + peel_height, MIDLEVEL_TWEEN_DURATION)
	# Peel animation: Masking, Part 1 -- need equal offset to "stay still" in the global coordinates
	tween.tween_property($LevelPeel/Masking, "position:y", $LevelPeel/Masking.position.y - peel_height, MIDLEVEL_TWEEN_DURATION)
	tween.tween_property($LevelPeel/Part1, "position:y", $LevelPeel/Part1.position.y - peel_height, MIDLEVEL_TWEEN_DURATION)
	# Peel animation: backside sprite -- needs to move twice as fast as the parent and have a slight horizontal offset
	tween.tween_property($"LevelPeel/LevelPeel Sprite", "position:y", $"LevelPeel/LevelPeel Sprite".position.y + peel_height, MIDLEVEL_TWEEN_DURATION)
	tween.tween_property($"LevelPeel/LevelPeel Sprite", "position:x", $"LevelPeel/LevelPeel Sprite".position.x - 150, MIDLEVEL_TWEEN_DURATION) 
	
	# Peel animation: pull tab + player - same as backside sprite, but needs slight delay; main tween needs to advance 24 pixels first
	var tab_subtween = create_tween()
	var peel_fraction = 24 / peel_height
	tab_subtween.tween_interval(peel_fraction * MIDLEVEL_TWEEN_DURATION)
	tab_subtween.tween_property($LevelPeel/Part1Goal, "position:y", $LevelPeel/Part1Goal.position.y + peel_height - 24, MIDLEVEL_TWEEN_DURATION * (1.0 - peel_fraction))
	tab_subtween.parallel().tween_property($LevelPeel/Part1Goal, "position:x", $LevelPeel/Part1Goal.position.x - 150 * (1.0 - peel_fraction), MIDLEVEL_TWEEN_DURATION * (1.0 - peel_fraction))
	tween.tween_subtween(tab_subtween)
	
	# Peel animation: player - needs to stop early, detach from pull tab, and reparent back to level.
	var player_subtween = create_tween()
	player_subtween.tween_interval(MIDLEVEL_TWEEN_DURATION * 0.325) # Hacky guess, would like to figure out better method later
	tween.tween_subtween(player_subtween)
	$LevelPeel/Part1Goal/Player.set_physics_process(false)
	await player_subtween.finished
	$LevelPeel/Part1Goal/Player.set_physics_process(true)
	$LevelPeel/Part1Goal/Player.set_deferred("velocity", Vector2.ZERO)
	$LevelPeel/Part1Goal/Player.reparent(self)
	midlevel_tween_finished.emit()
	
	# Hide and deactivate Part 1
	await tween.finished
	$LevelPeel.queue_free()


func _on_player_reached_exit() -> void:
	# Point player towards the exit
	$Player/AnimatedSprite2D.flip_h = $Player.position.x > $"Final Goal".position.x
	# Tween the player into the exit
	$Player.set_physics_process(false)
	var tween = create_tween()
	tween.tween_property($Player, "position", $"Final Goal".position, EXIT_TWEEN_DURATION)
	tween.tween_property($Player/AnimatedSprite2D, "modulate:a", 0, EXIT_TWEEN_DURATION)
	#await get_tree().create_timer(EXIT_TWEEN_DURATION * 2).timeout
	await tween.finished
	# Load the next level
	get_tree().change_scene_to_packed(next_level)


func _on_pause_level_reset() -> void:
	get_tree().reload_current_scene()


func _on_pause_level_quit() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
