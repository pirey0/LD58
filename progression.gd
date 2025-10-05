extends Node
class_name Progression

var founded := false

var can_trade_goods := false
var can_create_subsidiary := false
var root_exists := false
var evaluation_visible := false
var bought_goods := false
var sold_goods := false
var created_subsidiary := false
var attempted_to_get_loan := false
var year_cycle_active := false
var year_cycle_completable := false
var year_finished := false
var received_loan := false
var had_bankrupcy_with_debt := false
var trading_goods_tier_2 := false

var net_worth := 0

var steps := []
var current_idx := -1

func _ready() -> void:
	G.progression = self

	var script_files = get_all_scripts_in_dir("res://progression")
	script_files.sort_custom(func(a,b): return a.naturalnocasecmp_to(b)<0)
	for x in script_files:
		var inst = load(x).new()
		add_child(inst,true)
		inst.name = (x as String).get_file().get_basename()
		steps.append(inst)
		
func skip_all():
	for x in range(current_idx, steps.size()):
		var step : ProgressionStep = steps[x]
		step.skip_step()
		await get_tree().process_frame
	
	G.meta.set_new_goal("","")
	
func start():
	start_next_step()

func start_next_step():
	current_idx += 1
	if current_idx >= steps.size():
		prints("PROGRESSION: Finished")
		G.meta.set_new_goal("","")
		return
	
	var current : ProgressionStep = steps[current_idx]
	prints("PROGRESSION: Starting",  current.name)
	current.finished.connect(on_step_finished)
	current.begin_step()
	G.meta.set_new_goal(current.get_display_title(), current.get_display_descr())
	

func on_step_finished():
	start_next_step()

func get_all_scripts_in_dir(path: String, recursive := false) -> Array:
	var scripts: Array = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Cannot open directory: %s" % path)
		return scripts

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			if recursive and not file_name.begins_with("."):
				scripts += get_all_scripts_in_dir(path.path_join(file_name), true)
		else:
			if file_name.ends_with(".gd") or file_name.ends_with(".gdextension") or file_name.ends_with(".cs"):
				scripts.append(path.path_join(file_name))
		file_name = dir.get_next()

	dir.list_dir_end()
	return scripts
