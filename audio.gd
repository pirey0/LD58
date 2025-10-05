extends Node

func play(name, vol = 0.0, pitch_min = 0.9, pitch_max = 1.1):
	var node = AudioStreamPlayer.new()
	node.autoplay = true
	var p = "res://sfx/" + name + ".wav"
	assert(ResourceLoader.exists(p))
	node.stream = load(p)
	node.volume_db = vol
	node.pitch_scale = randf_range(pitch_min,pitch_max)
	node.finished.connect(node.queue_free)
	add_child(node)

func set_volume(v):
	AudioServer.set_bus_volume_linear(0,v)
