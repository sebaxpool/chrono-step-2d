class_name PlayerController
extends CharacterBody2D

@export var stats: MovementData
@onready var state_machine: StateMachine = $StateMachine
@onready var input_buffer: InputBuffer = $InputBuffer

var facing_direction: int = 1
var coyote_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var can_dash: bool = true

func _ready() -> void:
    assert(stats != null, "MovementData resource must be assigned to PlayerController.")
    state_machine.init(self)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("jump"):
        input_buffer.record_action("jump")
    if event.is_action_pressed("dash"):
        input_buffer.record_action("dash")
    state_machine.process_input(event)

func _physics_process(delta: float) -> void:
    _update_timers(delta)
    state_machine.process_physics(delta)
    
    if velocity.y < 0.0:
        _attempt_corner_correction(delta)
        
    move_and_slide()

func _update_timers(delta: float) -> void:
    if is_on_floor():
        coyote_timer = stats.coyote_time_seconds
        if dash_cooldown_timer <= 0.0:
            can_dash = true
    else:
        coyote_timer = maxf(0.0, coyote_timer - delta)
        
    if dash_cooldown_timer > 0.0:
        dash_cooldown_timer = maxf(0.0, dash_cooldown_timer - delta)

func apply_adaptive_gravity(delta: float) -> void:
    var base_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
    var multiplier: float = 1.0
    
    if absf(velocity.y) < stats.apex_threshold:
        multiplier = stats.apex_gravity_multiplier
    elif velocity.y > 0.0:
        multiplier = stats.fall_gravity_multiplier
        
    velocity.y = minf(velocity.y + (base_gravity * multiplier * delta), stats.max_fall_speed)

func get_input_axis() -> float:
    var axis: float = Input.get_axis("move_left", "move_right")
    if axis != 0.0:
        facing_direction = signi(int(axis))
    return axis

func _attempt_corner_correction(delta: float) -> void:
    var motion: Vector2 = Vector2(0.0, velocity.y * delta)
    if not test_move(global_transform, motion):
        return
        
    for offset in range(1, stats.corner_correction_pixels + 1):
        for direction in [-1, 1]:
            var test_transform: Transform2D = global_transform.translated(Vector2(offset * direction, 0))
            if not test_move(test_transform, motion):
                global_position.x += offset * direction
                return
