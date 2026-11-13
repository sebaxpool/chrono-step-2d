class_name DashJumpState
extends AirState

@export var air_state: State

func enter(_msg: Dictionary = {}) -> void:
	actor.velocity.y = actor.stats.jump_velocity
	actor.coyote_timer = 0.0

func process_physics(delta: float) -> State:
	if actor.is_on_wall_only() and actor.velocity.y > 0.0:
		return air_state
	return super.process_physics(delta)

func _get_horizontal_speed() -> float:
	return actor.stats.dash_speed
