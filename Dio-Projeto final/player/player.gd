class_name Player
extends CharacterBody2D
@export_category("Movement")
@export var speed: float = 3
@export_range(0, 1) var lerp_factor = 0.5

@export_category("Sword")
@export var sword_damage: int = 2

@export_category("Ritual")
@export var ritual_damage: float = 10
@export var ritual_interval: float = 15
@export var ritual_scene: PackedScene

@export_category("Life")
@export var health: int = 100
@export var health_max: int = 100
@export var death_prefab: PackedScene # animação de morte da scene skull

@export_category("Mana")
@export var mana: int = 30
@export var max_mana: int = 150
@export var ritual_cost: int = 15
@export var mana_regeneration_rate: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var progress_bars: Node = $Upadate_Bars
@onready var damage_digit_marker = $DamageDigitMarker
var damage_digit_prefab: PackedScene

var is_running: bool = false
var is_attacking: bool = false
var attack_colldown: float = 0.0
var is_attacking_up: bool = false
var input_vector: Vector2 = Vector2(0, 0)
var was_running: bool = false
var hitbox_colldown: float = 0.0
var ritual_cooldown: float = 0.0
var mana_regeneration_timer: float = 0.0
var mana_regeneration_active: bool = false

signal meat_collected(value:int)


func _ready():
	GameManager.player = self
	# função anonima que auto popula o GameManager direto do player
	# Inicializa o texto do meat_label com o valor do meat_counter
	meat_collected.connect(func(value: int):
		GameManager.meat_counter += 1) 
	# Dano que o Player sofre
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")
	

func _process(delta:float) -> void:
	

	# Notificando GameManager Posição do Player
	GameManager.player_position = position
	
	
	#Processar Ataque/ Ler input
	update_attack_cooldown(delta)
	
	read_input()
	
	if Input.is_action_just_pressed("attack"): # input de attack de lado
		attack()
	if Input.is_action_just_pressed("attack_up") && input_vector.y < 0:# input attack de cima  aqui o attack_up esta precionado a tecla quadrado do controle ps4, e o input_vector <0 diz que se vector y for menor do que zero a animação do attack_up vai rodar nesse caso é se o personagem andar para cima e apertar o quadrado do controle ele ataca para cima
		attack_up()
	
	# Processar Rotação e Animação
	cooldwn_mana(delta)
	rotate_sprite()
	update_hitbox_detection(delta)
	update_ritual(delta)
	update_progress_bars()
	if Input.is_action_just_pressed("active_ritual"):
		activate_ritual()
	play_idle_run_animation()
	if not is_attacking:
		if not is_attacking_up:
			pass
	

	
	
			

	
	
	# Atualizar cooldown do Ritual
func update_ritual(delta: float) -> void:
	if ritual_cooldown > 0: 
		ritual_cooldown -= delta	
		print("Ritual", ritual_cooldown)
	
	
	# Ativação Do Ritual
func activate_ritual() -> void:
	if ritual_cooldown > 0 or mana < ritual_cost: 
		return
	ritual_cooldown = ritual_interval
	
	mana -= ritual_cost
	print("Mana", mana)
	mana_regeneration_active = true

	
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)

 #Atualizar a regeneração de Mana com base no tempo
func cooldwn_mana(delta) -> void:
	mana_regeneration_timer += delta
	if mana_regeneration_timer >= 1.0:
		regenerate_mana()
		mana_regeneration_timer -= 1.0
	
	# Regenerar Mana
func regenerate_mana() -> void:
	if mana < max_mana:
		# Regenerar a mana com base na taxa de regeneração
		mana += mana_regeneration_rate
		# Certificar-se de que a mana não ultrapasse o máximo
		if mana > max_mana:
			mana = max_mana
	print("Mana regenerada:", mana)
		
		
		
	#
	
func _physics_process(delta:float) -> void:
	

	#Notificar Velocidade
	var target_velocity = input_vector * speed * 100.0 ## velocidade do vetor multiplicada por 100
	if is_attacking: # velocidade de esta atacando multiplicada por 0.25
		target_velocity *= 0.25 ##neste caso a velocidade de atacando é menor do que a velocidade geral do personagem
	
	if is_attacking_up:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, lerp_factor) ## lerp é para o personagem nao parar com tudo, ter uma parada mais agradavel
	move_and_slide() # para funcionar o codigo
		
		## Attack
	
		
		#Confirmando animação

func attack() -> void:
	if is_attacking: # se estiver atacando 
		return # animação vai retornar sempre que apertar a tecla quadrado do controle ps4
		##attack_side_1
	animation_player.play("attack_side_1") # chamando animação de ataque
	
	## Marcar attack
	is_attacking = true # se input attack_up for pressionada is_attacking é verdadeiro, se parar o ataque se torna falso de novo
	attack_colldown = 0.5 # tempo para rodar cada animação do ataque isso ajuda muito para nao cortar metade da aniumação
	
	
	
func attack_up() -> void:
	
	if is_attacking_up:
		return
	animation_player.play("attack_up_1")
	is_attacking = true
	
	attack_colldown = 0.5
	# Defina um temporizador para redefinir is_attacking após o término da animação
		#$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
	
func read_input() -> void:
	#Obter Input_Vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#Apagar deadzone do input vector
	var dead_zone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
	
func rotate_sprite() -> void:
	# Girar Sprite
	if input_vector.x > 0: # se andar com o personagem com a difreita o flip vai esta desativado
		sprite.flip_h = false
		
	#Desmarcar o Flip H do Sprite 2D
	elif input_vector.x < 0:#se andar com o personagem com a esquerda o flip vai esta ativado
	#Marcar o Flip H do Sprite 2D
		sprite.flip_h = true
		
func play_idle_run_animation() -> void:
	#Tocar Animação
	was_running = is_running # variavel que determina que esta parado é igual esta correndo
	is_running = not input_vector.is_zero_approx() # is_zero_approx é para checar se p input_vector esta em 0
	## se estiver correndo o vetor nao pode esta em zero e se estiver em zero a opção else funciona e roda a animação de idle
	if not is_attacking: # se nao estiver atacando
		if was_running != is_running: # esta parado é diferente de esta correndo
			# ou seja se nao estiver atacando vai esta correndo ou parado e parado é diferente de esta correndo
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("Idle")
		
func update_attack_cooldown(delta: float) -> void:
	
	## Atualizar Temporazidador do ataque verificação da animação do attack, 
	if is_attacking: ## se atacar 
		attack_colldown -= delta ## o tempo coldown delta vai diminuir
		if attack_colldown <= 0.0: ## tempo coldown nao pode ser menor do que zero para pode executar outra animação
			is_attacking = false ## animação de atacar é falsa ate precionar o botao
			is_running = false ## animação de correr é falsa ate precionar botao
			animation_player.play("Idle") ## animação de parado vai rodar se nenhuma tecla de correr ou atacar for precionada
	
	##  Atualizar Temporazidador do ataque atacando para cima
	if is_attacking_up:
		attack_colldown -= delta
		if attack_colldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("Idle")
# Causou Dano
func deal_damage_to_enemies() -> void: # função para causa dano aos enimigos
	# variavel para checar corpo criado SwordArea (Area2D)
	# Checar Lista do Grupo enemies
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body. is_in_group("pawn"):
			var enemy: Enemy = body
	#__________________________________________________
			# CALCULAR A DIREÇÃO DO ENEMY PARA O PERSONAGEM
			var direction_to_enemy = (enemy.position - position).normalized()
			
			
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			if is_attacking_up:
				attack_direction = Vector2.UP
			
			var dot_product = direction_to_enemy.dot(attack_direction)
			var damage_pawn: int = 5
			if dot_product >= 0.02:
				print("Dot", dot_product)
				enemy.damage(damage_pawn)
		
		if body. is_in_group("goblin_enemies"):
			var enemy: Enemy = body
	#__________________________________________________
			# CALCULAR A DIREÇÃO DO ENEMY PARA O PERSONAGEM
			var direction_to_enemy = (enemy.position - position).normalized()
			
			
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			if is_attacking_up:
				attack_direction = Vector2.UP
			
			var amount: int = 3
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.02:
				print("Dot", dot_product)
				enemy.damage(amount)
				
		if body. is_in_group("ovelha"):
			var enemy: Enemy = body
	#__________________________________________________
			# CALCULAR A DIREÇÃO DO ENEMY PARA O PERSONAGEM
			var direction_to_enemy = (enemy.position - position).normalized()
			
			
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			if is_attacking_up:
				attack_direction = Vector2.UP
			
			var damage_ovelha: int = 10
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.02:
				print("Dot", dot_product)
				enemy.damage(damage_ovelha)
				
func update_hitbox_detection(delta: float) -> void:
	# a cada frame em que o hitboxArea estiver dentro do inimigo
	# o hitbox_colldown vai ser subtraido por delta -0.16 por segundo
	# se o inimigo se afastar do player o hitbox_colldown volta para 0
	# a função return corta a parte do codigo var bodies detectar inimigos
	# ate damage(damage_amount)
	# Temporizador
	hitbox_colldown -= delta 
	if hitbox_colldown > 0: return 
	
	# Frequencia
	hitbox_colldown = 0.5
	
	# Detectar Inimigos e Receber Dano dos enimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)
		if body.is_in_group("goblin_enemies"):
			var enemy: Enemy = body
			var damage_amount = 5
			damage(damage_amount)
			
	pass
# Recebeu Dano
func damage(amount: int) -> void:
	if health <= 0: return
	health -= amount
	print("Player recebeu dano", amount, ". A vida total é de ", health, )
	
	#PISCAR NODE
	modulate = Color.RED # MODULO DE COR
	var tween = create_tween() # CRIAR TWEEN DE COR
	tween.set_ease(Tween.EASE_IN) # CRIAR PROPRIEDADES DO TWENN
	tween.set_trans(Tween.TRANS_QUINT) # TIPO DE TWENN PODE CONFERIR NO SITE https://easings.net/
	tween.tween_property(self, "modulate", Color.WHITE, 0.3) # CONFIGURAR CORES DE TRANSIÇÃO
						# EU,  "MODULO",  COR FINAL, TEMPO DE TRANSIÇÃO
						# COLOR.WHITE VOLTA PARA COR ORIGINAL
						
	 # Instanciando posição do prefab damage_digite da scene damage_digit_marker
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
		# Adicionar damage_digitMarket na cena
	get_parent().add_child(damage_digit)
	
	# PROCESSAR MORTE
	if health <= 0:
		die()
		
func die() -> void:
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
		queue_free()
		
		
func heal(amount: int) -> int:
	health += amount
	if health > health_max:
		health = health_max
	print("Player recebeu cura de", amount, ". A vida total é de", health, "/", health_max)
	return health
	
	#Atualizar Bars do Script progress_bars
func update_progress_bars():
	if progress_bars != null:
		progress_bars.update_bars(health_max, health, max_mana, mana)
			
