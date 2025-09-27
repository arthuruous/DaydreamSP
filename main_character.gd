extends CharacterBody2D

@onready var animated_sprite_2d := get_node_or_null("AnimatedSprite2D")

const SPEED := 300.0
const JUMP_VELOCITY := -400.0

@export var max_health: int = 100
var health: int = max_health

@export var attack_damage: int = 30
@export var attack_range: float = 48.0

signal player_died

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if abs(velocity.x) > 1:
		if animated_sprite_2d:
			animated_sprite_2d.animation = "running"
	else:
		if animated_sprite_2d:
			animated_sprite_2d.animation = "default"

	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
		if animated_sprite_2d:
			animated_sprite_2d.animation = "jumping"

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var dir := Input.get_axis("left", "right")
	if dir != 0:
		velocity.x = dir * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * delta)

	move_and_slide() 

	if animated_sprite_2d:
		animated_sprite_2d.flip_h = velocity.x < 0

	if Input.is_action_just_pressed("fight"):
		attack()

func attack() -> void:
	var enemies := get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if e and e.is_inside_tree() and e.global_position.distance_to(global_position) <= attack_range:
			if e.has_method("take_damage"):
				e.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	health = clamp(health - amount, 0, max_health)
	print("Player levou %d de dano — vida: %d/%d" % [amount, health, max_health])
	if health <= 0:
		die()

func die() -> void:
	print("Você morreu!")
	emit_signal("player_died")
