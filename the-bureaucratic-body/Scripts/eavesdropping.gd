extends Control

@onready var start_presentation_button: Button = $Button

func _ready() -> void:
	start_presentation_button.pressed.connect(_on_start_presentation_button_pressed)

func _on_start_presentation_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/presentation.tscn")
