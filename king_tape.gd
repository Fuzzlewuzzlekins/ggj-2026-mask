extends CharacterBody2D


var speed = -100.0
const JUMP_VELOCITY = -400.0
var direction = 1 # 1 for right, -1 for left
var is_hit = false


func _ready() -> void:
	# Make the enemy reside in layer 4
	set_collision_layer_value(4, true)
	set_collision_layer_value(5, false)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_wall():
		speed *= -1
		$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
	velocity.x = speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_hit:
		$AnimatedSprite2D.play("ouch")
	else:
		$AnimatedSprite2D.play("walk")
	move_and_slide()

func die():
	#$CollisionShape2D.set_deferred("disabled", true)
	# Move the enemy to layer 5 to stop player detection
	set_collision_layer_value(4, false)
	set_collision_layer_value(5, true)
	# Switch off masks so the enemy "falls out of the level"
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	is_hit = true
	$DieSoundPlayer.play()
	# Fade the enemy out over 1 sec, then delete
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	queue_free()
