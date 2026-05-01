extends Control

@onready var professionalism_bar: TextureProgressBar = $CanvasLayer/professionalism
@onready var anxiety_bar: TextureProgressBar = $CanvasLayer/anxiety
@onready var outfit_button: Button = $Label/Button

func _ready() -> void:
	outfit_button.pressed.connect(_on_outfit_button_pressed)

func _on_outfit_button_pressed() -> void:
	professionalism_bar.value = max(0.0, professionalism_bar.value - 1.0)
	anxiety_bar.value = max(0.0, anxiety_bar.value - 1.0)
