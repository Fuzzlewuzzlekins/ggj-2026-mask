extends Node2D

signal peel_corner_entered
signal peel_corner_exited

# Optional: if the Peelable conceals an external Area2D, link its hitbox here.
@export var HIDDEN_NODE_HITBOX: CollisionShape2D


func _ready() -> void:
	# Make the top layer active.
	$TempTiles.collision_enabled = true
	$PeelTarget/CollisionShape2D.disabled = false
	# Make the bottom layer inactive.
	$HiddenTiles.collision_enabled = false
	if HIDDEN_NODE_HITBOX:
		HIDDEN_NODE_HITBOX.disabled = true



func _on_peel_target_body_entered(body: Node2D) -> void:
	var peel_instance = self
	peel_corner_entered.emit(body, peel_instance)


func _on_peel_target_body_exited(body: Node2D) -> void:
	var peel_instance = self
	peel_corner_exited.emit(body, peel_instance)


func _on_player_peel_local(peel_instance: Node2D) -> void:
	if peel_instance == self:
		# Peel it! 
		# TODO: animation
		$TempTiles.collision_enabled = false
		$TempTiles.hide()
		$PeelTarget/CollisionShape2D.disabled = true
		$MaskTiles.hide()
		$HiddenTiles.collision_enabled = true
		if HIDDEN_NODE_HITBOX:
			HIDDEN_NODE_HITBOX.disabled = false
