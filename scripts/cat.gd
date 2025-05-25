extends CharacterBody3D
class_name Cat

@export var speed:float = 7
@onready var sprite_3d: Sprite3D = $Sprite3D

var player:Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if player == null:
		player = find_parent("GAME").find_child("Player")
	
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if player != null:
		sprite_3d.look_at(player.position)
		sprite_3d.rotation.x = 0
		
		var input_dir := (player.global_position - self.global_position).normalized()
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
