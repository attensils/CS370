extends CharacterBody3D

# Player nodes
@onready var head: Node3D = $head
@onready var standing_collison_shape: CollisionShape3D = $standing_collison_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape

# Speed vars
var current_speed = 5.0

const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0

# Movement vars
var crouching_depth = -0.5
const lerp_speed = 10
const jump_velocity = 4.5

# Input variables
const mouse_sens = 0.25
var direction  = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
# Mouse looking logic
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y*mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-98),deg_to_rad(98))
		
func _physics_process(delta: float) -> void:
# Handle movement state
# Crouching
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,1.8 + crouching_depth, delta*lerp_speed)
		standing_collison_shape.disabled = true
		crouching_collision_shape.disabled = false
	
#Standing
	else:
		standing_collison_shape.disabled = false
		crouching_collision_shape.disabled = true
		head.position.y = lerp(head.position.y,1.8, delta*lerp_speed)
		
		#Sprinting
		if Input.is_action_pressed("sprint"):
			current_speed = sprinting_speed
		else:
# Walking
			current_speed = walking_speed

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
