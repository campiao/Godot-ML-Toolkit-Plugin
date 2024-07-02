extends Node
class_name FrameTimer

signal timeout

var wait_frames: int = 60
var n_steps: int = 0

func _physics_process(delta):
	if wait_frames == 0:
		n_steps += 1
		return
	
	if n_steps % wait_frames != 0:
		n_steps += 1
		return
	
	n_steps += 1
	timeout.emit()