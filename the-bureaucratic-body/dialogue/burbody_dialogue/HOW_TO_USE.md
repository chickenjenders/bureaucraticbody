# The Bureaucratic Body — Dialogue Manager 3 Files

## How to plug these into your Godot project

### File list

- GameState.gd — autoload, holds all game state + scoring logic
- scene1_wakeup.dialogue — Scene 1: wake up sequence
- scene2_outfit_reason.dialogue — Scene 2: board meeting context narration
- scene3_closet.dialogue — Scene 3: outfit picker with branching confirms
- scene4_eavesdrop.dialogue — Scene 4: coworker eavesdrop (bubble-click structure)
- scene5_presentation.dialogue — Scene 5: coworker interruption + board Q&A
- scene6_meeting.dialogue — Scene 6: boss meeting + theory reflection endings

---

### Step 1 — Add GameState autoload

Project > Project Settings > Autoload

- Path: res://GameState.gd
- Name: GameState ← must match exactly, dialogue files reference this name

---

### Step 2 — Copy .dialogue files

Place all .dialogue files in res://dialogue/ (or wherever you prefer).
Update the paths in your scene scripts to match.

---

### Step 3 — Trigger dialogue from your scenes

Each scene script calls DialogueManager like this:

```gdscript
# Scene 1
DialogueManager.show_dialogue_balloon(
    load("res://dialogue/burbody_dialogue/scene1_wakeup.dialogue"), "wakeup"
)

# Scene 2
DialogueManager.show_dialogue_balloon(
    load("res://dialogue/burbody_dialogue/scene2_outfit_reason.dialogue"), "outfit_intro"
)

# Scene 3
DialogueManager.show_dialogue_balloon(
    load("res://dialogue/burbody_dialogue/scene3_closet.dialogue"), "closet_start"
)

# Scene 4 — pass the outfit-specific starting title
# Call _setup first, then bubble titles on each button press
var setup_title = GameState.outfit + "_setup"
DialogueManager.show_dialogue_balloon(
    load("res://dialogue/burbody_dialogue/scene4_eavesdrop.dialogue"), setup_title
)

# Scene 5
DialogueManager.show_dialogue_balloon(
    load("res://dialogue/burbody_dialogue/scene5_presentation.dialogue"), "presentation_start"
)

# Scene 6
DialogueManager.show_dialogue_balloon(
    load("res://dialogue/burbody_dialogue/scene6_meeting.dialogue"), "meeting_start"
)
```

---

### Step 4 — Scene 4 bubble-click pattern

In your eavesdrop scene, each chattering bubble is a Button.
Connect each button's pressed signal to a function like this:

```gdscript
# In your Scene 4 GDScript:
var bubble_index: int = 0
var outfit_key: String = ""

func _ready():
    outfit_key = GameState.outfit  # e.g. "fem_formal"
    # Show setup narration first
    await DialogueManager.show_dialogue_balloon(
        load("res://dialogue/burbody_dialogue/scene4_eavesdrop.dialogue"),
        outfit_key + "_setup"
    )

func _on_bubble_pressed():
    bubble_index += 1
    var title = outfit_key + "_bubble" + str(bubble_index)
    # Check if this bubble title exists — if not, show reflection
    # Bubble counts per outfit:
    #   masc_formal:  4 bubbles then reflection
    #   masc_casual:  3 bubbles then reflection
    #   fem_formal:   4 bubbles then reflection
    #   fem_casual:   4 bubbles then reflection
    var max_bubbles = {"masc_formal": 4, "masc_casual": 3, "fem_formal": 4, "fem_casual": 4}
    if bubble_index <= max_bubbles[outfit_key]:
        await DialogueManager.show_dialogue_balloon(
            load("res://dialogue/burbody_dialogue/scene4_eavesdrop.dialogue"), title
        )
    else:
        await DialogueManager.show_dialogue_balloon(
            load("res://dialogue/burbody_dialogue/scene4_eavesdrop.dialogue"),
            outfit_key + "_reflection"
        )
        # Transition to Scene 5 here
        get_tree().change_scene_to_file("res://Scenes/presentation.tscn")
```

---

### Step 5 — Scene 6 ending routing

The dialogue file calls `GameState.get_ending()` automatically.
That function reads outfit + interruption_choice + qa_choice
and returns "praised", "mixed", or "scolded".

The asymmetry is built into the score:

- Masculine outfit + confident + correct → praised
- Feminine outfit + confident + correct → mixed or scolded (penalty applied)
- Same choices. Different outcome. That is the argument.

---

### Step 6 — Reset for replay

Call GameState.reset() before restarting Scene 1:

```gdscript
GameState.reset()
get_tree().change_scene_to_file("res://scenes/scene1_wakeup.tscn")
```
