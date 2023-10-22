extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

const SPEED = 500.0
const FRICTION = 300
const DEADZONE = 50
const MAX_FORCE = 500

# Get the gravity from the project settings to be synced with RigidBody nodes.
var is_on_hold: bool = false
var is_moving: bool = false

var force_line: Line2D
var line_curve: Curve
var direction: Vector2
var vel: Vector2
var force_factor: float = 0

var turn_ended = true
var collided = []
var enemy_layer

var main

signal end_turn

func _ready():
	enemy_layer = get_tree().current_scene.get_node("EnemyLayer")
	main = get_tree().current_scene
	$ice_trail.visible = false
	line_curve = Curve.new()
	line_curve.max_value = 5
	line_curve.add_point(Vector2(1,0))
	line_curve.add_point(Vector2(0, 7.5))
	force_line = Line2D.new() # Create a new Sprite2D.
	force_line.z_index = -1
	force_line.width_curve = line_curve
	force_line.default_color = Color(0.1, 0.99, 0.2, 1)
	get_tree().current_scene.call_deferred("add_child", force_line)
	play_selected_animation()
	
func play_selected_animation() -> void:
	while true:
		$AnimationPlayer.play("spin_and_pulse")
		await $AnimationPlayer.animation_finished


func _physics_process(delta: float) -> void:
	if is_moving:
		animated_sprite_2d.frame = 3
	else:
		animated_sprite_2d.frame = 2 - clampi(GameManaager.player_health, 0 ,2)
	if GameManaager.is_player_turn and not is_on_hold and not is_moving:
		$Selected.visible = true
	if is_on_hold:
		force_line.remove_point(1)
		var distance_to_mouse = global_position.distance_to(get_global_mouse_position())
		var clamped_dtm = clampf(distance_to_mouse, 0, 315)
		var dir = global_position.direction_to(get_global_mouse_position())
		force_line.add_point(global_position + dir * clamped_dtm)
		var size = clampf(clamped_dtm/50,0,5) 
		# force_line.width_curve.set_point_value(0, size)
		force_factor = clamped_dtm / 315	
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)
		var collision: KinematicCollision2D = move_and_collide(velocity * delta)
		if collision:
				if GameManaager.is_player_turn:
					var shortest_collided = 100
					for collided_object in enemy_layer.get_children():
						print(global_position.distance_to(collided_object.global_position))
						if global_position.distance_to(collided_object.global_position) < 100:
							collided_object.bumped()
						main.apply_random_shake()
						
					if len(collided) != 0 and not GameManaager.start_game:
						collided[0].bumped()
				$NBumpSFX.play()
				var reflect = collision.get_remainder().bounce(collision.get_normal())
				velocity = velocity.bounce(collision.get_normal()) * 0.6
				move_and_collide(reflect)
		if velocity == Vector2.ZERO and not turn_ended:
			turn_ended = true
			is_moving = false
			$ice_trail.visible = false
			end_turn.emit()
			
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not GameManaager.is_player_turn:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if global_position.distance_to(get_global_mouse_position()) <= DEADZONE and not is_moving:
					is_moving = true
					is_on_hold = true
					force_line.visible = true
					force_line.clear_points()
					force_line.add_point(global_position)
					$Selected.visible = false
			else:
				if is_on_hold:
					$ice_trail.visible = true
					turn_ended = false
					is_on_hold = false
					direction = -global_position.direction_to(get_global_mouse_position())
					force_line.visible = false
					velocity = direction * SPEED * force_factor * 2
					$PuckSFX.play()


func _on_knockback_box_area_entered(area: Area2D) -> void:
	collided.append(area.get_parent())


func _on_knockback_box_area_exited(area: Area2D) -> void:
	collided.erase(area.get_parent())
