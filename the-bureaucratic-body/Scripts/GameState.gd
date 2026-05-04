# GameState.gd
# Autoload — add this in Project > Project Settings > Autoload
# Name it exactly: GameState
# Path: res://GameState.gd
#
# The dialogue files call:
#   GameState.set_outfit("masc_formal")
#   GameState.set_interruption("passive")
#   GameState.set_qa("correct")
#   GameState.get_ending()  -> returns "praised", "mixed", or "scolded"

extends Node

signal stats_changed(professionalism: float, anxiety: float)

# ── State variables ──────────────────────────────────────────────
var outfit: String = "" # "masc_formal" | "masc_casual" | "fem_formal" | "fem_casual"
var interruption_choice: String = "" # "passive" | "confident"
var qa_choice: String = "" # "correct" | "quiet"
var professionalism: float = 50.0
var anxiety: float = 50.0
var running_score: int = 0

# ── Setters (called as mutations from .dialogue files) ────────────
func set_outfit(value: String) -> void:
	outfit = value
	running_score += _outfit_score(value)

func set_interruption(value: String) -> void:
	interruption_choice = value
	var score_delta := _binary_choice_score(value, "confident", "passive")
	running_score += score_delta
	_apply_progress_delta(score_delta)

func set_qa(value: String) -> void:
	qa_choice = value
	var score_delta := _binary_choice_score(value, "correct", "quiet")
	running_score += score_delta
	_apply_progress_delta(score_delta)

func _ready() -> void:
	_emit_stats()

func _outfit_score(value: String) -> int:
	match value:
		"masc_formal":
			return 2
		"masc_casual":
			return 1
		"fem_formal":
			return 0
		"fem_casual":
			return -1
		_:
			return 0

func _binary_choice_score(value: String, praised_value: String, scolded_value: String) -> int:
	if value == praised_value:
		return 1
	if value == scolded_value:
		return -1
	return 0

func _apply_progress_delta(score_delta: int) -> void:
	if score_delta == 0:
		return

	# Determine if current outfit is masculine or feminine
	var is_masculine: bool = outfit == "masc_formal" or outfit == "masc_casual"
	var is_feminine: bool = outfit == "fem_formal" or outfit == "fem_casual"
	
	# Apply different bar changes based on outfit and choice
	if is_masculine:
		# Masculine choices: confident = professionalism up/anxiety down, passive = opposite
		professionalism = clamp(professionalism + float(score_delta) * 10.0, 0.0, 100.0)
		anxiety = clamp(anxiety - float(score_delta) * 10.0, 0.0, 100.0)
	elif is_feminine:
		if score_delta > 0:
			# Confident feminine choice: professionalism down, anxiety up (less so)
			professionalism = clamp(professionalism - 10.0, 0.0, 100.0)
			anxiety = clamp(anxiety + 5.0, 0.0, 100.0)
		else:
			# Passive feminine choice: professionalism up, anxiety up
			professionalism = clamp(professionalism + 10.0, 0.0, 100.0)
			anxiety = clamp(anxiety + 10.0, 0.0, 100.0)
	
	_emit_stats()

func _emit_stats() -> void:
	Global.professionalism = professionalism
	Global.anxiety = anxiety
	stats_changed.emit(professionalism, anxiety)

# ── Ending calculator ─────────────────────────────────────────────
# Score breakdown:
#   outfit:        masc_formal=3, masc_casual=2, fem_formal=2, fem_casual=1
#   interruption:  confident=2,   passive=1
#   qa:            correct=2,     quiet=1
#
# Score 6-7  -> "praised"
# Score 4-5  -> "mixed"
# Score 2-3  -> "scolded"
#
# IMPORTANT ASYMMETRY:
# fem paths: confident + correct can still produce "scolded" because
# assertiveness in a femininely-coded outfit is penalized by the system.
# This is enforced by the bonus_penalty below.

func get_ending() -> String:
	# Explicit mapping rules to match desired tone per outfit and choices.
	# Rules summary (priority by outfit):
	# - fem_formal: any confident -> scolded; passive -> mixed (neutral)
	# - fem_casual: passive -> praised (with dressing note); confident -> scolded
	# - masc_formal: confident -> praised; passive -> scolded
	# - masc_casual: confident -> praised; passive -> scolded
	if outfit == "fem_formal":
		if interruption_choice == "confident":
			return "scolded"
		else:
			return "mixed"

	if outfit == "fem_casual":
		if interruption_choice == "passive":
			return "praised"
		else:
			return "scolded"

	if outfit == "masc_formal":
		if interruption_choice == "confident":
			return "praised"
		else:
			return "scolded"

	if outfit == "masc_casual":
		if interruption_choice == "confident":
			return "praised"
		else:
			return "scolded"

	# Fallback: use previous numeric approach if outfit is unset or unknown.
	var score: int = 0
	match outfit:
		"masc_formal":
			score += 3
		"masc_casual":
			score += 2
		"fem_formal":
			score += 2
		"fem_casual":
			score += 1

	match interruption_choice:
		"confident":
			score += 2
		"passive":
			score += 1

	match qa_choice:
		"correct":
			score += 2
		"quiet":
			score += 1

	if score >= 6:
		return "praised"
	elif score >= 4:
		return "mixed"
	else:
		return "scolded"

# ── Reset (call when player restarts) ────────────────────────────
func reset() -> void:
	outfit = ""
	interruption_choice = ""
	qa_choice = ""
	running_score = 0
	professionalism = 50.0
	anxiety = 50.0
	_emit_stats()
