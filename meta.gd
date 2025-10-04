extends Node

@export var progress_slider : HSlider

var time := 0.0

var year_duration := 60.0

var in_year_end := false

func _physics_process(delta: float) -> void:
	
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
	
	
