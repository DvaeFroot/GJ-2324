extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -400.0
const FRICTION = 300
const DEADZONE = 50

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_on_hold: bool = false

var force_line: Line2D
var line_curve: Curve
var direction: Vector2
var vel: Vector2
var force_factor: float = 0
var level: int = 1
var exp: int = 0
var exp_to_next_level = 100*(level/2)

var turn_ended = true

signal end_turn

func _ready():
	line_curve = Curve.new()
	line_curve.add_point(Vector2(1,0))
	line_curve.add_point(Vector2(0, 5.16))
	force_line = Line2D.new() # Create a new Sprite2D.
	force_line.z_index = -1
	force_line.width_curve = line_curve
	force_line.default_color = Color(0.1, 0.99, 0.2, 255/255)
	get_tree().current_scene.call_deferred("add_child", force_line)


func _physics_process(delta: float) -> void:
	if is_on_hold:
		force_line.remove_point(1)
		var distance_to_mouse = global_position.distance_to(get_global_mouse_position())
		var clamped_dtm = clampf(distance_to_mouse, 0, 315)
		var dir = global_position.direction_to(get_global_mouse_position())
		force_line.add_point(global_position + dir * clamped_dtm)
		var size = clampf(clamped_dtm/50,0,5) 
		force_line.width_curve.set_point_value(0, size)
		force_factor = clamped_dtm / 315	
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)
		var collision: KinematicCollision2D = move_and_collide(velocity * delta)
		if collision:
			var reflect = collision.get_remainder().bounce(collision.get_normal())
			velocity = velocity.bounce(collision.get_normal()) * 0.6
			# print(collision.get_collider())
			if collision.get_collider() == $"../bouncepad":
				velocity *= 10
			move_and_collide(reflect)
		if velocity == Vector2.ZERO and not turn_ended:
			if $"../EnemyLayer".get_child_count() == 0:
				print("level finish")
				get_tree().change_scene_to_file("res://Scenes/main.tscn")
			
			print("Turn has ended")
			turn_ended = true
			end_turn.emit()
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not GameManaager.is_player_turn:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if global_position.distance_to(get_global_mouse_position()) <= DEADZONE:
					is_on_hold = true
					force_line.visible = true
					force_line.clear_points()
					force_line.add_point(global_position)
					$KnockbackBox.monitoring = false
			else:
				if is_on_hold:
					turn_ended = false
					is_on_hold = false
					direction = -global_position.direction_to(get_global_mouse_position())
					force_line.visible = false
					velocity = direction * SPEED * force_factor
					$KnockbackBox.monitoring = true


func _on_knockback_box_area_entered(area: Area2D) -> void:
	var other: CharacterBody2D = area.get_parent()
	if GameManaager.is_player_turn:
		other.bumped()
		
