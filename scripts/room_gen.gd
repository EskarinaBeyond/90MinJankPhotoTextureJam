@tool
extends Node3D
class_name Room

@onready var floor: Node3D = $floor
@onready var wall: Node3D = $wall
@onready var ceiling: Node3D = $ceiling

@export var floor_textures:Array[CompressedTexture2D]

var rng:RandomNumberGenerator = RandomNumberGenerator.new()

@export_tool_button("Reset (Level and Settings)", "Callable") var reset_action = reset

func reset():
	if Engine.is_editor_hint():
		_ready()

func _ready() -> void:
	for child in floor.get_children():
		var floor_texture:CompressedTexture2D = floor_textures.pick_random()
		if(child is CSGBox3D):
			var brush:CSGBox3D = child
			var mat:Material
			mat = brush.material.duplicate()
			mat.set("shader_paramater/albedo_tex",floor_texture)
			brush.material = mat
			
			print('set one texture')
		pass
	pass
