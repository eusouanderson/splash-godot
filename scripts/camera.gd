extends Camera2D

@onready var p1 = get_parent().get_node("Player1")
@onready var p2 = get_parent().get_node("Player2")

var zoom_min = 3.5  # Limite mínimo de zoom (aproximação)
var zoom_max = 10.0  # Limite máximo de zoom (afastamento)
var distance_min = 200.0  # Distância mínima para zoom máximo
var distance_max = 2000.0  # Distância máxima para zoom mínimo
var edge_padding = 1400.0  # Margem ao redor da tela para manter os jogadores visíveis

func _ready():
	# Para garantir que o modo de atualização da câmera esteja definido como seguir suavemente
	position_smoothing_enabled = true
	position_smoothing_speed = 15.0 

func _physics_process(_delta):
	# Centraliza a posição da câmera entre os dois jogadores
	var center_position = (p1.global_position + p2.global_position) / 2
	global_position = center_position

	# Cálculo da distância horizontal e vertical entre os jogadores
	var horizontal_distance = abs(p1.global_position.x - p2.global_position.x)
	var vertical_distance = abs(p1.global_position.y - p2.global_position.y)

	# Calcula a distância total (pode incluir uma margem de segurança)
	var total_distance = Vector2(horizontal_distance, vertical_distance).length() + edge_padding

	# Normaliza a distância para calcular o fator de zoom
	var normalized_distance = clamp((total_distance - distance_min) / (distance_max - distance_min), 0.0, 1.0)
	var zoom_factor = lerp(zoom_max, zoom_min, normalized_distance)
	zoom = Vector2(zoom_factor, zoom_factor)

	# Calcula o retângulo de visão da câmera com base no zoom atual e posição central
	var viewport_size = get_viewport_rect().size / zoom_factor
	var viewport_rect = Rect2(global_position - viewport_size / 2, viewport_size)

	# Ajuste dinâmico para garantir que ambos os jogadores estejam visíveis na tela
	if not viewport_rect.has_point(p1.global_position) or not viewport_rect.has_point(p2.global_position):
		var highest_y = max(p1.global_position.y, p2.global_position.y)
		var lowest_y = min(p1.global_position.y, p2.global_position.y)

		# Ajuste vertical para centralizar entre o jogador mais alto e o mais baixo
		var vertical_center = (highest_y + lowest_y) / 2
		global_position.y = vertical_center

		# Ajuste horizontal se necessário
		var horizontal_center = (p1.global_position.x + p2.global_position.x) / 2
		global_position.x = horizontal_center

	# Debugging
	#print("Player1 Position: ", p1.global_position)
	#print("Player2 Position: ", p2.global_position)
	#print("Camera Position: ", global_position)
	#print("Distance: ", total_distance)
	#print("Zoom Factor: ", zoom_factor)
