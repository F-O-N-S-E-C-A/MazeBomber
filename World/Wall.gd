extends StaticBody2D

var health
var border = false

func _ready():
	self.set_scale(GlobalVariables.scale_vector)
	pass

func set_border():
	border = true

func calculate_hp(distance_to_middle):
	health = distance_to_middle * 40 + Utils.uniform(20, 60)
	set_texture()
	pass

func take_damage(damage):
	if !border && health > 0:
		var new_health = health - damage
		if new_health < 0:
			health = new_health
			destroy()
			queue_free()
		else:
			health = new_health
			set_texture()

func destroy():
	var name = PowerUpRandomiser.get_random_power_up()
	if name != null:
		var power_up = load("res://Pickupables/" + name + ".tscn").instance()
		power_up.set_position(self.position)
		power_up.set_scale(GlobalVariables.scale_vector)
		get_parent().add_child(power_up)
		

func set_texture():
	if !border:
		var n = 4 - floor(health*4/100)
		$Sprite.set_texture(load("res://World/images/parede_fase" + str(n) + ".png"))

	
