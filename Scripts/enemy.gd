extends CharacterBody2D

@export var star_particles: PackedScene
const INITIAL_DIST_FROM_PLAYER: float = 300.0
const ERROR: Vector2 = Vector2(0.5,0.5)


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D
var collided = []

var turn_ended: bool = true

signal end_turn

func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")
	position.x = randf_range(-840, 850)
	position.y = randf_range(-366, 381)
	while global_position.distance_to(player.position) <= INITIAL_DIST_FROM_PLAYER:
		position.x = randf_range(-840, 850)
		position.y = randf_range(-366, 381)

func _physics_process(delta: float) -> void:
	if velocity == Vector2.ZERO and turn_ended == false:
		end_turn.emit()
		turn_ended = true
	velocity = velocity.move_toward(Vector2.ZERO, 300 * delta)
	move_and_slide()
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		print(player.global_position.distance_to(global_position))
		if not GameManaager.is_player_turn and player.global_position.distance_to(global_position) <= 90:
			GameManaager.lose_health()
		var reflect = collision.get_remainder().bounce(collision.get_normal())
		velocity = velocity.bounce(collision.get_normal()) * 0.6
		$NBumpSFX.play()
		move_and_collide(reflect)

func move() -> void:
	turn_ended = false
	var direction = noise(global_position.direction_to(player.global_position))
	velocity = direction * 300

func bumped() -> void:
	GameManaager.add_health()
	var direction = -global_position.direction_to(player.global_position)
	var timer = Timer.new()
	var star_particles_instance = star_particles.instantiate()
	get_tree().current_scene.add_child(star_particles_instance)
	star_particles_instance.global_position = global_position
	add_child(timer)
	timer.wait_time = 0.3
	timer.start()
	velocity = direction * 300
	$BumpSFX.play()
	await timer.timeout
	GameManaager.update_points()
	end_turn.emit()
	queue_free()

func noise(base: Vector2) -> Vector2:
	return Vector2(randf_range(base.x - ERROR.x, base.x + ERROR.x), randf_range(base.y - ERROR.y, base.y + ERROR.y)) 


func _on_knockback_box_area_entered(area: Area2D) -> void:
	print("Colliding with player", self)
	collided.append(area.get_parent())


func _on_knockback_box_area_exited(area: Area2D) -> void:
	print("Uncolliding with player", self)
	collided.erase(area.get_parent())
