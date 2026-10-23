extends CharacterBody2D

const WALK_SPEED = 70.0
const RUN_SPEED = 130.0
const JUMP_VELOCITY = -300.0
const GRAVITY = Vector2(0, 800)

enum states {Idle, Walk, Run, Jump, Fall}

var currstate = states.Idle
var canjump = false

func state_handle(velocity: Vector2):
	var direction := Input.get_axis("Left", "Right")
	if Input.is_action_just_pressed("Jump") and canjump:
		currstate = states.Jump
	
	if direction != 0:
		currstate = states.Run if Input.is_action_pressed("Run") else states.Walk
	
	if velocity.y < 0:
		currstate = states.Fall
		
	if velocity.x == 0:
		currstate = states.Idle


func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	state_handle(velocity)
	# Add the gravity.
	if not is_on_floor():
		velocity += GRAVITY * delta
	
	# Handle jump.
	if currstate == states.Jump:
		velocity.y = JUMP_VELOCITY
	if currstate == states.Jump and not is_on_floor():
		velocity.y = move_toward(velocity.y, 0, 100)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	
	if direction:
		velocity.x = direction * WALK_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)

	move_and_slide()
