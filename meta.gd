extends Node
class_name Meta

@export var progress_slider : HSlider
@export var tev : Label
@export var contribution : Label
@export var gameover_obj : Control
@export var gameover_reason : Label
@export var retry_button : Button

@export var main_menu_parent : Control
@export var begin_game_btn :Button

@export var objective_label : Label
@export var objective_descr : Label
@export var cycle_parent : Control
@export var evaluation_parent : Control

@export var win_parent : Control
@export var win_timer : Label

signal new_game_clicked

var time := 0.0

var year_duration := 120.0

var in_year_end := false


func _ready() -> void:
	G.meta = self
	gameover_obj.hide()
	win_parent.hide()
	await get_tree().physics_frame
	#var root = get_tree().get_first_node_in_group("main_company")
	#root.on_vanish.connect(gameover.bind("%s went insolvent.\n\
	# The courts lifted the corporate veil, you have to stand trial. "% root.company_name))
	objective_descr.text = ""
	objective_label.text = ""
	begin_game_btn.pressed.connect(on_new_game)

func on_new_game():
	new_game_clicked.emit()
	close_main_menu()


func close_main_menu():
	main_menu_parent.show()
	begin_game_btn.pressed.disconnect(on_new_game)
	var tw := create_tween()
	tw.tween_property(main_menu_parent,"scale", Vector2.ZERO , 1)\
		.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_IN)

func update_stats():
	evaluation_parent.visible = G.progression.evaluation_visible
	
	var total := 0
	
	for x in get_tree().get_nodes_in_group("object"):
		if x is Company and x.player_owned:
			total += x.money + x.goods * Balancing.GOOD_VALUE_HIGH - x.debt - max(0.0, x.tax)
	tev.text = Util.format_money(total)
	G.progression.net_worth = total
	pass

func _physics_process(delta: float) -> void:
	
	update_stats()
	
	if in_year_end:
		return 
	
	cycle_parent.visible = G.progression.year_cycle_active
	
	if G.progression.year_cycle_active:
		time += delta
		
		if not G.progression.year_cycle_completable:
			time = min(year_duration-20.0,time)
		
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
	G.progression.year_finished = true
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
			KEY_Q:
				G.progression.skip()
			KEY_5:
				get_tree().get_first_node_in_group("main_company").change_money(1_000_000,false)

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

func win():
	set_new_goal("","")
	win_parent.scale = Vector2.ZERO
	win_parent.show()
	
	var dur = Time.get_unix_time_from_system() - G.progression.start_time
	win_timer.text = win_timer.text% format_time_delta(dur)
	
	var tw := create_tween()
	tw.tween_interval(2.0)
	tw.tween_callback(func(): Engine.time_scale =0.1)
	tw.tween_property(win_parent,"scale", Vector2.ONE , 0.5).from(0.0 * Vector2.ONE)\
		.set_trans(Tween.TransitionType.TRANS_BACK).set_ease(Tween.EASE_OUT)

func format_time_delta(seconds: int) -> String:
	seconds = abs(seconds)
	var hours = int(seconds / 3600)
	var minutes = int((seconds % 3600) / 60)
	var secs = int(seconds % 60)
	return "%02d:%02d:%02d" % [hours, minutes, secs]

func on_retry():
	get_tree().quit(0)


var goaltw : Tween
func set_new_goal(title,descr):
	if goaltw:
		goaltw.kill()
	goaltw = create_tween()
	
	goaltw.tween_property(objective_descr, "visible_ratio", 0.0, 0.1 +objective_descr.text.length()*0.03)
	goaltw.tween_property(objective_label, "visible_ratio", 0.0, 0.1 +objective_label.text.length()*0.03)
	goaltw.tween_callback(func():
			objective_label.text = title
			objective_descr.text = descr
			)
	goaltw.tween_property(objective_label, "visible_ratio", 1.0,  0.1  + title.length()*0.03)
	goaltw.tween_property(objective_descr, "visible_ratio", 1.0,  0.1  + descr.length()*0.03)
