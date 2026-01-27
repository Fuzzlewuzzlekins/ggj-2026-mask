extends Node

signal midlevel_tween_finished

@export var MIDLEVEL_TWEEN_DURATION = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Reset visibility of TileMapLayers (not sure if needed)
	$TileMaps/Part1.show()
	$TileMaps/Part1Goal.show()
	$TileMaps/Masking.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_reached_midlevel() -> void:
	# Hide and deactivate Part 1
	$TileMaps/Part1.hide()
	$TileMaps/Part1Goal.hide()
	$TileMaps/Masking.hide()
	
	# Tween the player down to the midlevel spawn point
	var tween = create_tween()
	tween.tween_property($Player, "position", $Part2SpawnPoint.position, MIDLEVEL_TWEEN_DURATION)
	midlevel_tween_finished.emit()
