class_name DashState
extends State

@export var ground_state: State
@export var air_state: State

var _dash_timer: float = 0.0
var _dash_direction: int = 1

func enter(_msg: Dictionary = {}) -> void:
    actor.can_dash = false
    actor.dash_cooldown_timer = actor.stats.dash_cooldown
    _dash_timer = actor.stats.dash_duration
    
    var axis: float = actor.get_input_axis()
    _dash_direction = int(signf(axis)) if axis != 0.0 else actor.facing_direction
    actor.velocity = Vector2(_dash_direction * actor.stats.dash_speed, 0.0)

func process_physics(delta: float) -> State:
    _dash_timer -= delta
    actor.velocity.y = 0.0
    actor.velocity.x = _dash_direction * actor.stats.dash_speed
    
    if _dash_timer <= 0.0:
        actor.velocity.x *= 0.5
        return ground_state if actor.is_on_floor() else air_state
        
    return null
