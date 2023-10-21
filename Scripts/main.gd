extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite2d = Sprite2D.new()
	add_child(sprite2d)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
