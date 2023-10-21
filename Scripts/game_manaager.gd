extends Node

var is_player_turn: bool = false
var enemy_layer: Node2D
var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")
	enemy_layer = get_tree().current_scene.get_node("EnemyLayer")
	game_loop()


func game_loop() -> void:
	while(true):
		is_player_turn = false
		for enemy in enemy_layer.get_children():
			enemy.call_deferred("move")
			await enemy.end_turn
			
		is_player_turn = true
		await player.end_turn
	
