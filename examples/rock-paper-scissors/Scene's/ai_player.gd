extends AIController

@onready var world = get_parent()

var agent_action = 3

func collect_observations():
	add_observation(world.get_last_agent_action(name))

func set_action(action):
	agent_action = action

func on_episode_begin():
	agent_action = 3
