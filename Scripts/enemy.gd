extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D

var turn_ended: bool = true

signal end_turn

func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		var reflect = collision.get_remainder().bounce(collision.get_normal())
		velocity = velocity.bounce(collision.get_normal()) * 0.6
		if collision.get_collider().is_in_group("Bouncepads"):
			velocity *= 10
		move_and_collide(reflect)
	if velocity == Vector2.ZERO and turn_ended == false:
		end_turn.emit()
		turn_ended = true
	velocity = velocity.move_toward(Vector2.ZERO, 300 * delta)
	move_and_slide()

func move() -> void:
	turn_ended = false
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300
	
func bumped() -> void:
	var direction = -global_position.direction_to(player.global_position)
	velocity = direction * 300
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.2
	timer.start()
	await timer.timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:r", 0, 0.2)
	tween.tween_callback(queue_free)
	
