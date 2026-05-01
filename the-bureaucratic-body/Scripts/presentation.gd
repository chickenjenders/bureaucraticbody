extends Control

@onready var end_presentation_button: Button = $Button

func _ready() -> void:
	end_presentation_button.pressed.connect(_on_end_presentation_button_pressed)

func _on_end_presentation_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/meeting.tscn")
