class_name StateMachine
extends Node

@export var initial_state: State
var current_state: State

func init(actor: PlayerController) -> void:
	for child in get_children():
		if child is State:
			child.actor = actor
			
	if initial_state:
		current_state = initial_state
		current_state.enter()

func change_state(new_state: State, msg: Dictionary = {}) -> void:
	if new_state == null or new_state == current_state:
		return
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter(msg)

func process_input(event: InputEvent) -> void:
	var next_state: State = current_state.process_input(event)
	if next_state:
		change_state(next_state)

func process_physics(delta: float) -> void:
	var next_state: State = current_state.process_physics(delta)
	if next_state:
		change_state(next_state)
