extends CharacterBody2D
@export_category("Movement Settings")
@export var move_speed = 400.0
@export var move_acceleration: float = 10.0

@export_category("Jump Settings")
@export var jump_height : float = 100
@export var gravity : float = 10
@export var enable_coyote_time := true
@export var enable_long_input := true
@export_group("Jump Hold Settings")
@export var enable_jump_hold := true
@export var jump_time_to_peak : float = 0.25
@export var jump_time_to_descent : float = 0.2

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var can_jump := false
var pressed_jump := false
var horizontal := 0.0
var last_animation : String

func _physics_process(delta):
	velocity.x = get_input_velocity(delta) * move_speed
	if is_on_wall():
		horizontal = 0
	if not is_on_floor():
		velocity.y += get_gravity() * (delta if enable_jump_hold else 1)
		coyote_time()
		
		last_animation = "Fall"
	else:
		if last_animation == "Jump" or last_animation == "Fall":
			land_animation()
			
		can_jump = true
		if pressed_jump:
			pressed_jump = false
			jump()
	
	if Input.is_action_just_pressed("ui_accept"):
		if can_jump:
			jump()
		else:
			if not pressed_jump:
				pressed_jump = true
				jump_press()
	if Input.is_action_just_released("ui_accept") and velocity.y < 0 and enable_jump_hold:
		velocity.y = 0
	
	move_and_slide()
# ESC/QUIT FUNCTION
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

# VERTICAL MOVEMENT
func get_gravity() -> float:
	if enable_jump_hold:
		return jump_gravity if velocity.y < 0.0 else fall_gravity
	else:
		return gravity
func jump():
	if enable_jump_hold:
		velocity.y = jump_velocity
	else:
		velocity.y = -jump_height
	can_jump = false
	
	jump_animation()

# HORIZONTAL MOVEMENT
func get_input_velocity(delta) -> float:
	var raw_horizontal := 0.0
	
	if Input.is_action_pressed("ui_left"):
		raw_horizontal -= 1.0
	if Input.is_action_pressed("ui_right"):
		raw_horizontal += 1.0
	
	horizontal = move_toward(horizontal,raw_horizontal,move_acceleration * delta)
	
	return horizontal

# GAMEPLAY ADDITIONS
func coyote_time():
	await get_tree().create_timer(0.1).timeout
	can_jump = false
func jump_press():
	await get_tree().create_timer(0.75).timeout
	pressed_jump = false

# ANIMATION AND SOUND EFFECTS
func jump_animation():
	$"Player - Base/jump_sfx".play()
	$"Player - Base/AnimationPlayer".play("Jump")
	last_animation = "Jump"
func land_animation():
	$"Player - Base/AnimationPlayer".play("Squish")
	last_animation = "Land"
