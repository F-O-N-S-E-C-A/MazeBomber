extends Node2D

var timer

func _init(pos):
	position = pos
	timer = Timer.new()
	add_child(timer)
	timer.autostart = false
	timer.connect("timeout", self, "spawn")
	timer.wait_time = 8

func start_timer():
	if timer.time_left == 0:
		timer.start()
	else:
		print("yello")

func spawn():
	var boom_box = preload("res://Pickupables/BoomBox.tscn").instance()
	boom_box.my_init(self)
	add_child(boom_box)
	timer.stop()
