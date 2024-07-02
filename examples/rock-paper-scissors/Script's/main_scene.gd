extends Node2D

var Round # What Player Chose this Round
var ai_action = 3

@onready var CatBot = $"Cat Hand" # Bot Hands
@onready var Anim = $"Cat Hand/AnimationPlayer" # Bot Animation

@onready var Rock = $Buttons/Options/Rock # Rock Button
@onready var Paper = $Buttons/Options/Paper # Paper Button
@onready var Scissors = $Buttons/Options/Scissors # Scissors Button

@onready var Restart = $Buttons/Restart # Restart Button

@onready var Text = $Buttons/Text # Text Label

@onready var AI_Player = $AIController
@onready var Manager = $AgentsManager

func get_last_agent_action(_name):
	return Round

func _on_rock_pressed():
	Rock.disabled = true # Disable Button
	Paper.disabled = true # Disable Button
	Scissors.disabled = true # Disable Button
	Anim.play("Show Hands") # Play Show Hands Animation
	Round = 0 # Player Chose Rock
	Text.visible = true # Show Text
	step()

func _on_paper_pressed():
	Rock.disabled = true # Disable Button
	Paper.disabled = true # Disable Button
	Scissors.disabled = true # Disable Button
	Anim.play("Show Hands") # Play Show Hands Animation
	Round = 1 # Player Chose Paper
	Text.visible = true # Show Text
	step()

func _on_scissors_pressed():
	Rock.disabled = true # Disable Button
	Paper.disabled = true # Disable Button
	Scissors.disabled = true # Disable Button
	Anim.play("Show Hands") # Play Show Hands Animation
	Round = 2 # Player Chose Scissors
	Text.visible = true # Show Text
	step()

func _on_restart_pressed():
	Rock.disabled = false # Enable Button
	Paper.disabled = false # Enable Button
	Scissors.disabled = false # Enable Button
	Anim.play("Hide Hands") # Play Hide Hands Animation
	Round = 3 # No more Bugs HeHe
	Text.visible = false # Hide Text
	ai_action = Manager.begin_episode()

func _ready():
	Anim.play("Hide Hands") # I used this on func ready because there was a bug the Hand shows up at start

func step():
	AI_Player.request_decision()
	Manager.request_decision()
	ai_action = AI_Player.agent_action
	if ai_action == 0: # What the CatBot Chose 0 = Rock
		CatBot.frame = 1 # CatBot Posing Rock
	elif ai_action == 1: # What the CatBot Chose 1 = Paper
		CatBot.frame = 0 # CatBot Posing Paper
	elif ai_action == 2: # What the CatBot Chose 2 = Scissors
		CatBot.frame = 2 # CatBot Posing Scissors

	#Win Situation
	if Round == 0 and ai_action == 2: # CatBot Chose Scissors and Player Chose Rock
		Text.text = "Cat Chose Scissors \n You Won😿"
	if Round == 1 and ai_action == 0: # CatBot Chose Rock and Player Chose Paper
		Text.text = "Cat Chose Rock \n You Won😿"
	if Round == 2 and ai_action == 1: # CatBot Chose Paper and Player Chose Scissors
		Text.text = "Cat Chose Paper \n You Won😿"

	#Lose Situation
	if Round == 0 and ai_action == 1: # CatBot Chose Paper and Player Chose Rock
		Text.text = "Cat Chose Paper \n You Lose😹"
	if Round == 1 and ai_action == 2: # CatBot Chose Scissors and Player Chose Paper
		Text.text = "Cat Chose Scissors \n You Lose😹"
	if Round == 2 and ai_action == 0: # CatBot Chose Rock and Player Chose Scissors
		Text.text = "Cat Chose Rock \n You Lose😹"

	#Tie Situation
	if Round == 0 and ai_action == 0: # Both Chose Rock
		Text.text = "Both Chose Rock \n That's A Tie😸"
	if Round == 1 and ai_action == 1: # Both Chose Paper
		Text.text = "Both Chose Paper \n That's A Tie😸"
	if Round == 2 and ai_action == 2: # Both Chose Scissors
		Text.text = "Both Chose Scissors \n That's A Tie😸"
