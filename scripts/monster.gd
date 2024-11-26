extends CharacterBody2D

const SPEED = 160.0  # Velocidade do Inimigo
const CHASE_DISTANCE = 80.0  # Distância para agredir no player
const ATTACK_DISTANCE = 200.0  # Distância para atacar
const JUMP_VELOCITY = -400.0  # Velocidade do Pulo
const PATROL_DISTANCE = 5000.0  # Distância de patrulha
const DAMAGE_AMOUNT = 5  # Quantidade de dano que o inimigo causa

var direction = 1  # 1 para direita, -1 para esquerda
var start_position = Vector2.ZERO  # Posição inicial do inimigo
var patrol_target_position = Vector2.ZERO  # Posição alvo da patrulha
var is_frozen = false  # Variável para verificar se o inimigo está congelado
var is_attacking = false  # Variável para controlar o estado de ataque

@onready var camera = get_parent().get_node("Camera2D")
@onready var p1 = get_parent().get_node("Player1")
@onready var p2 = get_parent().get_node("Player2")
@onready var animation_sprite = $AnimatedSprite2D  # Referência ao AnimatedSprite2D

func _ready() -> void:
	start_position = global_position  # Salva a posição inicial no ready
	set_random_patrol_target()
	animation_sprite.play("idle")  # Começa com a animação idle

func _physics_process(delta: float) -> void:
	var target_velocity = Vector2.ZERO
	var closest_player = get_closest_player()

	if closest_player:
		target_velocity = handle_player_interaction(closest_player, delta)
	else:
		target_velocity = patrol(delta)

	# Atualiza a velocidade e move o inimigo
	velocity = target_velocity
	move_and_slide()

func get_closest_player() -> Node2D:
	# Verifica a distância para cada jogador, mas considera apenas aqueles que não estão congelados
	var distance_to_player1 = CHASE_DISTANCE + 1 if p1.is_frozen else global_position.distance_to(p1.global_position)
	var distance_to_player2 = CHASE_DISTANCE + 1 if p2.is_frozen else global_position.distance_to(p2.global_position)

	# Se o jogador 1 estiver ao alcance e mais próximo que o jogador 2, retorna o jogador 1
	if distance_to_player1 <= CHASE_DISTANCE and distance_to_player1 < distance_to_player2:
		return p1
	# Se o jogador 2 estiver ao alcance, retorna o jogador 2
	elif distance_to_player2 <= CHASE_DISTANCE:
		return p2
	# Se nenhum jogador estiver ao alcance, retorna nulo
	return null

func handle_player_interaction(player: Node2D, delta: float) -> Vector2:
	if is_frozen:
		animation_sprite.play("idle")  # Mantenha o inimigo parado
		return Vector2.ZERO  # Retorna à patrulha se o inimigo estiver congelado

	var target_velocity = chase_player(player, delta)

	if global_position.distance_to(player.global_position) <= ATTACK_DISTANCE:
		if not is_attacking:
			is_attacking = true  # Sinaliza que o inimigo está atacando
			animation_sprite.play("attack")
	else:
		is_attacking = false
		if is_player_in_front(player):
			jump()
		else:
			animation_sprite.play("run")  # Continua a animação de correr

	return target_velocity

func patrol(delta: float) -> Vector2:
	var direction_vector = (patrol_target_position - global_position).normalized()
	velocity.x = direction_vector.x * SPEED * direction

	if reached_patrol_target():
		set_random_patrol_target()
		direction *= -1  # Inverte a direção ao alcançar o alvo de patrulha

	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	if velocity.x != 0:
		animation_sprite.play("run")
	else:
		animation_sprite.play("idle")

	return velocity

func set_random_patrol_target() -> void:
	var random_offset = randf_range(-PATROL_DISTANCE, PATROL_DISTANCE)
	patrol_target_position = start_position + Vector2(random_offset, 0)

func reached_patrol_target() -> bool:
	return global_position.distance_to(patrol_target_position) < 5.0  # Distância de tolerância

func chase_player(player_node: Node2D, delta: float) -> Vector2:
	var direction_vector = (player_node.global_position - global_position).normalized()
	velocity.x = direction_vector.x * SPEED

	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	return velocity

func is_player_in_front(player_node: Node2D) -> bool:
	return (direction == 1 and player_node.global_position.x > global_position.x) or (direction == -1 and player_node.global_position.x < global_position.x)

func jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation_sprite.play("jump")  # Adicione uma animação de pulo, se disponível

func attack_player(player_node: Node2D) -> void:
	if player_node.has_method("take_damage") and is_attacking:
		player_node.take_damage(DAMAGE_AMOUNT)

func on_hit() -> void:
	animation_sprite.play("hit")

func on_death() -> void:
	animation_sprite.play("dead")
