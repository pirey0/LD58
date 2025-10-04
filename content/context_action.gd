extends RefCounted
class_name ContextAction

var icon : Texture
var modifier : Texture
var modifier_color := Color.WHITE
var callback : Callable


func _init(callback, tex, modifier, modifier_col = Color.WHITE):
	icon = tex
	self.modifier = modifier
	self.modifier_color = modifier_col
	self.callback = callback
