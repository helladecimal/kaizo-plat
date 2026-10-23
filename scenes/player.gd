extends CharacterBody2D

const walk_vel = 70.0
const run_vel = 130.0
const walk_accel = 10
const run_accel = 6
const jump_force = -220.0

const ground_friction = 20
const air_friction = 0
const g = 800

enum states {Idle, Walk, Run, Jump, Fall}

var currstate = states.Idle

@onready var sprite = $sprite
@onready var buffer = $buffer

func sprite_process():
	var direction := Input.get_axis("Left", "Right")
	
	if velocity.x == 0 and is_on_floor():
		sprite.play("idle")
	if velocity.x != 0 and is_on_floor():
		sprite.play("run")
		
	if velocity.y < 0:
		sprite.play("jump")
	if velocity.y > 10 and not is_on_floor():
		sprite.play("fall")	
	
	if direction == 0:
		sprite.flip_h = sprite.flip_h
	else:
		sprite.flip_h = true if direction < 0 else false
	# oh the horror ...
	pass

func _process(delta: float) -> void:
	sprite_process()
	pass

func _physics_process(delta: float) -> void:
	
	currstate = states.Jump if velocity.y < 0 else states.Fall
	
	# Add the gravity.
	if currstate == states.Fall or currstate == states.Jump:
		velocity.y += g * delta
	
	# Handle jump.
	if Input.is_action_pressed("Jump") and is_on_floor(): # bunnyhop, why not
		velocity.y = jump_force
		
	if Input.is_action_just_released("Jump") and not is_on_floor() and velocity.y < 0:
		velocity.y /= 2
		
	if velocity.y > 0 and not is_on_floor():
		var nudge = Input.get_axis("Up", "Down")
		
		velocity.y += 8*(nudge)

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
			
	var speed = run_vel if Input.is_action_pressed("Run") else walk_vel
	var accel = run_accel if Input.is_action_pressed("Run") else walk_accel
	if direction:
		velocity.x = move_toward(velocity.x,(direction * speed), accel)
	else:
		velocity.x = move_toward(velocity.x, 0, accel) if is_on_floor() else move_toward(velocity.x, 0, air_friction)

	print(currstate)
	print(velocity.x)
	move_and_slide()
