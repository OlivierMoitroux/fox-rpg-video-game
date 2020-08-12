extends KinematicBody2D
# can't extend sth you are not
const MAX_SPEED = 80 # 120
const ROLL_SPEED = 120
const ACCELERATION = 500 # 500 700
const FRICTION = 500

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = $AnimationTree.get("parameters/playback")

var velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT
enum {
	MOVE,
	ROLL,
	ATTACK
}
var state = MOVE

func _ready():
	# only activate animation tree in-game (or click on right pannel)
	animationTree.active = true

# Called every tick the physics engine update
# Since we don't access any physics variable besides our own, we can use _process insead of _physics_process
# But move_and_slide is not recommended outside physics_process. _process can be enought for this project though
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()

func attack_state():
	animationState.travel("Attack")
	
func attack_animation_finished():
	velocity = velocity* 0.8
	state = MOVE
	
func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func roll_animation_finished():
	velocity = Vector2.ZERO
	state = MOVE

func move():
	velocity = move_and_slide(velocity) # handle the delta automatically inside (>< collide)
	
func move_state(delta):
	# use delta to take into account the frame rate (1/60 sec). Not taking it into account might be more fair for the player if the game engine is lagging though
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized() # prevent faster diagonal moves
	
	if input_vector != Vector2.ZERO:
		
		roll_vector = input_vector # Here, otherwise, would roll in place, get the right direction
		# Animations (with an AnimationTree):
		# Want to remember the previous motion for idle state -> update when moving.
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector) # player should commit to the direction of the attack, not change during the annimation
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		
		velocity = velocity.move_toward(input_vector*MAX_SPEED, ACCELERATION*delta)
		# Alternative:
#		velocity += input_vector*ACCELERATION*delta
#		velocity = velocity.clamped(MAX_SPEED) # Add some friction
# 		speed = 100, acc and fric = 10 
		# Basic:
#		velocity = input_vector*MAX_SPEED
		
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)
	# move_and_collide(velocity*delta) # stick to world barrier
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
# Draft:
# -----
# Called when the node enters the scene tree for the first time.
# underscore = callback
#func _ready():
#	print("Hello world, it's friday")
#	pass 


#var animationPlayer = null # instantiate only when scene is ready
#
#func _ready():
#	animationPlayer = $AnimationPlayer
