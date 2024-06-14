extends Node

@export var speed: float = 1

var enemy: Enemy
var sprite: AnimatedSprite2D


func _ready():
	enemy = get_parent() 
	sprite = enemy.get_node("AnimatedSprite2D")
	pass


func _physics_process(delta: float) -> void:
	# Ignorar GameOver
	if GameManager.is_game_over: return
	
	# CALCULO DE VETORES
	# Notificando Inimigo Posição GameManager
	var player_position = GameManager.player_position
	# Posição Atual - Position
	var difference = player_position - enemy.position
	# Movimentação Personagem = a subtração da posição atual - position
	var input_vector = difference.normalized() # Normalized para o player começar a navegaçao do input atual
	# Velocidade do personagem
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()


	# Girar Sprite
	if input_vector.x > 0:
		sprite.flip_h = false
		
	#Desmarcar o Flip H do Sprite 2D
	elif input_vector.x < 0:#se andar com o personagem com a esquerda o flip vai esta ativado
	#Marcar o Flip H do Sprite 2D
		sprite.flip_h = true
	
