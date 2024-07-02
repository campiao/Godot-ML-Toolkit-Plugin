extends Node
class_name AIController

enum Modes {HEURISTIC, TRAINING}

@export var mode: Modes = Modes.TRAINING
@export var max_num_steps: int = 1000
@export var wait_frames: int = 60
@export var type: String = "Default"
@export var team: int = 0

@export_category("Action Vector")
@export var continuous_space_size: int = 0
@export var discrete_space_size: int = 0

@export_category("Observation Vector")
@export var observation_space_size: int = 1

signal turn_based_needs_to_send_obs

var done: bool = false
var reward: float = 0.0
var n_steps: int = 0
var need_to_send_obs: bool = false
var frame_timer = load("res://addons/godot_ml_agents/frame_timer.gd")
var request_decision_timer
var id: int
var observation_vector = []
var actions_vector = []

func _ready():
	_initialize()

func _initialize():
	add_to_group("Agents")
	request_decision_timer = frame_timer.new()
	request_decision_timer.wait_frames = wait_frames
	add_child(request_decision_timer)
	print("wait frames: ", request_decision_timer.wait_frames)
	request_decision_timer.connect("timeout", request_decision)
	
func get_type():
	return type

func get_team():
	return team

func get_obs():
	observation_vector = []
	collect_observations()
	var response = observation_vector
	var lenght = len(observation_vector)
	if lenght < observation_space_size:
		print("Warning: observation vector size is smaller than expected, adding zero padding")
		var zero_num = observation_space_size - lenght
		for i in range(zero_num):
			response.append(0)
	elif lenght > observation_space_size:
		print("Warning: observation vector size is larger than expected, cutting to expected size")
		response = response # TODO: fix lenght to max lenght allowed
	return response

func collect_observations():
	assert(false, "Collect observation method not implemented yet")

func get_obs_space():
	return observation_space_size

func get_reward():
	return reward

func get_action_space():
	return [continuous_space_size, discrete_space_size]

func get_agent_info():
	return [id, type, team, observation_space_size, continuous_space_size, discrete_space_size]

func get_done():
	return done

func set_action(_action):
	assert(false, "set_action method is not implemented yet")

func on_episode_begin():
	assert(false, "on_episode_begin method is not implemented yet")

func heuristic_process():
	assert(false, "heuristic_process method is not implemented yet")

func _physics_process(_delta):
	pass

func request_decision():
	set_ready_to_send_obs()

func reset():
	n_steps = 0

func reset_if_done():
	if done:
		reset()

func set_done(value: bool):
	done = value

func set_ready_to_send_obs():
	need_to_send_obs = true

func connect_signals_to_manager(manager: Node):
	turn_based_needs_to_send_obs.connect(manager.process_agents_ready)

func turn_based_request_action():
	emit_signal("turn_based_needs_to_send_obs")

func zero_reward():
	reward = 0.0

func add_reward(value: float):
	reward += value

func add_observation(obs):
	observation_vector.append(obs)

func end_episode():
	done = true
