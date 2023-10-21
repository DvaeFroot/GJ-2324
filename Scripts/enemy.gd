extends CharacterBody2D

const INITIAL_DIST_FROM_PLAYER: float = 300.0
const ERROR: Vector2 = Vector2(0.5,0.5)
@onready var background_music = $"../../BackgroundMusic"


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D

var turn_ended: bool = true

signal end_turn

func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")
	position.x = randf_range(-840, 850)
	position.y = randf_range(-366, 381)
	while global_position.distance_to(player.position) <= INITIAL_DIST_FROM_PLAYER:
		position.x = randf_range(-840, 850)
		position.y = randf_range(-366, 381)
	background_music.play()

func _physics_process(delta: float) -> void:
	if velocity == Vector2.ZERO and turn_ended == false:
		end_turn.emit()
		turn_ended = true
	velocity = velocity.move_toward(Vector2.ZERO, 300 * delta)
	move_and_slide()
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
			var reflect = collision.get_remainder().bounce(collision.get_normal())
			velocity = velocity.bounce(collision.get_normal()) * 0.6
			move_and_collide(reflect)

func move() -> void:
	turn_ended = false
	var direction = noise(global_position.direction_to(player.global_position))
	velocity = direction * 300

func bumped() -> void:
	var direction = -global_position.direction_to(player.global_position)
	velocity = direction * 300
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.3
	timer.start()
	await timer.timeout
	queue_free()

func noise(base: Vector2) -> Vector2:
	return Vector2(randf_range(base.x - ERROR.x, base.x + ERROR.x), randf_range(base.y - ERROR.y, base.y + ERROR.y)) 
