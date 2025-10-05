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
var aquired_public_company := false
var can_leverage_buyout := false #TODO
var received_leveraged_buyout := false #TODO

var net_worth := 0

var steps := []
var current_idx := -1
var rnd := RandomNumberGenerator.new()
var companies_to_spawn :Array

func _ready() -> void:
	G.progression = self
	
	var script_files = get_all_scripts_in_dir("res://progression")
	script_files.sort_custom(func(a,b): return a.naturalnocasecmp_to(b)<0)
	for x in script_files:
		var inst = load(x).new()
		add_child(inst,true)
		inst.name = (x as String).get_file().get_basename()
		steps.append(inst)

	rnd.seed = 0
	companies_to_spawn = load_companies_from_file()
	companies_to_spawn.sort_custom(func(a,b): return a[1] > b[1])
	prints("Loaded", companies_to_spawn.size(), "real companies.")
	
func skip_to(n):
	for x in range(current_idx, steps.size()):
		var step : ProgressionStep = steps[x]
		if step.name == n:
			current_idx = x-1
			start_next_step()
			return
		else:
			step.skip_step()
			current_idx += 1
		await get_tree().process_frame

func skip():
	steps[current_idx].skip_step()
	start_next_step()

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


func spawn_companies(count):
	if count == -1:
		count = companies_to_spawn.size()
	for x in count:
		var data = companies_to_spawn[-1]
		companies_to_spawn.remove_at(companies_to_spawn.size()-1)
		var angle =  rnd.randf_range(0.0, 2*PI)
		var value = data[1]
		var dist = log(value)/log(1.003)
		var spawn_point = dist * Vector2(sin(angle), cos(angle))
		var comp :Company = G.world.spawn_company_at(spawn_point, data[0], preload("res://companies/public_company.tscn"))
		comp.money = data[1]
		comp.on_initial_transaction_finished_for_sub(comp)
		comp.update_state()
		
func load_companies_from_file() -> Array:
	var file = FileAccess.open("res://companies.txt", FileAccess.READ)
	
	var next_line := file.get_csv_line()
	next_line = file.get_csv_line()
	#skip header
	
	var out := []
	while not next_line.size()<4:
		var line := next_line
		var value = int(line[3])
		if value > 5000.0:
			out.append([line[1], value])
		var linenr := int(line[0])
		for x in (1 if (linenr < 20 or linenr >= 3518) else 25):
			next_line = file.get_csv_line()
	return out
