extends CanvasLayer

@onready var professionalism_bar: TextureProgressBar = $professionalism
@onready var anxiety_bar: TextureProgressBar = $anxiety

func _ready() -> void:
    _sync_from_state()
    if not GameState.stats_changed.is_connected(_on_stats_changed):
        GameState.stats_changed.connect(_on_stats_changed)

func set_stats(professionalism: float, anxiety: float) -> void:
    professionalism_bar.value = clamp(professionalism, 0.0, 100.0)
    anxiety_bar.value = clamp(anxiety, 0.0, 100.0)

func _sync_from_state() -> void:
    set_stats(GameState.professionalism, GameState.anxiety)

func _on_stats_changed(professionalism: float, anxiety: float) -> void:
    set_stats(professionalism, anxiety)
