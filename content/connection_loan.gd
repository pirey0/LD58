extends Connection

var closed := false
var active_transfers := 0



func _ready() -> void:
	super()
	set_physics_process(false)
	self.base_color = Color.SLATE_GRAY

func on_connection_established():
	super()
	
	var obj = spawn_load_hud()
	#TODO
	
func spawn_load_hud():
	pass
