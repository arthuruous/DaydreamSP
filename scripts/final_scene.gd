extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_position: Node2D
@export var initial_wave_size: int = 3
@export var wave_increase: int = 2
@export var damage_increase: int = 1
@export var spawn_delay: float = 2.0

var current_wave: int = 1
var enemies_remaining: int
var enemy_base_damage: int = 1

func _ready() -> void:
	start_wave()

func start_wave() -> void:
	var wave_size = initial_wave_size + (current_wave - 1) * wave_increase
	enemies_remaining = wave_size

	for i in range(wave_size):
		spawn_enemy()

func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position.global_position
	enemy.base_damage = enemy_base_damage
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)

func _on_enemy_died(enemy) -> void:
	enemies_remaining -= 1
	enemy.queue_free()

	if enemies_remaining <= 0:
		# prepara a próxima onda
		current_wave += 1
		enemy_base_damage += damage_increase
		await get_tree().create_timer(spawn_delay).timeout
		start_wave()
Enemy:extends CharacterBody2D

@export var base_damage: int = 1
@export var speed: float = 100.0
@onready var player = get_tree().get_first_node_in_group("player")

signal died(enemy)

func _physics_process(delta: float) -> void:
	if player:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

		if global_position.distance_to(player.global_position) < 20:
			player.take_damage(base_damage)

func take_damage(amount: int) -> void:
	# você pode ter um sistema de vida no inimigo
	emit_signal("died", self)
