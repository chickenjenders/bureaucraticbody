extends Control

@onready var choose_outfit_button: Button = $Button
var _pick_outfit_dialogue: Resource = null

func _ready() -> void:
	choose_outfit_button.pressed.connect(_on_choose_outfit_button_pressed)
	choose_outfit_button.visible = false

	_pick_outfit_dialogue = load("res://dialogue/wake_up.dialogue")
	call_deferred("_init_dialogue")

func _on_choose_outfit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/closet.tscn")


func _on_dialogue_ended(resource: Resource) -> void:
	if resource == _pick_outfit_dialogue:
		choose_outfit_button.visible = true


func _init_dialogue() -> void:
	var dm = Engine.get_singleton("DialogueManager")
	if not dm:
		await get_tree().process_frame
		dm = Engine.get_singleton("DialogueManager")

	if dm:
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)
		dm.show_dialogue_balloon(_pick_outfit_dialogue, "pick_outfit")
	else:
		# If DialogueManager still isn't available, show the button so the scene is playable
		choose_outfit_button.visible = true
