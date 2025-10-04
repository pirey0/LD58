extends RefCounted
class_name ContextAction

var icon : Texture
var modifier : Texture
var modifier_color := Color.WHITE
var callback : Callable
var tooltip :String
var bg_color : Color


func _init(callback, tex, modifier, modifier_col = Color.WHITE, tooltip:= "", bg_color := Color.CORNFLOWER_BLUE):
	icon = tex
	self.modifier = modifier
	self.modifier_color = modifier_col
	self.callback = callback
	self.tooltip = tooltip
	self.bg_color = bg_color
