extends Area2D

var checkpoint

func _ready():
	checkpoint = get_parent().get_parent().get_node("Checkpoint")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		checkpoint.last_location = $Marker2D.global_position
