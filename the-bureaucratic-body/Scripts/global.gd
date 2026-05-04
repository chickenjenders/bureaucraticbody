extends Node

const BORING_MUSIC: AudioStream = preload("res://assets/boring.ogg")

var professionalism = 50
var anxiety = 50
var agency = 10
var current_outfit = "none" # Tracks the "Morning Ritual" choice [cite: 29]

var _music_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.stream = BORING_MUSIC
	_music_player.finished.connect(_on_music_finished)
	add_child(_music_player)
	_music_player.play()

func _on_music_finished() -> void:
	_music_player.play()