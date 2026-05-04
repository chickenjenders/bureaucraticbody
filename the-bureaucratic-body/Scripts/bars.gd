extends CanvasLayer

@onready var GS = get_node("/root/GameState")
@onready var professionalism_bar: TextureProgressBar = $professionalism
@onready var anxiety_bar: TextureProgressBar = $anxiety

func _ready() -> void:
    _sync_from_state()
    if not GS.stats_changed.is_connected(_on_stats_changed):
        GS.stats_changed.connect(_on_stats_changed)

func set_stats(professionalism: float, anxiety: float) -> void:
    professionalism_bar.value = clamp(professionalism, 0.0, 100.0)
    anxiety_bar.value = clamp(anxiety, 0.0, 100.0)

func _sync_from_state() -> void:
    set_stats(GS.professionalism, GS.anxiety)

func _on_stats_changed(professionalism: float, anxiety: float) -> void:
    set_stats(professionalism, anxiety)
