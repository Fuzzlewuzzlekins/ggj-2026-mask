extends CharacterBody2D


var speed = 300.0
const JUMP_VELOCITY = -400.0
var direction = 1 # 1 for right, -1 for left

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

	$AnimatedSprite2D.play("walk")
	move_and_slide()
