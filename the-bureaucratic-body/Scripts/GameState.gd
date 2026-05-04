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

# ── State variables ──────────────────────────────────────────────
var outfit: String = ""             # "masc_formal" | "masc_casual" | "fem_formal" | "fem_casual"
var interruption_choice: String = "" # "passive" | "confident"
var qa_choice: String = ""           # "correct" | "quiet"

# ── Setters (called as mutations from .dialogue files) ────────────
func set_outfit(value: String) -> void:
	outfit = value

func set_interruption(value: String) -> void:
	interruption_choice = value

func set_qa(value: String) -> void:
	qa_choice = value

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
	var score: int = 0

	# Outfit score
	match outfit:
		"masc_formal":
			score += 3
		"masc_casual":
			score += 2
		"fem_formal":
			score += 2
		"fem_casual":
			score += 1

	# Interruption score
	match interruption_choice:
		"confident":
			score += 2
		"passive":
			score += 1

	# QA score
	match qa_choice:
		"correct":
			score += 2
		"quiet":
			score += 1

	# ── Asymmetry penalty ──────────────────────────────────────────
	# Feminine outfit + assertive choices = system penalizes harder.
	# Same confident + correct combo costs fem paths 2 points.
	# This makes fem_formal + confident + correct -> "mixed" not "praised"
	# and fem_casual + confident + correct -> "scolded"
	if (outfit == "fem_formal" or outfit == "fem_casual") and interruption_choice == "confident" and qa_choice == "correct":
		score -= 2

	# ── Map score to ending ────────────────────────────────────────
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
