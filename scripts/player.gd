extends CharacterBody3D
class_name Player


@export var speed = 7.0
@export var jumo_velocity = 4.5
@export_range(0.0, 1.0) var look_sensitivity = 0.05

@onready var head_anchor: Node3D = $HeadAnchor
@onready var camera_3d: Camera3D = $HeadAnchor/Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jumo_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	input_dir = input_dir.rotated(-head_anchor.rotation.y)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	

func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Mouse in viewport coordinates.
	if event is InputEventMouseMotion:
		print("Mouse Motion at: ", event.position)
		
		head_anchor.rotate_y((event.velocity.normalized().x) * -look_sensitivity)
		camera_3d.rotate_x((event.velocity.normalized().y) * -look_sensitivity)
		
		if camera_3d.rotation_degrees.x < -90:
			camera_3d.rotation_degrees.x = -90
		
		if camera_3d.rotation_degrees.x > 90:
			camera_3d.rotation_degrees.x = 90
		

	# Print the size of the viewport.
	print("Viewport Resolution is: ", get_viewport().get_visible_rect().size)	
	
