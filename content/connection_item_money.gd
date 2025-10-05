extends ConnectionItem

var value:
	set(x):
		value = x
		$Label.text = Util.format_money(value)
		$Label.show()

func _ready() -> void:
	super()
	
	Audio.play("whouhu",-15)
func vanish():
	super()
	Audio.play("wabib",-10)
