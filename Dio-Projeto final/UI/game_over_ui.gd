class_name GameOverUI
extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var monster_kill_label: Label = %MobsKillsLabel

@export var restart_delay: float = 5.0
var restart_cooldown: float

func _ready():
	# Tempo para resetar o jogo apos o game Over
	time_label.text = GameManager.time_elapsed_string
	monster_kill_label.text = str(GameManager.monsters_defeated_counter)
	restart_cooldown = restart_delay
	
func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()
			
func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()
	print("Restart game please!")
	pass

