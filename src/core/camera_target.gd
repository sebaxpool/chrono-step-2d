class_name CameraTarget
extends CharacterBody2D

@export var target: CharacterBody2D
@export var precision_window_x: float = 45.0
@export var max_lookahead_speed: float = 220.0

func _ready() -> void:
	process_physics_priority = 100
	if target:
		global_position = target.global_position

func _physics_process(_delta: float) -> void:
	if not target:
		return
	global_position.y = target.global_position.y
	velocity.y = target.velocity.y
	var diff_x: float = target.global_position.x - global_position.x
	if absf(diff_x) > precision_window_x:
		global_position.x = target.global_position.x - signf(diff_x) * precision_window_x
		velocity.x = clampf(target.velocity.x, -max_lookahead_speed, max_lookahead_speed)
	else:
		velocity.x = 0.0
