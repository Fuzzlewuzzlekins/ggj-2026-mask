extends Node2D

signal peel_corner_entered
signal peel_corner_exited

# Optional: if the Peelable conceals an external Area2D, link its hitbox here.
@export var HIDDEN_NODE_HITBOX: CollisionShape2D

@export var PEEL_SPEED = 0.4


func _ready() -> void:
	# Make the top layer active.
	$PeelMask/TempTiles.collision_enabled = true
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
		$PeelSound.play()
		# TODO: animation
		var tween = create_tween().set_parallel()
		var peel_height = $PeelMask.polygon[2].y * 2
		tween.tween_property($PeelMask, "position:y", peel_height, PEEL_SPEED)
		tween.tween_property($PeelMask/MaskTiles, "position:y", peel_height * -1.0, PEEL_SPEED)
		tween.tween_property($PeelMask/TempTiles, "position:y", peel_height * -1.0, PEEL_SPEED)
		$PeelMask/TempTiles.collision_enabled = false
		#$PeelMask/TempTiles.hide()
		$PeelTarget/CollisionShape2D.disabled = true
		#$PeelMask/MaskTiles.hide()
		$HiddenTiles.collision_enabled = true
		if HIDDEN_NODE_HITBOX:
			HIDDEN_NODE_HITBOX.disabled = false
