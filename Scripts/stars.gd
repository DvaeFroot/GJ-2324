extends Node2D

var y_speed = -1000
var x_speed = 500
var opacity = 1
var _scale = 0.5
var _scale_factor = 7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.4
	timer.start()
	await timer.timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	y_speed += 20000 * delta
	$BigStar1.position += Vector2(-x_speed, y_speed) * delta
	$BigStar2.position += Vector2(x_speed, y_speed) * delta
	$SmallStar1.position += Vector2(-x_speed*0.01, y_speed) * delta
	$SmallStar2.position += Vector2(x_speed*0.01, y_speed) * delta
	
	var _big_scale = Vector2(clampf(_scale, 0, 1), clampf(_scale, 0, 1))
	var _small_scale = Vector2(clampf(_scale - 0.5, 0, 1), clampf(_scale - 0.5, 0, 1))
	$BigStar1.scale = _big_scale
	$BigStar2.scale = _big_scale
	$SmallStar1.scale = _small_scale
	$SmallStar2.scale = _small_scale
	
	$BigStar1.rotation_degrees -= 100 * delta * 5
	$BigStar2.rotation_degrees += 100 * delta * 5
	$SmallStar1.rotation_degrees += 75 * delta * 5
	$SmallStar2.rotation_degrees += 75 * delta * 5
	
	opacity -= 2 * delta
	
	if _scale > 1.5:
		_scale_factor *= -1
	_scale += _scale_factor * delta
	print(_scale)
	$BigStar1.self_modulate = Color(1,1,1,opacity)
