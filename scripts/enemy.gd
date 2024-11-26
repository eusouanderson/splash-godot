extends CharacterBody2D

const SPEED = 160.0  # Velocidade do Inimigo
const CHASE_DISTANCE = 5.0  # Distância para agredir no player
const ATTACK_DISTANCE = 200.0  # Distância para atacar
const JUMP_VELOCITY = -400.0  # Velocidade do Pulo
const PATROL_DISTANCE = 500.0  # Distância de patrulha
const DAMAGE_AMOUNT = 5 # Quantidade de dano que o inimigo causa

var direction = 1  # 1 para direita, -1 para esquerda
var start_position = Vector2.ZERO  # Posição inicial do inimigo
var patrol_target_position = Vector2.ZERO  # Posição alvo da patrulha
var is_frozen = false  # Variável para verificar se o inimigo está congelado

@onready var camera = get_parent().get_node("Camera2D")
@onready var p1 = get_parent().get_node("Player1")
@onready var p2 = get_parent().get_node("Player2")
@onready var enemies = get_parent().get_children()  # Lista de todos os inimigos

func _ready() -> void:
	# Define uma posição de patrulha inicial aleatória
	set_random_patrol_target()

func _physics_process(delta: float) -> void:
	var target_velocity = Vector2.ZERO
	var distance_to_player1 = global_position.distance_to(p1.global_position)
	var distance_to_player2 = global_position.distance_to(p2.global_position)

	var closest_player = null
	var closest_distance = INF

	# Determina qual jogador está mais próximo
	if distance_to_player1 <= CHASE_DISTANCE and distance_to_player1 < distance_to_player2:
		closest_player = p1
		closest_distance = distance_to_player1
	elif distance_to_player2 <= CHASE_DISTANCE:
		closest_player = p2
		closest_distance = distance_to_player2

	if closest_player and closest_distance <= CHASE_DISTANCE:
		# Ignora o jogador se ele estiver congelado
		if closest_player.is_frozen:
			# Se o jogador mais próximo estiver congelado, escolha o outro jogador
			closest_player = p2 if closest_player == p1 else p1
			closest_distance = global_position.distance_to(closest_player.global_position)

		# Verifica se o jogador escolhido está congelado
		if not closest_player.is_frozen:
			target_velocity = chase_player(closest_player, delta)
			if closest_distance <= ATTACK_DISTANCE:
				attack_player(closest_player)  # Chama a função de ataque
		else:
			# Se o jogador escolhido estiver congelado, continue a patrulha
			target_velocity = patrol(delta)
			# Verifique se o jogador congelado está à frente do inimigo
			if is_player_in_front(closest_player):
				jump()  # Realiza um pulo se o jogador estiver à frente
	else:
		target_velocity = patrol(delta)

	# Verifique se há outros inimigos à frente e pule se necessário
	if is_other_enemy_in_front():
		jump()  # Realiza um pulo se outro inimigo estiver à frente

	velocity = target_velocity
	move_and_slide()

# Função para definir uma nova posição de patrulha aleatória
func set_random_patrol_target() -> void:
	var random_offset = randf_range(-PATROL_DISTANCE, PATROL_DISTANCE)
	patrol_target_position = start_position + Vector2(random_offset, 0)

# Função para verificar se o inimigo chegou à posição alvo da patrulha
func reached_patrol_target() -> bool:
	return global_position.distance_to(patrol_target_position) < 5.0  # Distância de tolerância

# Função para fazer o inimigo patrulhar
func patrol(delta: float) -> Vector2:
	# Move o inimigo em direção à posição de patrulha alvo
	var direction_vector = (patrol_target_position - global_position).normalized()
	velocity.x = direction_vector.x * SPEED

	# Verifica se atingiu a posição de patrulha
	if reached_patrol_target():
		set_random_patrol_target()  # Define uma nova posição de patrulha aleatória

	# Aplicar gravidade se não estiver no chão
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	return velocity

# Função para verificar se o jogador está à frente do inimigo
func is_player_in_front(player_node: Node2D) -> bool:
	# Verifica a direção do inimigo
	if direction == 1:  # Direita
		return player_node.global_position.x > global_position.x
	else:  # Esquerda
		return player_node.global_position.x < global_position.x

# Função para verificar se há outros inimigos à frente
func is_other_enemy_in_front() -> bool:
	for enemy in enemies:
		if enemy != self and enemy.is_inside_tree():  # Ignora o próprio inimigo
			if global_position.distance_to(enemy.global_position) < 30:  # Distância que você considera como "frente"
				if is_player_in_front(enemy):
					#print("Another enemy is in front!")  # Debug: informar que outro inimigo está à frente
					return true
	return false

# Função para fazer o inimigo pular
func jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY  # Aplica a velocidade de pulo
		#print("Jumping over obstacle.")  # Debug: informar que está pulando

# Função para fazer o inimigo perseguir o jogador
func chase_player(player_node: Node2D, delta: float) -> Vector2:
	var direction = (player_node.global_position - global_position).normalized()
	velocity.x = direction.x * SPEED

	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	return velocity

# Função para atacar o jogador
func attack_player(player_node: Node2D) -> void:
	if player_node.has_method("take_damage"):
		player_node.take_damage(DAMAGE_AMOUNT)  # Aplica dano ao jogador
