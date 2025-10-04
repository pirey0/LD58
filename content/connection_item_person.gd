extends ConnectionItem

var person_name:
	set(x):
		person_name = x
		$Label.text = x
		$Label.show()
