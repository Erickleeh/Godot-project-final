class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene]
var mobs_per_minute: float = 60.0

@onready var path_follow_2d: PathFollow2D = %Path2D/PathFollow2D
var cooldown: float = 0.0

func _process(delta: float) -> void:
	# Ignorar GameOver
	if GameManager.is_game_over: return
	
	#Temporizador (colldown)
	cooldown -= delta
	if cooldown > 0: return
	
	
	#Frequência: Monstros por Minuto
	# Neste Exemplo a cada 1 frame se cria um monstro
	var intervalo = 60.0 / mobs_per_minute
	cooldown = intervalo
	print("mobs", mobs_per_minute)
	
	# Checar se o ponto é valido
	# codigo para as creaturs nao nascer nos locais com colisao tipo o mar
	var point = get_point()
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1000 # ob1000 esta escrito em bytes
	# se lê de traz para frente nesse caso a layer 4 esta ativo
	# entao estamos dizendo que apenas a colisao da layer 4 é verdadeira
	# caso queira que a colisao funciona em todas as layer é só 
	# apagar o parameters.collison_mask e deixar só 
	# o parameters.position = point
	var result: Array = world_state.intersect_point(parameters, 1)
	if not result.is_empty(): return
	
	#______________________________________________________________
	

	
	# Instanciar uma criatura Aleatoria
	var index = randi_range(0, creatures.size() -1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = point
	get_parent().add_child(creature)
	
	
	
	pass
	# Pegar ponto aleatorio do path follow para criar criaturas
func get_point() -> Vector2:
	# setar um valor aleatorio
	path_follow_2d.progress_ratio = randf() #randf pega uma cordenada aleatoria de 0, a 1
	#setar uma posição
	return path_follow_2d.global_position
