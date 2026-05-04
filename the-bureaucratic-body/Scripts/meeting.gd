extends Control

@onready var replay_button: Button = $Button
var _meeting_dialogue: Resource = null

func _ready() -> void:
	replay_button.pressed.connect(_on_replay_button_pressed)
	replay_button.visible = false

	_meeting_dialogue = load("res://dialogue/burbody_dialogue/scene6_meeting.dialogue")
	call_deferred("_init_dialogue")

func _on_replay_button_pressed() -> void:
	var GS = get_node("/root/GameState")
	GS.reset()
	get_tree().change_scene_to_file("res://Scenes/wake_up.tscn")

func _on_dialogue_ended(resource: Resource) -> void:
	if resource == _meeting_dialogue:
		replay_button.visible = true

func _init_dialogue() -> void:
	var dm = Engine.get_singleton("DialogueManager")
	if not dm:
		await get_tree().process_frame
		dm = Engine.get_singleton("DialogueManager")

	if dm:
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)
		dm.show_dialogue_balloon(_meeting_dialogue, "meeting_start")
	else:
		# If DialogueManager still isn't available, show the button so the scene is playable
		replay_button.visible = true
