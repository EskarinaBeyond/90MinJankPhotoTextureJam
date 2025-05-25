extends Node3D
class_name CatSpawner

var cats_anchor: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if cats_anchor == null:
		find_parent("game").find_child("CatsAnchor")
	
	spawn_cat()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_cat():
	var new_cat:Cat = Cat.new()
	new_cat.global_position = self.global_position
	cats_anchor.add_child(new_cat)
	
