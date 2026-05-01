extends CanvasLayer

@onready var professionalism_bar: TextureProgressBar = $professionalism
@onready var anxiety_bar: TextureProgressBar = $anxiety

func set_stats(professionalism: float, anxiety: float) -> void:
    professionalism_bar.value = clamp(professionalism, 0.0, 100.0)
    anxiety_bar.value = clamp(anxiety, 0.0, 100.0)
