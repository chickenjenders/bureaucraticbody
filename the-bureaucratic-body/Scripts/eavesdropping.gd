extends Control

@onready var legacy_start_button: Button = $Button
@onready var eavesdrop_button: Button = $eavesdrop
@onready var bubble_one_button: TextureButton = $bubble_one
@onready var bubble_two_button: TextureButton = $bubble_two

var _eavesdrop_dialogue: Resource = null
var bubble_index: int = 0
var outfit_key: String = ""
var setup_finished: bool = false
var sequence_complete: bool = false
var max_bubbles: Dictionary = {
	"masc_formal": 4,
	"masc_casual": 3,
	"fem_formal": 4,
	"fem_casual": 4,
}

func _get_valid_outfit_key() -> String:
	var GS = get_node("/root/GameState")
	var key := String(GS.outfit)
	if key == "" or not max_bubbles.has(key):
		# Fallback prevents dialogue key assertions when outfit was not set.
		return "masc_formal"
	return key

func _ready() -> void:
	legacy_start_button.visible = false
	legacy_start_button.pressed.connect(_on_start_button_pressed)

	# Kept for scene compatibility, but no longer used for progression.
	eavesdrop_button.visible = false
	eavesdrop_button.pressed.connect(_on_eavesdrop_button_pressed)

	bubble_one_button.pressed.connect(_on_bubble_pressed)
	bubble_two_button.pressed.connect(_on_bubble_pressed)

	outfit_key = _get_valid_outfit_key()
	_eavesdrop_dialogue = load("res://dialogue/burbody_dialogue/scene4_eavesdrop.dialogue")
	call_deferred("_init_dialogue")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/presentation.tscn")

func _on_eavesdrop_button_pressed() -> void:
	# Intentionally unused in current flow.
	pass

func _show_start_button() -> void:
	print("[eavesdropping] _show_start_button called; sequence_complete=", sequence_complete, " bubble_index=", bubble_index)
	legacy_start_button.visible = true
	legacy_start_button.show()
	legacy_start_button.disabled = false
	legacy_start_button.z_index = 100
	legacy_start_button.move_to_front()
	legacy_start_button.focus_mode = Control.FOCUS_ALL
	eavesdrop_button.visible = false
	bubble_one_button.disabled = true
	bubble_two_button.disabled = true

func _init_dialogue() -> void:
	var dm = Engine.get_singleton("DialogueManager")
	if not dm:
		await get_tree().process_frame
		dm = Engine.get_singleton("DialogueManager")

	if dm:
		# Connect once so we can react when this dialogue resource ends
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)
		dm.show_dialogue_balloon(_eavesdrop_dialogue, outfit_key + "_setup")

	# Do not block bubble input on signal timing.
	setup_finished = true

func _on_dialogue_ended(resource: Resource) -> void:
	print("[eavesdropping] _on_dialogue_ended resource=", resource, " bubble_index=", bubble_index, " sequence_complete=", sequence_complete)
	# If the dialogue resource ends, show the start button if the sequence is marked complete.
	if resource != _eavesdrop_dialogue:
		return

	# If sequence is complete, show the button and disable bubbles
	if sequence_complete:
		print("[eavesdropping] sequence complete; showing start button")
		_show_start_button()
		return

	var max_count: int = int(max_bubbles.get(outfit_key, 0))
	if max_count <= 0:
		sequence_complete = true
		_show_start_button()
		return

	# Otherwise re-enable bubbles for next click (shouldn't happen now since we mark complete on first click)
	bubble_one_button.disabled = false
	bubble_two_button.disabled = false
	print("[eavesdropping] re-enabled bubble buttons; bubble_index=", bubble_index)

func _on_bubble_pressed() -> void:
	print("[eavesdropping] _on_bubble_pressed called; setup_finished=", setup_finished, " sequence_complete=", sequence_complete, " bubble_index=", bubble_index)
	if not setup_finished or sequence_complete:
		return

	var dm = Engine.get_singleton("DialogueManager")
	var max_count: int = int(max_bubbles.get(outfit_key, 0))
	print("[eavesdropping] outfit_key=", outfit_key, " max_count=", max_count)
	if max_count <= 0:
		sequence_complete = true
		_show_start_button()
		return

	if bubble_index < max_count:
		bubble_index += 1
		var title := outfit_key + "_bubble" + str(bubble_index)
		# Mark sequence as complete on first click—no need to loop through multiple bubbles
		sequence_complete = true
		if dm:
			dm.show_dialogue_balloon(_eavesdrop_dialogue, title)
			# Prevent restarting the same balloon while it's active
			bubble_one_button.disabled = true
			bubble_two_button.disabled = true
			print("[eavesdropping] showed balloon ", title, "; marked sequence complete")
		return
