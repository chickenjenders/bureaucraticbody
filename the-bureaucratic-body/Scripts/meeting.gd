extends Control

@onready var replay_button: Button = $Button

func _ready() -> void:
	replay_button.pressed.connect(_on_replay_button_pressed)

func _on_replay_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/wake_up.tscn")
