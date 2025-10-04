extends Connection


func _ready() -> void:
	super()
	is_closable_by_user = false
	self.base_color = Color.DIM_GRAY
	self.color = base_color
	self.line_width = 2.0
	
	source.on_vanish.connect(on_owner_vanish)
	
func on_owner_vanish():
	if destination and destination.player_owned:
		destination.bankrupt()	
		
