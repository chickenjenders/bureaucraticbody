extends TextureButton

@onready var label_one: Label = $Label
@onready var label_two: Label = $Label2

const POP_TIME := 0.12
const HOLD_TIME := 0.45
const START_DELAY := 0.1

func _ready() -> void:
	label_one.visible = false
	label_two.visible = false
	call_deferred("_run_label_loop")

func _run_label_loop() -> void:
	await get_tree().create_timer(START_DELAY).timeout

	while is_inside_tree():
		await _show_label(label_one, label_two)
		await _show_label(label_two, label_one)

func _show_label(active_label: Label, inactive_label: Label) -> void:
	inactive_label.visible = false
	inactive_label.modulate.a = 0.0
	inactive_label.scale = Vector2.ONE

	active_label.visible = true
	active_label.modulate.a = 0.0
	active_label.scale = Vector2(0.92, 0.92)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(active_label, "modulate:a", 1.0, POP_TIME)
	tween.parallel().tween_property(active_label, "scale", Vector2.ONE, POP_TIME)
	await tween.finished

	await get_tree().create_timer(HOLD_TIME).timeout
