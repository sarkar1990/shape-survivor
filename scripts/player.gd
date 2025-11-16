# scripts/player.gd
extends CharacterBody2D
# Drag-to-move controller that works with mouse & single-touch
# Movement is smoothed for a pleasant feel.

@export var speed : float = 420.0        # movement speed in pixels/sec
@export var smoothing : float = 10.0     # higher = snappier
var target_pos : Vector2
var has_input : bool = false

func _ready():
	target_pos = global_position
	set_process(true)
	# Show helpful debug
	print("Player ready. speed=%s smoothing=%s" % [speed, smoothing])

func _unhandled_input(event):
	# Touch screen on Android will generate InputEventScreenTouch & ScreenDrag
	# Mouse will generate InputEventMouseButton & InputEventMouseMotion
	if event is InputEventScreenTouch:
		if event.pressed:
			target_pos = get_global_mouse_position()
			has_input = true
		else:
			has_input = false
	elif event is InputEventScreenDrag:
		# finger drag -> update target
		target_pos = get_global_mouse_position()
		has_input = true
	elif event is InputEventMouseButton:
		# left click pressed -> set target; release clears
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			target_pos = get_global_mouse_position()
			has_input = true
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			has_input = false
	elif event is InputEventMouseMotion:
		# optional: when mouse moves while held (desktop), update target
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			target_pos = get_global_mouse_position()
			has_input = true

func _process(delta):
	# If player has input, move towards target_pos smoothly
	var desired = global_position
	if has_input:
		desired = target_pos
	# Compute desired velocity
	var to_target = (desired - global_position)
	var distance = to_target.length()
	if distance > 2.0:
		var desired_velocity = to_target.normalized() * speed
		# Smooth velocity (lerp)
		velocity = velocity.lerp(desired_velocity, clamp(smoothing * delta, 0, 1))
	else:
		# stop (close enough)
		velocity = velocity.lerp(Vector2.ZERO, clamp(smoothing * delta, 0, 1))
	# Move with CharacterBody2D convenience
	move_and_slide()
