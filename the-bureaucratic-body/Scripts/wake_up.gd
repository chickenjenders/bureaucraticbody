extends Control

@onready var start_button: Button = $Button
var _wake_dialogue: Resource = null

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	start_button.visible = false

	_wake_dialogue = load("res://dialogue/burbody_dialogue/scene1_wakeup.dialogue")
	call_deferred("_init_dialogue")


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/pick_outfit.tscn")


func _on_dialogue_ended(resource: Resource) -> void:
	if resource == _wake_dialogue:
		start_button.visible = true


func _init_dialogue() -> void:
	var dm = Engine.get_singleton("DialogueManager")
	if not dm:
		await get_tree().process_frame
		dm = Engine.get_singleton("DialogueManager")

	if dm:
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)
		dm.show_dialogue_balloon(_wake_dialogue)
	else:
		# If DialogueManager still isn't available, show the button so the scene is playable
		start_button.visible = true
