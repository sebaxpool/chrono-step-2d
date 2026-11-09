class_name State
extends Node

var actor: PlayerController

func enter(_msg: Dictionary = {}) -> void:
    pass

func exit() -> void:
    pass

func process_input(_event: InputEvent) -> State:
    return null

func process_physics(_delta: float) -> State:
    return null
