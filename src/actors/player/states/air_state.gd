class_name AirState
extends State

@export var ground_state: State
@export var dash_state: State

func process_input(event: InputEvent) -> State:
    if event.is_action_released("jump") and actor.velocity.y < 0.0:
        actor.velocity.y *= actor.stats.jump_cut_multiplier
    return null

func process_physics(delta: float) -> State:
    actor.apply_adaptive_gravity(delta)
    
    if actor.can_dash and actor.input_buffer.consume_action("dash", 0.1):
        return dash_state
        
    if actor.coyote_timer > 0.0 and actor.input_buffer.consume_action("jump", actor.stats.jump_buffer_seconds):
        actor.velocity.y = actor.stats.jump_velocity
        actor.coyote_timer = 0.0
        return null
        
    if actor.is_on_wall_only() and actor.velocity.y > 0.0:
        actor.velocity.y = minf(actor.velocity.y, actor.stats.wall_slide_speed)
        if actor.input_buffer.consume_action("jump", actor.stats.jump_buffer_seconds):
            var wall_normal: Vector2 = actor.get_wall_normal()
            actor.velocity.x = wall_normal.x * actor.stats.wall_jump_force.x
            actor.velocity.y = actor.stats.wall_jump_force.y
            return null
            
    var axis: float = actor.get_input_axis()
    if axis != 0.0:
        actor.velocity.x = move_toward(actor.velocity.x, axis * actor.stats.max_speed, actor.stats.air_acceleration * delta)
    else:
        actor.velocity.x = move_toward(actor.velocity.x, 0.0, actor.stats.air_resistance * delta)
        
    if actor.is_on_floor():
        return ground_state
        
    return null
