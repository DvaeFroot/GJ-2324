extends Node

var is_player_turn: bool = false
var enemy_layer: Node2D
var player: CharacterBody2D

var enemy = preload("res://Scenes/enemy.tscn")
var rng = RandomNumberGenerator.new()
var enemycount = 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")
	enemy_layer = get_tree().current_scene.get_node("EnemyLayer")
	game_loop()


func game_loop() -> void:
	while(true):
		is_player_turn = false
		
		for enemy in enemy_layer.get_children():
			if enemy != null:
				enemy.call_deferred("move")
				await enemy.end_turn
			
		is_player_turn = true
		if enemy_layer.get_child_count() == 0:
			print("new wave")
			enemycount += 1
			for i in enemycount:
				var enemytemp = enemy.instantiate()
				enemytemp.position.x = rng.randi_range(-900, 800)
				enemytemp.position.y = rng.randi_range(-440, 440)
				# while true:
					# if enemytemp.position.x == bouncepad.position.x or enemytemp.position.y == bouncepad.position.y:
						# enemytemp.position.x = rng.randi_range(10, 1140)
						# enemytemp.position.y = rng.randi_range(10, 600)
					# else:
						# break
				enemy_layer.add_child(enemytemp)
		await player.end_turn
	
