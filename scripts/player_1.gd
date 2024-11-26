extends CharacterBody2D

# Constantes
const SPEED = 450.0
const JUMP_VELOCITY = -1000.0
const MAX_HEALTH = 1000.0

# Variáveis
var health = MAX_HEALTH
var is_frozen = false  # Variável para verificar se o personagem está congelado
@onready var sound_hurt = $sound_hurt
@onready var sound_jump = $sound_jump
@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar

func _ready() -> void:
	update_health_bar()

func _physics_process(delta: float) -> void:
	# Verifica se o botão do controle para curar foi pressionado
	if Input.is_action_just_pressed("heal_action"):
		heal(20)  # Restaura 20 pontos de vida
		is_frozen = false
		
	# Se o personagem estiver congelado, desabilita a colisão
	if is_frozen:
		# Desabilita a colisão
		set_collision_layer(0)
		set_collision_mask(0)
		return
	else:
		# Restaura a colisão se não estiver congelado
		set_collision_layer(1)
		set_collision_mask(1)

	# Adicionar gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y < 0:
			animated_sprite.play("jump")  # Animação de pulo
		else:
			animated_sprite.play("fall")  # Animação de queda
	else:
		# Manipular pulo
		if Input.is_action_just_pressed("ui_accept"):
			sound_jump.play()
			velocity.y = JUMP_VELOCITY
			animated_sprite.play("jump")
	
		
	# Obter a direção de entrada e manipular o movimento/desaceleração
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		animated_sprite.play("run")
		animated_sprite.flip_h = direction < 0  # Virar sprite para a esquerda/direita
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			animated_sprite.play("idle")

	# Mover o personagem
	move_and_slide()

func take_damage(amount: float) -> void:
	sound_hurt.play()
	animated_sprite.play("hit")
	# Reduz a saúde e atualiza a barra
	health -= amount
	if health < 0:
		health = 0  # Garante que a saúde não fique negativa
	update_health_bar()
	
	if health == 0:
		handle_death()  # Lida com a morte se a saúde for zero

func handle_death() -> void:
	animated_sprite.stop()  # Para a animação atual
	animated_sprite.play("dead")  # Troca para a animação de morte, se houver
	is_frozen = true  # Congela o personagem, desabilitando a movimentação
	# Aqui você pode adicionar mais lógica, como tocar um som de morte ou mudar a cor do personagem

func update_health_bar() -> void:
	# Atualiza a barra de saúde
	health_bar.value = health / MAX_HEALTH * health_bar.max_value

func heal(amount: float) -> void:
	# Aumenta a saúde e atualiza a barra
	health += amount
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	update_health_bar()
