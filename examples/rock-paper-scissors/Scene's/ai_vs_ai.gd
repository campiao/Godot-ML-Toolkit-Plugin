extends Node2D

var player1_action = 3 # What Player Chose this Player_2.agentc_action
var player2_action = 3

@onready var CatBot_1 = $"Cat Hand" # Bot Hands
@onready var CatBot_2 = $"Cat Hand2" # Bot Hands
@onready var Anim_1 = $"Cat Hand/AnimationPlayer" # Bot Animation

@onready var Restart = $Buttons/Restart # Restart Button

@onready var Text = $Buttons/Text # Text Label

@onready var Player_1 = $Player1
@onready var Player_2 = $Player2
@onready var Manager = $AgentsManager

func get_last_agent_action(agent_requesting):
	if agent_requesting == "Player1":
		return Player_1.agent_action
	return Player_2.agent_action

func _on_restart_pressed():
	Text.visible = true # Hide Text
	step()

func _ready():
	pass

func step():
	Player_1.request_decision()
	Player_2.request_decision()
	Manager.request_decision()

	if Player_1.agent_action == 0: # What the CatBot Chose 0 = Rock
		CatBot_1.frame = 1 # CatBot Posing Rock
	elif Player_1.agent_action == 1: # What the CatBot Chose 1 = Paper
		CatBot_1.frame = 0 # CatBot Posing Paper
	elif Player_1.agent_action == 2: # What the CatBot Chose 2 = Scissors
		CatBot_1.frame = 2 # CatBot Posing Scissors

	if Player_2.agent_action == 0: # What the CatBot Chose 0 = Rock
		CatBot_2.frame = 1 # CatBot Posing Rock
	elif Player_2.agent_action == 1: # What the CatBot Chose 1 = Paper
		CatBot_2.frame = 0 # CatBot Posing Paper
	elif Player_2.agent_action == 2: # What the CatBot Chose 2 = Scissors
		CatBot_2.frame = 2 # CatBot Posing Scissors

	#Win Situation
	if Player_2.agent_action == 0 and Player_1.agent_action == 2: # CatBot Chose Scissors and Player Chose Rock
		Text.text = "Rock vs Scissors \n Player 2 Wins😹"
	if Player_2.agent_action == 1 and Player_1.agent_action == 0: # CatBot Chose Rock and Player Chose Paper
		Text.text = "Paper vs  Rock \n Player 2 Wins😹"
	if Player_2.agent_action == 2 and Player_1.agent_action == 1: # CatBot Chose Paper and Player Chose Scissors
		Text.text = "Scissors vs Paper \n Player 2 Wins😹"

	#Lose Situation
	if Player_2.agent_action == 0 and Player_1.agent_action == 1: # CatBot Chose Paper and Player Chose Rock
		Text.text = "Rock vs Paper \n Player 1 Wins😹"
	if Player_2.agent_action == 1 and Player_1.agent_action == 2: # CatBot Chose Scissors and Player Chose Paper
		Text.text = "Paper vs Scissors \n Player 1 Wins😹"
	if Player_2.agent_action == 2 and Player_1.agent_action == 0: # CatBot Chose Rock and Player Chose Scissors
		Text.text = "Scissors vs Rock \n Player 1 Wins😹"

	#Tie Situation
	if Player_2.agent_action == 0 and Player_1.agent_action == 0: # Both Chose Rock
		Text.text = "Both Chose Rock \n That's A Tie😸"
	if Player_2.agent_action == 1 and Player_1.agent_action == 1: # Both Chose Paper
		Text.text = "Both Chose Paper \n That's A Tie😸"
	if Player_2.agent_action == 2 and Player_1.agent_action == 2: # Both Chose Scissors
		Text.text = "Both Chose Scissors \n That's A Tie😸"
