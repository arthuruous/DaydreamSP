extends CharacterBody2D

@export var speed: float = 150.0
@export var health: int = 100
@export var gravity: float = 800.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0
@export var attack_range: float = 36.0

@onready var sprite := get_node_or_null("AnimatedSprite2D")

signal died(enemy)

var can_attack: bool = true
var target: Node = null

func _ready() -> void:
	add_to_group("enemy")
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float) -> void:
	if not target:
		var ps := get_tree().get_nodes_in_group("player")
		if ps.size() > 0:
			target = ps[0]
		else:
			return

	# gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# direção até o player
	var to_player: Vector2 = target.global_position - global_position

	if abs(to_player.x) > 4:
		velocity.x = sign(to_player.x) * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta)

	move_and_slide()

	# flip sprite
	if sprite:
		sprite.flip_h = velocity.x < 0

	# atacar
	if to_player.length() <= attack_range:
		attack_player()

func attack_player() -> void:
	if not can_attack: return
	if target and target.has_method("take_damage"):
		target.take_damage(attack_damage)
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func take_damage(amount: int) -> void:
	health -= amount
	print("Inimigo levou %d de dano — vida: %d" % [amount, health])
	if health <= 0:
		die()

func die() -> void:
	print("Inimigo morreu!")
	emit_signal("died", self)

	var parent_node = get_parent()
	if parent_node != null:
		for offset in [Vector2(40,0), Vector2(-40,0)]:
			var new_enemy = duplicate()  # clona o nó
			parent_node.add_child(new_enemy)
			new_enemy.global_position = global_position + offset
			
			# **reset completo do clone**
			new_enemy.health = 100  # vida cheia
			new_enemy.can_attack = true
			new_enemy.target = null
			new_enemy.set_process(true)
			new_enemy.set_physics_process(true)
			
			# encontrar o player novamente
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				new_enemy.target = players[0]

	queue_free()
