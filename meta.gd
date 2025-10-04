extends Node

@export var progress_slider : HSlider
@export var tev : Label
@export var contribution : Label

var time := 0.0

var year_duration := 60.0

var in_year_end := false

func update_stats():
	
	var total := 0
	
	for x in get_tree().get_nodes_in_group("object"):
		if x is Company and x.player_owned:
			total += x.money + x.goods * 300.0 - x.debt - max(0.0, x.tax)
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
	
	var tw := create_tween()
	tw.tween_callback(start_new_year).set_delay(3.0)
	
	pass

func start_new_year():
	time = 0.0
	in_year_end = false
	
	
