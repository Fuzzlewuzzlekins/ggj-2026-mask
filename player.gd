extends CharacterBody2D

signal reached_midlevel
signal reached_exit
signal peel_local

# Flag whether the character should detect 1 level layer at a time (they're in a 
# "split level") or 2 layers (they're in a "simple level"). I'd prefer to read this 
# from the parent node instead of having to check a box, but that's unsafe :/
@export var IN_SPLIT_LEVEL: bool

var is_grabbing = false
var is_touching_midlevel_goal = false
var is_touching_final_goal = false
var peel_corner_touching = null
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
	# Make the player reside in layer 3
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, true)

	# Set the masks dynamically depending on level type
	set_collision_mask_value(1, true)
	# If the parent scene is a "split level" with two parts,
	# start character as only able to interact with Part 1.
	if IN_SPLIT_LEVEL:
		set_collision_mask_value(2, false)
	# Otherwise, the level is simple. Let player detect all layers.
	else:
		set_collision_mask_value(2, true)
	
	# This makes dudes kill us which is bad for the player
	# but very good for us
	$Area2D.set_collision_mask_value(4, true)


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
		$JumpSoundPlayer.play()

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
	if Input.is_action_just_pressed("grab"):
		is_grabbing = true
		$GrabSoundPlayer.play()
		if is_touching_midlevel_goal:
			reached_midlevel.emit()
		elif peel_corner_touching:
			peel_local.emit(peel_corner_touching)
		
	# Exit the level if grounded and touching (exposed) exit.
	if is_touching_final_goal and is_on_floor():
		reached_exit.emit()
	
	if is_grabbing:
		$AnimatedSprite2D.play("grab")
	else:
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
	if self == body:
		is_touching_final_goal = true


func _on_final_goal_body_exited(body: Node2D) -> void:
	if self == body:
		is_touching_final_goal = false


func _on_peelable_peel_corner_entered(body: Node2D, peel_instance: Node2D) -> void:
	if self == body:
		peel_corner_touching = peel_instance

func _on_peelable_peel_corner_exited(body: Node2D, peel_instance: Node2D) -> void:
	if self == body and peel_corner_touching == peel_instance:
		peel_corner_touching = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Handles dudes killin' us
	if body.is_in_group("enemies"):
		# If we're falling and above the enemy, assume we can squish
		if velocity.y > 0 and global_position.y < body.global_position.y:
			stomp_enemy(body)
		else:
			take_damage()
	
func take_damage():
	hide()


func stomp_enemy(body):
	# Remove the enemy AND bounce us up a bit
	body.die()
	velocity.y = -50.0


func _on_animated_sprite_2d_animation_finished() -> void:
	# At the moment "grab" is the only non-looping animation. Add a condition here if that changes.
	is_grabbing = false
