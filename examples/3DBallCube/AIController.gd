extends AIController

@onready var cube = get_parent()
@onready var ball = get_node("../../Ball")

var counter = 1

func collect_observations():
	add_observation(cube.rotation.x)
	add_observation(cube.rotation.y)
	add_observation(cube.rotation.z)
	add_observation(ball.position.x)
	add_observation(ball.position.y)
	add_observation(ball.position.z)
	add_observation(ball.velocity.x)
	add_observation(ball.velocity.y)

func set_action(actions):
	cube.rotate_x(actions[0])
	cube.rotate_z(actions[1])

func on_episode_begin():
	cube.rotation_degrees = Vector3.ZERO
	ball.position = Vector3(0, 0.86, 0)
	ball.velocity = Vector3.ZERO

func _physics_process(_delta):
	if ball.position.y < - 0.5:
		add_reward( - 1.0)
		end_episode()
	elif ball.get_last_slide_collision():
		add_reward(0.1)
	print("frame ", counter)
	counter += 1