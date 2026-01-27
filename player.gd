extends CharacterBody2D

signal reached_midlevel

var is_touching_midlevel_goal = false

const SPEED = 400.0
const JUMP_VELOCITY = -750.0


func _ready() -> void:
	# Start character as only able to interact with Part 1.
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Handle "grab" attempts.
	if Input.is_action_just_pressed("grab") and is_touching_midlevel_goal:
		
		reached_midlevel.emit()

	move_and_slide()


func _on_midlevel_goal_body_entered(body: Node2D) -> void:
	if self == body:
		is_touching_midlevel_goal = true


func _on_midlevel_goal_body_exited(body: Node2D) -> void:
	if self == body:
		is_touching_midlevel_goal = false


func _on_midlevel_tween_finished():
	is_touching_midlevel_goal = false
	$CollisionShape2D.disabled = false
	set_deferred("velocity", Vector2.ZERO)
	# Swap character to use Physics Layer 2
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)
