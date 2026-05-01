extends Control

@onready var choose_outfit_button: Button = $Button

func _ready() -> void:
	choose_outfit_button.pressed.connect(_on_choose_outfit_button_pressed)

func _on_choose_outfit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/closet.tscn")
