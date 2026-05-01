extends Control

@onready var start_button: Button = $Button

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
	var fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.color.a = 0.0
	fade_overlay.anchor_right = 1.0
	fade_overlay.anchor_bottom = 1.0
	add_child(fade_overlay)
	move_child(fade_overlay, get_child_count() - 1)
	
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 1.0)
	await tween.finished
	
	get_tree().change_scene_to_file("res://Scenes/wake_up.tscn")
