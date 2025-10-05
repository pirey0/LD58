extends Control
class_name ConnectionItem

signal target_reached

var connection : Connection
var vanished := false
var progress := 0.0
@export var speed := 0.25
var reversed := false

func setup(con : Connection):
	connection = con
	con.on_vanish.connect(on_connection_vanish)
	if con.freeing:
		on_connection_vanish()
	
func _ready() -> void:
	var tw = create_tween()
	tw.tween_property(self,"scale", Vector2.ONE , 1.0).from(0.1 * Vector2.ONE)\
			.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Audio.play("whouhu",-15)

func _process(delta: float) -> void:
	if vanished:
		return
	
	progress += delta * speed
	if progress >= 1.0:
		on_target_reached()
		
	position = connection.get_pos_at((1.0 - progress) if reversed else progress)
	
func on_target_reached():
	create_tween().tween_callback(func(): target_reached.emit()).set_delay(0.5)
	vanish()

func on_connection_vanish():
	vanish()

func vanish():
	if vanished:
		return
	vanished = true
	
	Audio.play("wabib",-10)
	var tw = create_tween()
	tw.tween_property(self,"scale", Vector2.ZERO , 0.5).from(Vector2.ONE)\
			.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(queue_free)

func set_modifier(tex, color):
	$Modifier.texture = tex
	$Modifier.modulate = color
	$Modifier.show()
	
