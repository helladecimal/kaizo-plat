extends CharacterBody2D

const walk_vel = 90.0
const run_vel = 170.0
const walk_accel = 12
const run_accel = 8
const jump_force = -300.0

const ground_friction = 20
const air_friction = 0
const g = 800

enum states {Idle, Walk, Run, Jump, Fall}

var currstate = states.Idle

@onready var sprite = $sprite
@onready var coyote = $coyote
@onready var buffer = $buffer
@onready var hurtbox = $Hurtbox

func sprite_process():
	var direction := Input.get_axis("Left", "Right")
	
	if velocity.x == 0 and direction == 0 and is_on_floor():
		sprite.play("idle")
	if velocity.x != 0 and direction != 0 and is_on_floor():
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
	
	if Input.is_action_just_pressed("Jump"):
		buffer.start()
		
	
	# Handle jump.
	if not buffer.is_stopped() and (is_on_floor() or not coyote.is_stopped()):
		velocity.y = jump_force
		
	if Input.is_action_just_released("Jump") and not is_on_floor() and velocity.y < 0:
		velocity.y /= 2
		
	if velocity.y > 0 and not is_on_floor():
		var nudge = float(Input.is_action_pressed("Jump"))
		
		velocity.y -= 5*(nudge)

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
			
	var speed = run_vel if Input.is_action_pressed("Run") or (not is_on_floor() and direction == 0) else walk_vel
	var accel = run_accel if Input.is_action_pressed("Run") or (not is_on_floor() and direction == 0) else walk_accel
	if direction:
		velocity.x = move_toward(velocity.x,(direction * speed), accel)
	else:
		velocity.x = move_toward(velocity.x, 0, accel) if is_on_floor() else move_toward(velocity.x, 0, air_friction)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and not is_on_floor() and buffer.is_stopped():
		coyote.start()
