class_name InputBuffer
extends Node

var _buffered_timestamps: Dictionary = {}

func record_action(action_name: String) -> void:
    _buffered_timestamps[action_name] = Time.get_ticks_msec()

func consume_action(action_name: String, window_seconds: float) -> bool:
    if not _buffered_timestamps.has(action_name):
        return false
    
    var recorded_time: int = _buffered_timestamps[action_name]
    var elapsed_seconds: float = (Time.get_ticks_msec() - recorded_time) / 1000.0
    
    if elapsed_seconds <= window_seconds:
        _buffered_timestamps.erase(action_name)
        return true
    
    return false

func clear_buffer() -> void:
    _buffered_timestamps.clear()
