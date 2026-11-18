class_name SlopePivot
extends Node2D

@export var player: CharacterBody2D
@export var ground_align_speed: float = 20.0
@export var air_align_speed: float = 8.0

var _bottom_radius: float = 25.0

func _ready() -> void:
	if not player and get_parent() is CharacterBody2D:
		player = get_parent() as CharacterBody2D
	if not player:
		return
	_setup_bottom_pivot()

func _setup_bottom_pivot() -> void:
	var world_col := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not world_col or not world_col.shape:
		return

	var pivot_offset := Vector2.ZERO
	if world_col.shape is CapsuleShape2D:
		var cap := world_col.shape as CapsuleShape2D
		_bottom_radius = cap.radius
		pivot_offset = Vector2(0.0, (cap.height * 0.5) - cap.radius)
	elif world_col.shape is RectangleShape2D:
		var rect := world_col.shape as RectangleShape2D
		_bottom_radius = rect.size.x * 0.5
		pivot_offset = Vector2(0.0, rect.size.y * 0.5)

	# Ubicar el pivote en el centro exacto de la base de los pies
	position = world_col.position + pivot_offset

	# Compensar hijos para que a 0 grados coincidan 1:1 con la capsula azul
	var child_offset := -pivot_offset
	var visuals := get_node_or_null("Visuals") as Node2D
	if visuals:
		visuals.position = child_offset

	var hurtbox := get_node_or_null("HurtboxComponent") as Node2D
	if hurtbox:
		hurtbox.position = Vector2.ZERO
		var hurt_col := hurtbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if hurt_col:
			hurt_col.position = child_offset

func _physics_process(delta: float) -> void:
	if not player:
		return

	var target_angle: float = 0.0
	if player.is_on_floor():
		target_angle = _get_true_slope_angle()
		rotation = lerp_angle(rotation, target_angle, ground_align_speed * delta)
	else:
		rotation = lerp_angle(rotation, 0.0, air_align_speed * delta)

func _get_true_slope_angle() -> float:
	var space_state := get_world_2d().direct_space_state
	var ray_length: float = (_bottom_radius * 2.2) + 6.0
	var query := PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0.0, ray_length))
	query.exclude = [player.get_rid()]
	query.collision_mask = player.collision_mask
	query.collide_with_areas = false

	var hit := space_state.intersect_ray(query)
	if hit.is_empty():
		return 0.0

	var normal: Vector2 = hit["normal"]
	if normal.y > -0.5:
		return 0.0

	return normal.angle() + PI * 0.5
