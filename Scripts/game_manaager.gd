extends Node

var is_player_turn: bool = false
var enemy_layer: Node2D
var player: CharacterBody2D
var wave_has_started: bool = false
var health = 2
var start_game: bool = false

var background_music
var enemy_spawners
var wave = 0
var wave_finished = false
var points = 0
var point_label: Label
var player_health = 3
var player_health_label: Label

@onready var enemy = preload("res://Scenes/enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")
	enemy_layer = get_tree().current_scene.get_node("EnemyLayer")
	background_music = get_tree().current_scene.get_node("BackgroundMusic")
	background_music.play()
	enemy_spawners = get_tree().current_scene.get_node("EnemySpawners")
	point_label = get_tree().current_scene.get_node("CenterContainer/PointLabel")
	player_health_label = get_tree().current_scene.get_node("Player/CenterContainer/Label")
	point_label.text = str(points)
	player_health_label.text = str(player_health)
	game_loop()
	
func update_points() -> void:
	points += 1
	point_label.text = str(points)
	add_health()
	
func lose_health() -> void:
	player_health -= 1
	player_health_label.text = str(player_health)
	
	
func next_wave() -> void:
	for spawner in enemy_spawners.get_children()[wave].get_children():
		var enemy_instance = enemy.instantiate()
		enemy_layer.add_child(enemy_instance)
		enemy_instance.position = spawner.position
	wave_finished = false


func finish_wave() -> void:
	wave_has_started = true
	await get_tree().create_timer(0.2)
	next_wave()
	wave += 1

func add_health():
	if points%5 == 0:
		player_health += 1
		player_health_label.text = str(player_health)

func game_loop() -> void:
	while(not wave_finished):
		is_player_turn = true
		if not start_game:
			await player.end_turn
			continue
		else:
			await player.end_turn
				
		if enemy_layer.get_child_count() == 0 and start_game:
			print("pota")
			await finish_wave()
			continue
		print("hello")
		
		is_player_turn = false
		if wave_has_started:
			for enemy in enemy_layer.get_children():
				if enemy != null:
					enemy.call_deferred("move")
					await enemy.end_turn
