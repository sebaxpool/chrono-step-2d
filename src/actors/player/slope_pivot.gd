class_name SlopePivot
extends Node2D

@export var player: CharacterBody2D
@export var ground_align_speed: float = 20.0
@export var air_align_speed: float = 8.0

@export_group("Ajuste Manual en Pendientes")
@export_range(0.0, 1.0, 0.05) var pivot_height_ratio: float = 0.5:
	set(value):
		pivot_height_ratio = value
		if _is_ready:
			_apply_pivot_layout()
@export_range(-30.0, 30.0, 0.5) var slope_slide_offset: float = 0.0
@export_range(-20.0, 20.0, 0.5) var slope_depth_offset: float = 0.0

var _is_ready: bool = false
var _base_center_pos: Vector2 = Vector2.ZERO
var _base_pivot_pos: Vector2 = Vector2.ZERO
var _half_height: float = 50.0
var _flat_half_width: float = 20.0
var _probe_half_width: float = 20.0
var _ray_margin: float = 62.0

func _ready() -> void:
	if not player and get_parent() is CharacterBody2D:
		player = get_parent() as CharacterBody2D
	if not player:
		return
	_setup_shape_metrics()
	_apply_pivot_layout()
	position = _base_pivot_pos
	_is_ready = true

func _setup_shape_metrics() -> void:
	var world_col := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not world_col or not world_col.shape:
		return

	var max_x: float = 25.0
	if world_col.shape is ConvexPolygonShape2D:
		var poly := world_col.shape as ConvexPolygonShape2D
		var max_y: float = 0.0
		max_x = 0.0
		for pt in poly.points:
			if pt.y > max_y:
				max_y = pt.y
			if absf(pt.x) > max_x:
				max_x = absf(pt.x)
		var flat_x: float = 0.0
		for pt in poly.points:
			if pt.y >= max_y - 1.0 and absf(pt.x) > flat_x:
				flat_x = absf(pt.x)
		_half_height = max_y
		_flat_half_width = maxf(flat_x, 1.0)
		_probe_half_width = maxf(minf(_flat_half_width, max_x - 1.0), 4.0)
	elif world_col.shape is RectangleShape2D:
		var rect := world_col.shape as RectangleShape2D
		_half_height = rect.size.y * 0.5
		_flat_half_width = rect.size.x * 0.5
		_probe_half_width = maxf(_flat_half_width - 1.0, 4.0)
	elif world_col.shape is CapsuleShape2D:
		var cap := world_col.shape as CapsuleShape2D
		_half_height = cap.height * 0.5
		_flat_half_width = cap.radius
		_probe_half_width = maxf(cap.radius * 0.5, 4.0)

	_ray_margin = (_probe_half_width * 2.4) + 14.0
	_base_center_pos = world_col.position

func _apply_pivot_layout() -> void:
	var pivot_y: float = _half_height * pivot_height_ratio
	var pivot_offset := Vector2(0.0, pivot_y)
	_base_pivot_pos = _base_center_pos + pivot_offset

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
	var target_offset: Vector2 = Vector2.ZERO
	var speed: float = air_align_speed

	if player.is_on_floor():
		var sample := _sample_slope()
		target_angle = sample.x
		target_offset = Vector2(sample.y, sample.z)
		speed = ground_align_speed

	var weight: float = minf(1.0, speed * delta)
	rotation = lerp_angle(rotation, target_angle, weight)
	position = position.lerp(_base_pivot_pos + target_offset, weight)

func _cast_foot_ray(space_state: PhysicsDirectSpaceState2D, x_pos: float, start_y: float, end_y: float) -> Dictionary:
	var query := PhysicsRayQueryParameters2D.create(Vector2(x_pos, start_y), Vector2(x_pos, end_y))
	query.exclude = [player.get_rid()]
	query.collision_mask = player.collision_mask
	query.collide_with_areas = false
	var hit := space_state.intersect_ray(query)
	if hit.is_empty():
		return {}
	var normal: Vector2 = hit["normal"]
	if normal.y > -0.5:
		return {}
	return hit

func _build_sample(angle: float, plane_point: Vector2, normal: Vector2, pivot_global: Vector2) -> Vector3:
	if absf(angle) < 0.01:
		return Vector3.ZERO
	var pivot_y: float = _half_height * pivot_height_ratio
	var dist_pivot_to_feet: float = _half_height - pivot_y
	var dist_to_plane: float = (pivot_global - plane_point).dot(normal)
	var gap: float = clampf(dist_to_plane - dist_pivot_to_feet, 0.0, _flat_half_width)
	var slope_factor: float = clampf(absf(angle) / (PI * 0.25), 0.0, 1.0)
	var downhill_dir := Vector2(-normal.y, normal.x) * signf(angle)
	var offset: Vector2 = (-normal * (gap + (slope_depth_offset * slope_factor))) + (downhill_dir * (slope_slide_offset * slope_factor))
	return Vector3(angle, offset.x, offset.y)

func _sample_slope() -> Vector3:
	var space_state := get_world_2d().direct_space_state
	var center_global := player.to_global(_base_center_pos)
	var pivot_global := player.to_global(_base_pivot_pos)
	var ray_end_y: float = center_global.y + _half_height + _ray_margin

	var hit_left := _cast_foot_ray(space_state, center_global.x - _probe_half_width, center_global.y, ray_end_y)
	var hit_right := _cast_foot_ray(space_state, center_global.x + _probe_half_width, center_global.y, ray_end_y)
	var has_left: bool = not hit_left.is_empty()
	var has_right: bool = not hit_right.is_empty()

	if has_left and has_right:
		var p_left: Vector2 = hit_left["position"]
		var p_right: Vector2 = hit_right["position"]
		var n_left: Vector2 = hit_left["normal"]
		var n_right: Vector2 = hit_right["normal"]
		var a_left: float = n_left.angle() + PI * 0.5
		var a_right: float = n_right.angle() + PI * 0.5
		if absf(a_left) < 0.01 and absf(a_right) < 0.01:
			return Vector3.ZERO
		var chord: Vector2 = p_right - p_left
		var chord_angle: float = atan2(chord.y, chord.x)
		var min_a: float = minf(a_left, a_right) - 0.04
		var max_a: float = maxf(a_left, a_right) + 0.04
		if chord_angle >= min_a and chord_angle <= max_a:
			var mid_point: Vector2 = (p_left + p_right) * 0.5
			var eff_normal := Vector2(sin(chord_angle), -cos(chord_angle))
			return _build_sample(chord_angle, mid_point, eff_normal, pivot_global)
		if p_left.y <= p_right.y:
			return _build_sample(a_left, p_left, n_left, pivot_global)
		return _build_sample(a_right, p_right, n_right, pivot_global)
	elif has_left:
		var n_left: Vector2 = hit_left["normal"]
		return _build_sample(n_left.angle() + PI * 0.5, hit_left["position"], n_left, pivot_global)
	elif has_right:
		var n_right: Vector2 = hit_right["normal"]
		return _build_sample(n_right.angle() + PI * 0.5, hit_right["position"], n_right, pivot_global)

	var hit_center := _cast_foot_ray(space_state, center_global.x, center_global.y, ray_end_y)
	if hit_center.is_empty():
		return Vector3.ZERO
	var n_center: Vector2 = hit_center["normal"]
	return _build_sample(n_center.angle() + PI * 0.5, hit_center["position"], n_center, pivot_global)
