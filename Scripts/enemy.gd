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
	queue_free()
	# var enemies = get_tree().get_nodes_in_group("Enemy")
	# print(enemies.size())
	# if enemies.size() == 1:
		# print("level complete")
		# get_tree().change_scene_to_file("res://Scenes/main.tscn")
