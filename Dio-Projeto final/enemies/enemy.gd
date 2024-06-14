class_name Enemy
extends Node2D
@export_category("life")
@export var health: int = 10
@export var death_prefab: PackedScene # animação de morte da scene skull

@onready var damage_digit_marker = $DamageDigitMarker
var damage_digit_prefab: PackedScene

@export_category("Drops")
@export var drop_chance: float = 0.1
@export var drop_items: Array[PackedScene]
@export var drop_chances: Array[float]

func _ready():
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")

func damage(amount: int) -> void:
	health -= amount
	print("inimigo recebeu dano", amount, ". A vida total é de ", health)
	
	#PISCAR NODE
	modulate = Color.RED # MODULO DE COR
	var tween = create_tween() # CRIAR TWEEN DE COR
	tween.set_ease(Tween.EASE_IN) # CRIAR PROPRIEDADES DO TWENN
	tween.set_trans(Tween.TRANS_QUINT) # TIPO DE TWENN PODE CONFERIR NO SITE https://easings.net/
	tween.tween_property(self, "modulate", Color.WHITE, 0.3) # CONFIGURAR CORES DE TRANSIÇÃO
						# EU,  "MODULO",  COR FINAL, TEMPO DE TRANSIÇÃO
						# COLOR.WHITE VOLTA PARA COR ORIGINAL
	# Criar um DamageDigit
	# sempre que for chamar uma scene, criar um var PackedScene e depois instanciar no instantiate
	
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
	#Caveira
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
	if randf() <= drop_chance:
		drop_item()
		
	# Incrementar contador
	GameManager.monsters_defeated_counter += 1
		
	queue_free()
	
	# Drop de Itens
func drop_item() -> void:
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	get_parent().add_child(drop)

func get_random_drop_item() -> PackedScene:
	# Lista com 1 item
	if drop_items.size() == 1:
		return drop_items[0]
	
	# Calcular Chance Maxima
	var max_chance: float = 0.0
	for drop_chance in drop_chances:
		max_chance += drop_chance
		
	# jogar dado
	var random_value = randf() * max_chance
	
	# Girar a roleta
	var needle: float = 0.0
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1
		if random_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance
	
	return drop_items[0]
		

