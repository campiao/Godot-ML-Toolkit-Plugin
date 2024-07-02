extends Node

@export var wait_frames := 2
@export_range(1, 15, 1, "or_greater") var speed_scale: int = 1
@export var auto_start_episode := true
@export var enable_connection := true

const HOST: String = "127.0.0.1"
const GD_UPD_PORT: int = 7071
const DEFAULT_TCP_PORT: int = 5000
const DEFAULT_UDP_PORT: int = 5005
var tcp_stream: StreamPeerTCP = null
var udp_stream: PacketPeerUDP = null
var is_connected_to_server: bool = false
var frame_timer = load("res://addons/godot_ml_agents/frame_timer.gd")
var request_decision_timer

var all_agents: Array
var agents_training: Array
var agents_heuristic: Array
var agents_ready_to_send_obs: Array
var agents_done = []

var n_action_steps = 0

func _ready():
	if not enable_connection:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	await get_tree().root.ready
	get_tree().set_pause(true)
	initialize()
	get_tree().set_pause(false)

func _process(delta):
	poll_tcp_stream()

func poll_tcp_stream():
	var available_bytes = tcp_stream.get_available_bytes()
	if available_bytes > 0:
		var message = tcp_stream.get_var()
		if message == null:
			return
		if message == "freeze":
			freeze_game()
		elif message == "unfreeze":
			unfreeze_game()
		elif message == "reset":
			begin_episode()

func initialize():
	process_mode = Node.PROCESS_MODE_ALWAYS
	request_decision_timer = frame_timer.new()
	request_decision_timer.wait_frames = wait_frames
	add_child(request_decision_timer)
	request_decision_timer.connect("timeout", request_decision)
	Engine.physics_ticks_per_second = 60 * speed_scale
	Engine.time_scale = speed_scale

	register_agents()
	establish_connection()

func establish_connection():
	is_connected_to_server = connect_to_server()
	if is_connected_to_server:
		handshake()
		send_env_info()

func _physics_process(_delta):
	pass

func request_decision():
	heuristic_process()
	process_agents_ready()

func process_agents_ready():
	if is_connected_to_server:
		
		set_agents_ready()
		if not agents_ready_to_send_obs.is_empty():
			var reply = []
			for agent in agents_ready_to_send_obs:
				var agent_data = get_agent_data_to_send(agent)
				reply.append(agent_data)
			send_message(reply)
			check_if_episode_ends()
			if not agents_done.is_empty():
				reset_agents_ready()
				return
			handle_recieved_message()
			reset_agents_ready()

func check_if_episode_ends():
	agents_done = []
	for agent in all_agents:
		if agent.done:
			agents_done.append(agent)
	if auto_start_episode:
		begin_episode(agents_done)

func reset_agents_ready():
	for agent in agents_ready_to_send_obs:
		agent.need_to_send_obs = false
	
	agents_ready_to_send_obs = []

func heuristic_process():
	set_heuristic_agents_ready()
	if not agents_ready_to_send_obs.is_empty():
		for agent in agents_ready_to_send_obs:
			agent.heuristic_process()
	reset_agents_ready()

func set_agents_ready():
	for agent in agents_training:
		if agent.need_to_send_obs:
			agents_ready_to_send_obs.append(agent)
		
func set_heuristic_agents_ready():
	for agent in agents_heuristic:
		if agent.need_to_send_obs:
			agents_ready_to_send_obs.append(agent)
			
func register_agents():
	all_agents = get_tree().get_nodes_in_group("Agents")
	print(all_agents)
	var id_index = 0
	for agent in all_agents:
		agent.id = id_index
		id_index += 1
		agent.connect_signals_to_manager(self)
		if agent.mode == agent.Modes.TRAINING:
			agents_training.append(agent)
		elif agent.mode == agent.Modes.HEURISTIC:
			agents_heuristic.append(agent)

func handshake():
	var message = "handshake"
	tcp_stream.put_data(message.to_ascii_buffer())
	
	message = tcp_stream.get_var()
	if message == "handshake":
		print("Connection established!")

func send_env_info():
	var data = [len(agents_training)]
	for agent in agents_training:
		var info = agent.get_agent_info()
		data.append(info)
	udp_stream.put_var(data) # TODO: change to TCP Stream

func connect_to_server():
	print("Connecting to TCP server")
	tcp_stream = StreamPeerTCP.new()
	udp_stream = PacketPeerUDP.new()
	udp_stream.bind(GD_UPD_PORT, HOST)

	udp_stream.connect_to_host(HOST, DEFAULT_UDP_PORT)

	tcp_stream.connect_to_host(HOST, DEFAULT_TCP_PORT)
	tcp_stream.poll()
	while tcp_stream.get_status() < 2:
		tcp_stream.poll()
	return tcp_stream.get_status() == 2

func disconnect_from_server():
	tcp_stream.disconnect_from_host()

func handle_recieved_message():
	while udp_stream.get_available_packet_count() == 0:
		pass
	var message = udp_stream.get_var()
	if message != null:
		set_agent_actions(message)

func send_message(data):
	udp_stream.put_var(data)

func get_agent_data_to_send(agent):
	var data = []
	data.append_array([agent.id, agent.type, agent.team, agent.get_obs(), agent.reward, agent.done])
	return data

func set_agent_actions(actions_info):
	for actions in actions_info:
		var agent_id = actions[0]
		var action = actions[1]
		var agent = get_agent_by_id(agent_id)
		agent.set_action(action)

func get_agent_by_id(agent_id):
	for agent in all_agents:
		if agent.id == agent_id:
			return agent
	
	return null

func begin_episode(agents: Array=all_agents):
	for agent in agents:
		agent.done = false
		agent.reward = 0
		agent.on_episode_begin()

func freeze_game():
	get_tree().paused = true
	print("Game paused")

func unfreeze_game():
	get_tree().paused = false
	print("Game unpaused")
