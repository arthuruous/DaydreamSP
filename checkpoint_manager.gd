extends Node2D

var last_location

@onready var player = $"../Player"

func _ready():
	last_location = player.global_position
