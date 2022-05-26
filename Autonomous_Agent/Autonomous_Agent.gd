extends KinematicBody2D

const ACCELERATION = 1600
const BASEMAXSPEED = 160
const FRICTION = 800
var velocity = Vector2.ZERO
var keys = []
var damage_multiplier = 1
var radius_multiplier = 1
var max_speed = BASEMAXSPEED
var max_bombs = 1
var number_of_bombs = 1
var big_bombs = 0
var landMines = 0
var speed_up_timer
var c4 = 0
var c4_planted = null

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

onready var rng = RandomNumberGenerator.new()
onready var last_time = OS.get_unix_time()
onready var input_vector = Vector2.ZERO

func my_init(k, image, otherPlayers):
	c4=1
	self.set_scale(GlobalVariables.scale_vector)
	for p in otherPlayers:
		add_collision_exception_with(p)
	keys = k
	$Sprite.set_texture(image)
	speed_up_timer_init()

func _physics_process(delta):
	var time_now = OS.get_unix_time()
	
	
	if time_now - last_time >= 1:
		rng.randomize()
		input_vector.x = rng.randf_range(-10, 10)
		input_vector.y = rng.randf_range(-10, 10)
		input_vector = input_vector.normalized()
		last_time = time_now
	else:
		#input_vector.x = Input.get_action_strength(keys[0]) - Input.get_action_strength(keys[2])
		#input_vector.y = Input.get_action_strength(keys[1]) - Input.get_action_strength(keys[3])
		#input_vector = input_vector.normalized()
		pass

	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * max_speed, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)
		
	velocity = move_and_slide(velocity)

func _process(_delta):
	if (rng.randf_range(-10, 10) >= 9.85 || Input.is_action_just_released(keys[4])) && number_of_bombs != 0:
		number_of_bombs -= 1
		var test_bomb = preload("res://World/TNT.tscn").instance()
		test_bomb.my_init(self)
		test_bomb.set_position(self.position)
		get_parent().add_child(test_bomb)

	if (rng.randf_range(-10, 10) >= 9.9 || Input.is_action_just_released(keys[5])) && big_bombs != 0:
		big_bombs -= 1
		var test_bomb = preload("res://World/BigBomb.tscn").instance()
		test_bomb.my_init(self)
		test_bomb.set_position(self.position)
		get_parent().add_child(test_bomb)

	if (rng.randf_range(-10, 10) >= 9.9 || Input.is_action_just_released(keys[5])) && landMines != 0:
		landMines -= 1
		var test_bomb = preload("res://World/LandMine.tscn").instance()
		test_bomb.my_init(self)
		test_bomb.set_position(self.position)
		get_parent().add_child(test_bomb)

	if rng.randf_range(-10, 10) >= 9.9 || Input.is_action_just_released(keys[5]):
		if(c4_planted != null):
			c4_planted.to_explode = true
			c4_planted = null
		if(c4_planted == null && c4 > 0):
			c4 -= 1
			c4_planted = preload("res://World/C4.tscn").instance()
			c4_planted.my_init(self)
			c4_planted.set_position(self.position)
			get_parent().add_child(c4_planted)

func add_shield(shield):
	$HPBar.add_shield(shield)

func add_hp(hp):
	$HPBar.add_hp(hp)

func take_damage(damage):
	var dead = $HPBar.take_damage(damage)
	if dead:
		queue_free()
		get_parent().get_parent().game_over()

func speed_up_timer_init():
	speed_up_timer = Timer.new()
	add_child(speed_up_timer)
	speed_up_timer.autostart = false
	speed_up_timer.connect("timeout", self, "speed_down")
	speed_up_timer.wait_time = 10

func speed_up():
	if speed_up_timer.time_left == 0:
		max_speed += 100
	speed_up_timer.start()

func speed_down():
	max_speed -= 100
	speed_up_timer.stop()

func play_powerup_sound():
	if Settings.sound_fx_enabled:
		$powerup_sound.volume_db = Settings.sound_fx_volume - 25
		$powerup_sound.play()

func play_load_sound():
	if Settings.sound_fx_enabled:
		$load_fx.volume_db = Settings.sound_fx_volume - 25
		$load_fx.play()
