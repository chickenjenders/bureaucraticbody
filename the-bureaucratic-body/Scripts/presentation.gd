extends Control

@onready var end_presentation_button: Button = $Button
var _presentation_dialogue: Resource = null

func _ready() -> void:
	end_presentation_button.pressed.connect(_on_end_presentation_button_pressed)
	end_presentation_button.visible = false

	_presentation_dialogue = load("res://dialogue/burbody_dialogue/scene5_presentation.dialogue")
	call_deferred("_init_dialogue")

func _on_end_presentation_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/meeting.tscn")

func _on_dialogue_ended(resource: Resource) -> void:
	if resource == _presentation_dialogue:
		end_presentation_button.visible = true

func _init_dialogue() -> void:
	var dm = Engine.get_singleton("DialogueManager")
	if not dm:
		await get_tree().process_frame
		dm = Engine.get_singleton("DialogueManager")

	if dm:
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)
		dm.show_dialogue_balloon(_presentation_dialogue, "presentation_start")
	else:
		# If DialogueManager still isn't available, show the button so the scene is playable
		end_presentation_button.visible = true
