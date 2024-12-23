extends Node2D  # Alterar para Control se estiver gerenciando múltiplos elementos de UI

const MAX_HEALTH = 5
var health = MAX_HEALTH

func _ready() -> void:
	update_health_ui()
	$ProgressBar.max_value = MAX_HEALTH

func update_health_ui():
	set_health_label()
	set_health_bar()

func set_health_label() -> void:
	$HealthLabel.text = "Health: %s" % health

func set_health_bar() -> void:
	$ProgressBar.value = health

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		damage()

func damage() -> void:
	health -= 1
	if health < 0:
		health = MAX_HEALTH
	update_health_ui()
