extends Node

signal game_over

# Satalite Notificando posição do Player, Notificando Inimigo Position Player
var player: Player
var player_position: Vector2
#_____________________________________
var is_game_over: bool = false

var time_elapsed: float = 0
var time_elapsed_string: String
var meat_counter: int = 0
var monsters_defeated_counter: int = 0

func _process(delta: float):
	# Atualiza o temporizador
	time_elapsed += delta
	# Converte o tempo decorrido em segundos e minutos
	var time_elapsed_in_seconds: int = floor(time_elapsed)
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int = time_elapsed_in_seconds / 60
	# Formata o texto do temporizador no formato MM:SS
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]


func end_game():
	
	if is_game_over: return
	is_game_over = true
	game_over.emit()
	
func reset():
	player = null
	player_position = Vector2.ZERO
	is_game_over= false
	
	time_elapsed = 0.0
	time_elapsed_string = "00:00"
	meat_counter = 0
	monsters_defeated_counter = 0

	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
