class_name GroundState
extends State

@export var air_state: State
@export var dash_state: State

func process_physics(delta: float) -> State:
	if not actor.is_on_floor():
		return air_state
		
	if actor.can_dash and actor.input_buffer.consume_action("dash", 0.1):
		return dash_state
		
	if actor.input_buffer.consume_action("jump", actor.stats.jump_buffer_seconds):
		actor.velocity.y = actor.stats.jump_velocity
		actor.coyote_timer = 0.0
		return air_state
		
	var axis: float = actor.get_input_axis()
	if axis != 0.0:
		actor.velocity.x = move_toward(actor.velocity.x, axis * actor.stats.max_speed, actor.stats.acceleration * delta)
	else:
		actor.velocity.x = move_toward(actor.velocity.x, 0.0, actor.stats.friction * delta)
		
	return null
