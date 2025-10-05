extends Node

func _ready() -> void:
	

	spawn_all_companies()

	await get_tree().physics_frame
	
	G.progression.start()
	

func spawn_all_companies():
	var companies := load_companies_from_file()

	prints("Spawning", companies.size(), "real companies.")
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 0
	
	companies.sort_custom(func(a,b): return a[1] > b[1])

	
	for data in companies:
		var angle =  rnd.randf_range(0.0, 2*PI)
		var value = data[1]
		var dist = log(value)/log(1.003)
		var spawn_point = dist * Vector2(sin(angle), cos(angle))
		var comp :Company = G.world.spawn_company_at(spawn_point, data[0])
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

	
