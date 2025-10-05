extends Node

@export var progress_slider : HSlider
@export var tev : Label
@export var contribution : Label
@export var gameover_obj : Control
@export var gameover_reason : Label
@export var retry_button : Button

var time := 0.0

var year_duration := 120.0

var in_year_end := false

func _ready() -> void:
	gameover_obj.hide()
	await get_tree().physics_frame
	var root = get_tree().get_first_node_in_group("main_company")
	root.on_vanish.connect(gameover.bind("%s went insolvent.\n\
	 The courts lifted the corporate veil, you have to stand trial. "% root.company_name))

func update_stats():
	
	var total := 0
	
	for x in get_tree().get_nodes_in_group("object"):
		if x is Company and x.player_owned:
			total += x.money + x.goods * Balancing.GOOD_VALUE_MID - x.debt - max(0.0, x.tax)
	tev.text = Util.format_money(total)
	pass

func _physics_process(delta: float) -> void:
	update_stats()
	
	if in_year_end:
		return 
		
	time += delta
	
	progress_slider.value = time/year_duration
	
	if time > year_duration:
		trigger_year_end()

func trigger_year_end():
	in_year_end = true
	progress_slider.value = 1.0
	
	for x in get_tree().get_nodes_in_group("end_of_year_listener"):
		x.on_year_end()
	
	var tw := create_tween()
	tw.tween_callback(start_new_year).set_delay(10.0)
	
	pass

func start_new_year():
	time = 0.0
	in_year_end = false
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_1:
				trigger_year_end()
			KEY_2:
				gameover("CHEAT!")
			KEY_3:
				Engine.time_scale += 1
			KEY_4:
				Engine.time_scale -= 1

func gameover(reason):
	gameover_obj.scale = Vector2.ZERO
	gameover_obj.show()
	gameover_reason.text = reason
	
	var tw := create_tween()
	tw.tween_interval(2.0)
	tw.tween_callback(func(): Engine.time_scale =0.1)
	tw.tween_property(gameover_obj,"scale", Vector2.ONE , 0.5).from(0.0 * Vector2.ONE)\
		.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	retry_button.pressed.connect(on_retry)

func on_retry():
	get_tree().quit(0)
