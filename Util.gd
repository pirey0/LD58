extends Node
class_name Util

static func get_random_company_name():
	return "New Company %s" % randi_range(1000,9999)

static func format_money(s: int) -> String:
	var suffixes = ["", "k", "m", "b", "t", "q", "Q", "s", "S", "o", "n"]
	var num = float(s)
	var i = 0
	
	while num >= 1000.0 and i < suffixes.size() - 1:
		num /= 1000.0
		i += 1
	
	var str_val := ""
	if num < 10:
		str_val = str(round(num * 100) / 100.0)  # up to 2 decimals
	elif num < 100:
		str_val = str(round(num * 10) / 10.0)   # up to 1 decimal
	else:
		str_val = str(int(num))                  # no decimals for large ones
	
	# Trim trailing .0 or .00
	if str_val.ends_with(".0"):
		str_val = str_val.substr(0, str_val.length() - 2)
	elif str_val.ends_with(".00"):
		str_val = str_val.substr(0, str_val.length() - 3)
	
	return  "$" + str_val + suffixes[i]


static func get_company_surface_offset(c : Company, angle):
	return Vector2(sin(angle), -cos(angle)) * 125.0 * c.size_mult
