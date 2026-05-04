extends Control

@onready var legacy_start_button: Button = $Button
@onready var eavesdrop_button: Button = $eavesdrop
@onready var bubble_one_button: TextureButton = $bubble_one
@onready var bubble_two_button: TextureButton = $bubble_two
var _eavesdrop_dialogue: Resource = null
var bubble_index: int = 0
var outfit_key: String = ""
var setup_finished: bool = false
var bubble_one_clicked: bool = false
var bubble_two_clicked: bool = false
var dialogue_unlocked: bool = false

func _ready() -> void:
	legacy_start_button.visible = false
	eavesdrop_button.visible = false
	bubble_one_button.pressed.connect(_on_bubble_one_pressed)
	bubble_two_button.pressed.connect(_on_bubble_two_pressed)
	eavesdrop_button.pressed.connect(_on_eavesdrop_button_pressed)

	outfit_key = GameState.outfit # e.g. "fem_formal"
	_eavesdrop_dialogue = load("res://dialogue/burbody_dialogue/scene4_eavesdrop.dialogue")
	call_deferred("_init_dialogue")

func _on_dialogue_ended(resource: Resource) -> void:
	if resource == _eavesdrop_dialogue:
		setup_finished = true
		_update_eavesdrop_button()

func _update_eavesdrop_button() -> void:
	eavesdrop_button.visible = setup_finished and bubble_one_clicked and bubble_two_clicked and not dialogue_unlocked

func _on_bubble_one_pressed() -> void:
	if dialogue_unlocked:
		await _on_bubble_pressed()
		return

	bubble_one_clicked = true
	_update_eavesdrop_button()

func _on_bubble_two_pressed() -> void:
	if dialogue_unlocked:
		await _on_bubble_pressed()
		return

	bubble_two_clicked = true

	_update_eavesdrop_button()

func _on_eavesdrop_button_pressed() -> void:
	if not setup_finished or not bubble_one_clicked or not bubble_two_clicked or dialogue_unlocked:
		return

	dialogue_unlocked = true
	eavesdrop_button.visible = false
	await _on_bubble_pressed()

func _init_dialogue() -> void:
	var dm = Engine.get_singleton("DialogueManager")
	if not dm:
		await get_tree().process_frame
		dm = Engine.get_singleton("DialogueManager")

	if dm:
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)
		# Show setup narration first
		await dm.show_dialogue_balloon(
			_eavesdrop_dialogue,
			outfit_key + "_setup"
		)
		setup_finished = true
		_update_eavesdrop_button()
	else:
		# If DialogueManager still isn't available, show the button so the scene is playable
		setup_finished = true
		_update_eavesdrop_button()

func _on_bubble_pressed() -> void:
	bubble_index += 1
	var title = outfit_key + "_bubble" + str(bubble_index)
	
	# Bubble counts per outfit:
	var max_bubbles = {"masc_formal": 4, "masc_casual": 3, "fem_formal": 4, "fem_casual": 4}
	
	var dm = Engine.get_singleton("DialogueManager")
	if dm:
		if bubble_index <= max_bubbles.get(outfit_key, 0):
			await dm.show_dialogue_balloon(
				_eavesdrop_dialogue, title
			)
		else:
			await dm.show_dialogue_balloon(
				_eavesdrop_dialogue,
				outfit_key + "_reflection"
			)
			# Transition to Scene 5
			get_tree().change_scene_to_file("res://Scenes/presentation.tscn")
