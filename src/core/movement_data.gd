class_name MovementData
extends Resource

@export_group("Horizontal Movement")
@export var max_speed: float = 260.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var air_resistance: float = 650.0
@export var air_acceleration: float = 1400.0

@export_group("Vertical & Jump Mechanics")
@export var jump_velocity: float = -420.0
@export var jump_cut_multiplier: float = 0.45
@export var apex_threshold: float = 45.0
@export var apex_gravity_multiplier: float = 0.65
@export var fall_gravity_multiplier: float = 1.45
@export var max_fall_speed: float = 650.0

@export_group("Assist & Precision Windows")
@export var coyote_time_seconds: float = 0.11
@export var jump_buffer_seconds: float = 0.12
@export var corner_correction_pixels: int = 6

@export_group("Dash & Wall Mechanics")
@export var dash_speed: float = 580.0
@export var dash_duration: float = 0.16
@export var dash_cooldown: float = 0.45
@export var wall_slide_speed: float = 110.0
@export var wall_jump_force: Vector2 = Vector2(310.0, -390.0)
