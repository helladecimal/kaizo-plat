extends CharacterBody2D

const walk_vel = 70.0
const run_vel = 130.0
const jump_force = -220.0

const ground_friction = 0.8
const air_friction = 0.5
const g = 800

enum states {Idle, Walk, Run, Jump, Fall}

var currstate = states.Idle
var canjump = false


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	
	currstate = states.Jump if velocity.y < 0 else states.Fall
	
	# Add the gravity.
	if currstate == states.Fall or currstate == states.Jump:
		velocity.y += g * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_force
		
	if Input.is_action_just_released("Jump") and not is_on_floor() and velocity.y < 0:
		velocity.y /= 2
		
	if velocity.y > 0 and not is_on_floor():
		var nudge = Input.get_axis("Up", "Down")
		
		velocity.y += 5*(nudge)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction := Input.get_axis("Left", "Right")
	
	if direction == 0:
		currstate = states.Idle
	else:
		if Input.is_action_just_pressed("Run"):
			currstate = states.Run
		else:
			currstate = states.Walk
	
	if direction:
		velocity.x = direction * walk_vel
	else:
		velocity.x = move_toward(velocity.x, 0, walk_vel)

	print(currstate)
	print(velocity.y)
	move_and_slide()
