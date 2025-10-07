extends Node

func _ready() -> void:
	var debug := true
	
	if debug and OS.has_feature("editor"):
		G.progression.skip_to("progression_step_10")
	else:
		G.progression.start()
