extends Control

@onready var outfit_button: Button = $Done/Button
@onready var done_label: Label = $Done
@onready var suit_m_button: TextureButton = $suitM
@onready var collared_button: TextureButton = $collared
@onready var suit_w_button: TextureButton = $suitW
@onready var dress_button: TextureButton = $dress

@onready var GS = get_node("/root/GameState")

var _closet_dialogue: Resource = null
var _awaiting_outfit_selection: bool = true

func _ready() -> void:
	# Done label is already set to invisible in the scene editor
	if outfit_button:
		outfit_button.pressed.connect(_on_go_to_work_pressed)
	
	# Connect outfit selection buttons
	if suit_m_button:
		suit_m_button.pressed.connect(_on_suit_m_pressed)
	if collared_button:
		collared_button.pressed.connect(_on_collared_pressed)
	if suit_w_button:
		suit_w_button.pressed.connect(_on_suit_w_pressed)
	if dress_button:
		dress_button.pressed.connect(_on_dress_pressed)
	
	_closet_dialogue = load("res://dialogue/burbody_dialogue/scene3_closet.dialogue")
	
	var dm = Engine.get_singleton("DialogueManager")
	if dm:
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)
		dm.show_dialogue_balloon(_closet_dialogue, "closet_start")

func _on_suit_m_pressed() -> void:
	if _awaiting_outfit_selection:
		_awaiting_outfit_selection = false
		GS.set_outfit("masc_formal")
		_show_outfit_dialogue("masc_formal_confirm")

func _on_collared_pressed() -> void:
	if _awaiting_outfit_selection:
		_awaiting_outfit_selection = false
		GS.set_outfit("masc_casual")
		_show_outfit_dialogue("masc_casual_confirm")

func _on_suit_w_pressed() -> void:
	if _awaiting_outfit_selection:
		_awaiting_outfit_selection = false
		GS.set_outfit("fem_formal")
		_show_outfit_dialogue("fem_formal_confirm")

func _on_dress_pressed() -> void:
	if _awaiting_outfit_selection:
		_awaiting_outfit_selection = false
		GS.set_outfit("fem_casual")
		_show_outfit_dialogue("fem_casual_confirm")

func _show_outfit_dialogue(dialogue_node: String) -> void:
	# Hide all outfit buttons except the selected one
	if suit_m_button:
		suit_m_button.visible = (dialogue_node == "masc_formal_confirm")
	if collared_button:
		collared_button.visible = (dialogue_node == "masc_casual_confirm")
	if suit_w_button:
		suit_w_button.visible = (dialogue_node == "fem_formal_confirm")
	if dress_button:
		dress_button.visible = (dialogue_node == "fem_casual_confirm")
	
	# Show confirmation dialogue
	var dm = Engine.get_singleton("DialogueManager")
	if dm:
		dm.show_dialogue_balloon(_closet_dialogue, dialogue_node)

func _on_dialogue_ended(resource: Resource) -> void:
	if resource == _closet_dialogue:
		if not _awaiting_outfit_selection:
			# Hide all outfit buttons and show the done label with GO TO WORK button
			if suit_m_button:
				suit_m_button.visible = false
			if collared_button:
				collared_button.visible = false
			if suit_w_button:
				suit_w_button.visible = false
			if dress_button:
				dress_button.visible = false
			if done_label:
				done_label.visible = true
				done_label.z_index = 100 # Bring to front

func _on_go_to_work_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/eavesdropping.tscn")
