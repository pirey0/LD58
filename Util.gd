extends Node
class_name Util

static func get_random_company_name():
	return "New Company %s" % randi_range(1000,9999)

static func format_money(s:int) -> String:
		return str(s) + "$"

static func get_company_surface_offset(c, angle):
	return Vector2(sin(angle), -cos(angle)) * 125.0
	pass
