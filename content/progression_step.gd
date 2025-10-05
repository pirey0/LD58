extends Node
class_name ProgressionStep

signal finished
	
func get_display_title() -> String:
	return ""

func get_display_descr() -> String:
	return ""

func _ready() -> void:
	set_physics_process(false)

func begin_step():
	set_physics_process(true)
	pass

func skip_step():
	finish()
	
	
func finish():
	set_physics_process(false)
	finished.emit()
