extends Node

@onready var health_progress_bar = $HealthProgressBar
@onready var mana_progress_bar = $ManaProgressBar



func update_bars(health_max, health, max_mana, mana):
	health_progress_bar.max_value = health_max
	health_progress_bar.value = health

	mana_progress_bar.max_value = max_mana
	mana_progress_bar.value = mana
	
	

func _process(delta) -> void:
	var player_position = GameManager.player_position
	if player_position:
		# Atualiza a posição das barras de vida e mana para acompanhar o jogador
		health_progress_bar.global_position = player_position + Vector2 (-35, 10)
		mana_progress_bar.position = player_position + Vector2 (-35, 20)
