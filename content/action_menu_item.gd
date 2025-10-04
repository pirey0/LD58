extends Control

var callback

func _ready() -> void:
	$Button.mouse_entered.connect(on_mouse_enter)
	$Button.mouse_exited.connect(on_mouse_exit)
	$Button.pressed.connect(callback)
	scale = Vector2.ZERO
	var tw = create_tween()
	tw.tween_property(self,"scale", Vector2.ONE , 1.0).from(0.1 * Vector2.ONE)\
			.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_OUT)

func selfdestroy():
	var tw = create_tween()
	tw.tween_property(self,"scale", Vector2.ZERO , 0.5).from(Vector2.ONE)\
			.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)

func setup(action : ContextAction):
	$Main.texture = action.icon
	$Modifier.texture = action.modifier
	$Modifier.modulate = action.modifier_color

func on_mouse_enter() -> void:
	set_highlight(true)

func on_mouse_exit() -> void:
	set_highlight(false)


func set_highlight(val):
	$Button.modulate = Color.YELLOW if val else Color.WHITE
