class_name HitboxComponent
extends Area2D

signal hit_landed(target: Node2D, pogo_triggered: bool)

@export var base_damage: int = 10
@export var knockback_force: float = 280.0
@export var enables_downward_pogo: bool = true

func compute_knockback_vector(target_global_pos: Vector2) -> Vector2:
    var direction: Vector2 = global_position.direction_to(target_global_pos).normalized()
    return direction * knockback_force

func should_trigger_pogo(attack_direction: Vector2) -> bool:
    return enables_downward_pogo and attack_direction.y > 0.5
