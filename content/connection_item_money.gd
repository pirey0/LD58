extends ConnectionItem

var value:
	set(x):
		value = x
		$Label.text = Util.format_money(value)
		$Label.show()
