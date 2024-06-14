extends Node


@export var mob_spawner: MobSpawner
@export var initial_spaw_rate: float = 60
@export var spawn_rate_per_minute: float = 30
@export var wave_duration: float = 20
@export var break_intensity: float = 0.5

var time: float = 0.0

func _process(delta: float) -> void:
	# Ignorar GameOver
	if GameManager.is_game_over: return
	
	# Incrementar Temporizador
	time += delta
	
	# Dificuldade Linear Linha Verde
	var spawn_rate = initial_spaw_rate + spawn_rate_per_minute * (time / 60.0)
	
	
	# Sistema de ondas(Linha Rosa)
	var sin_wave = sin((time * TAU) / wave_duration)
	# a função sin é um angulo radiante que utiliza como parametro PI e TAU
	# PI = 3,14, TAU é PI * 2 = 6,28
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	# função remap, ela pega uma variavel, entende o minimo e maximo dela
	# e tranforma em um novo minimo e maximo dessa função
	# colocando dentro dos parametros  outra variavel com novo valor
	#nesse caso é o break_intensity
	#print("Time: %.2f, Wave: %.2f" % [time,wave])
	#Formato do print para conferir o tempo da Wave
	spawn_rate *= wave_factor
	
	# Aplicar dificuldade
	mob_spawner.mobs_per_minute = spawn_rate


# Initial Spaw Rate é o valor inicial que vai começar a spawnar os mobs
# Spawn Rate Per Minute é o valor da onda maxima que vai chegar
# Spawn Rate Per Minute sempre vai ser somado com o valor initial spaw rate
# ou seja se initial spaw rate for 20 e vc colocar Spawn rate per minute 20
# o Spawn Rate per minute vai ser 40
# Wave diration é o tempo da duração da onda
# quanto maior o tempo da onda maior o tempo de initial spaw e Spawn rate per minute
# Break Intensity é o tamanho da onda o maximo é 1
# e com o Break intensity podendo configurar ate -1
