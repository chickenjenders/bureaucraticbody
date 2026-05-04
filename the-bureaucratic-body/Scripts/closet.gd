extends Control

@onready var professionalism_bar: TextureProgressBar = $CanvasLayer/professionalism
@onready var anxiety_bar: TextureProgressBar = $CanvasLayer/anxiety
@onready var outfit_button: Button = $Label/Button
var _closet_dialogue: Resource = null

func _ready() -> void:
	outfit_button.pressed.connect(_on_outfit_button_pressed)
	outfit_button.visible = false

	_closet_dialogue = load("res://dialogue/burbody_dialogue/scene3_closet.dialogue")
	call_deferred("_init_dialogue")

func _on_outfit_button_pressed() -> void:
	professionalism_bar.value = max(0.0, professionalism_bar.value - 1.0)
	anxiety_bar.value = max(0.0, anxiety_bar.value - 1.0)
	get_tree().change_scene_to_file("res://Scenes/eavesdropping.tscn")

func _on_dialogue_ended(resource: Resource) -> void:
	if resource == _closet_dialogue:
		outfit_button.visible = true

func _init_dialogue() -> void:
	var dm = Engine.get_singleton("DialogueManager")
	if not dm:
		await get_tree().process_frame
		dm = Engine.get_singleton("DialogueManager")

	if dm:
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)
		dm.show_dialogue_balloon(_closet_dialogue, "closet_start")
	else:
		# If DialogueManager still isn't available, show the button so the scene is playable
		outfit_button.visible = true
