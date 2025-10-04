extends ConnectionItem

var value

func _ready() -> void:
	super()
	$Label.text = Util.format_money(value)
	$Label.show()
