extends Control
class_name Connection

var source
var destination

func _ready() -> void:
	position = source.position

func _process(_delta):
	size = get_dest_pos()
	
	queue_redraw()  # Redraw every frame (if controls can move)

func get_dest_pos():
	return G.world.screen_to_world_pos(G.get_mouse_pos())- source.position

func _draw():
	if not source:
		return

	var start_pos = Util.get_company_surface_offset(null, 0.0)
	var end_pos = get_dest_pos()

	# Draw cubic Bezier curve
	draw_connection(start_pos, end_pos, Color.WHITE)

func _get_canvas_item_visible_rect() -> Rect2:
	# Expand visible area by 2000 pixels in all directions
	return Rect2(Vector2(-2000, -2000), get_size() + Vector2(4000, 4000))

func draw_connection(from_pos: Vector2, to_pos: Vector2, color: Color):
	#TODO Change!
	
	var cp_offset = abs(from_pos.x - to_pos.x) * 0.5

	var p1 = from_pos
	var p2 = from_pos + Vector2(cp_offset, 0)
	var p3 = to_pos - Vector2(cp_offset, 0)
	var p4 = to_pos

	var points = PackedVector2Array()
	var steps = 24

	for i in range(steps + 1):
		var t = float(i) / steps
		var u = 1.0 - t
		var pos = (
			u**3 * p1 +
			3.0 * u*u*t * p2 +
			3.0 * u*t*t * p3 +
			t**3 * p4
		)
		points.append(pos)

	draw_polyline(points, color, 10.0)
