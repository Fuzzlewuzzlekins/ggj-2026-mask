extends CharacterBody2D

signal reached_midlevel
signal reached_exit

var is_touching_midlevel_goal = false
var cooldown_timer: SceneTreeTimer
# TODO
#var last_floor_time = -1.0
#var last_jump_time = -1.0

const SPEED = 400.0
const JUMP_VELOCITY = -750.0
const LEVEL_READY_COOLDOWN = 1.0
# TODO
#const MAX_JUMP_HOLD_TIME = 0.5
#const COYOTE_TIME = 0.1


func _ready() -> void:
	# Start character as only able to interact with Part 1.
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	cooldown_timer = get_tree().create_timer(LEVEL_READY_COOLDOWN)


func _physics_process(delta: float) -> void:
	var current_animation = null
	
	
	# Add the gravity.
	if not is_on_floor():
		# TODO: implement Coyote Time
		velocity += get_gravity() * delta
		current_animation = "jump"

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		# TODO: implement variable jump power
		velocity.y = JUMP_VELOCITY
		current_animation = "jump"

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		if not current_animation:
			current_animation = "run"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not current_animation:
			current_animation = "idle"
	
	# Handle "grab" attempts.
	# TODO: animate grab regardless of target
	if Input.is_action_just_pressed("grab") and is_touching_midlevel_goal:
		reached_midlevel.emit()
		
	$AnimatedSprite2D.play(current_animation)
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


func _on_final_goal_body_entered(body: Node2D) -> void:
	# IDK why this is firing on level start so I'll deactivate it during 
	# level start cooldown:
	if cooldown_timer.time_left == 0:
		reached_exit.emit()
