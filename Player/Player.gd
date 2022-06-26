extends KinematicBody2D

const ACCELERATION = 1600
const BASEMAXSPEED = 160
const FRICTION = 800
var velocity = Vector2.ZERO
var key_map = []
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
var updateFromNetwork = false
var network_input_vector = Vector2.ZERO
var input_vector = Vector2.ZERO
var position_x = 0
var position_y = 0
var last_x = 0
var last_y = 0
var selfPeerID
var ownerID = 1
var player: String
var hud = null
var lobby = false

onready var hpbar = $HPBar
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func setOwnerID(id):
	ownerID = id


func _ready():
	if GameModes.multiplayer_online or GameModes.waiting_lobby:
		selfPeerID = get_tree().get_network_unique_id()

func my_init(k, image, otherPlayers, p, h):
	if GameModes.multiplayer_online:
		$Nickname.visible = true
	hud = h
	updateHUD()
	player = p
	self.set_scale(GlobalVariables.scale_vector)
	for p in otherPlayers:
		add_collision_exception_with(p)
	key_map = k
	$Sprite.set_texture(image)
	speed_up_timer_init()

remote func syncPosition(x, y, input_vector):
	updateFromNetwork = true
	network_input_vector = input_vector
	position_x = x
	position_y = y

func _physics_process(delta):
	if updateFromNetwork:
		input_vector = network_input_vector
	else:
		if GameModes.waiting_lobby or GameModes.multiplayer_online:
			if selfPeerID == ownerID:
				input_vector.x = Input.get_action_strength(key_map[0]) - Input.get_action_strength(key_map[2])
				input_vector.y = Input.get_action_strength(key_map[1]) - Input.get_action_strength(key_map[3])
				input_vector = input_vector.normalized()
		else:
			input_vector.x = Input.get_action_strength(key_map[0]) - Input.get_action_strength(key_map[2])
			input_vector.y = Input.get_action_strength(key_map[1]) - Input.get_action_strength(key_map[3])
			input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * max_speed, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)

	velocity = move_and_slide(velocity)

	if updateFromNetwork:
		updateFromNetwork = false
		self.position.x = position_x
		self.position.y = position_y

	if selfPeerID == ownerID && (self.position.x != last_x || self.position.y != last_y):
		#if input_vector != Vector2.ZERO:
		rpc_unreliable("syncPosition", self.position.x, self.position.y, input_vector)
	
	last_x = self.position.x
	last_y = self.position.y
	

remote func syncTNT(p):
	var test_bomb = preload("res://World/TNT.tscn").instance()
	test_bomb.my_init(self)
	test_bomb.set_position(p)
	get_parent().add_child(test_bomb)

remote func syncBigBomb(p):
	var test_bomb = preload("res://World/BigBomb.tscn").instance()
	test_bomb.my_init(self)
	test_bomb.set_position(p)
	get_parent().add_child(test_bomb)

remote func syncLandMine(p):
	var test_bomb = preload("res://World/LandMine.tscn").instance()
	test_bomb.my_init(self)
	test_bomb.set_position(p)
	get_parent().add_child(test_bomb)

remote func syncC4(p):
	if(c4_planted != null):
		c4_planted.to_explode = true
		c4_planted = null
	elif(c4_planted == null && c4 > 0):
		c4 -= 1
		c4_planted = preload("res://World/C4.tscn").instance()
		c4_planted.my_init(self)
		c4_planted.set_position(self.position)
		get_parent().add_child(c4_planted)
	play_place_bomb_sound()

func _process(_delta):
	if GameModes.multiplayer_online or GameModes.waiting_lobby:
		if selfPeerID != ownerID:
			return

	if Input.is_action_just_released(key_map[4]) && number_of_bombs != 0:
		number_of_bombs -= 1
		var test_bomb = preload("res://World/TNT.tscn").instance()
		test_bomb.my_init(self)
		test_bomb.set_position(self.position)
		get_parent().add_child(test_bomb)
		if GameModes.multiplayer_online or GameModes.waiting_lobby:
			rpc("syncTNT", self.position)
		updateHUD()
		play_place_bomb_sound()

	if Input.is_action_just_released(key_map[5]) && big_bombs != 0:
		big_bombs -= 1
		var test_bomb = preload("res://World/BigBomb.tscn").instance()
		test_bomb.my_init(self)
		test_bomb.set_position(self.position)
		get_parent().add_child(test_bomb)
		if GameModes.multiplayer_online or GameModes.waiting_lobby:
			rpc("syncBigBomb", self.position)
		updateHUD()
		play_place_bomb_sound()

	if Input.is_action_just_released(key_map[6]) && landMines != 0:
		landMines -= 1
		var test_bomb = preload("res://World/LandMine.tscn").instance()
		test_bomb.my_init(self)
		test_bomb.set_position(self.position)
		get_parent().add_child(test_bomb)
		if GameModes.multiplayer_online or GameModes.waiting_lobby:
			rpc("syncLandMine", self.position)
		updateHUD()
		play_place_bomb_sound()

	if Input.is_action_just_released(key_map[7]):
		if(c4_planted != null):
			c4_planted.to_explode = true
			c4_planted = null
			if GameModes.multiplayer_online or GameModes.waiting_lobby:
				rpc("syncC4", self.position)
		elif(c4_planted == null && c4 > 0):
			c4 -= 1
			c4_planted = preload("res://World/C4.tscn").instance()
			c4_planted.my_init(self)
			c4_planted.set_position(self.position)
			get_parent().add_child(c4_planted)
			if GameModes.multiplayer_online:
				rpc("syncC4", self.position)

		updateHUD()
		play_place_bomb_sound()

func add_shield(shield):
	$HPBar.add_shield(shield)

func add_hp(hp):
	$HPBar.add_hp(hp)

remote func syncTakeDamage(damage):
	var dead = $HPBar.take_damage(damage)
	if dead:
		GameModes.addDeath(self)
		queue_free()
		get_parent().get_parent().game_over()

func take_damage(damage):
	if GameModes.waiting_lobby:
		return
	if GameModes.multiplayer_online:
		if !get_tree().is_network_server():
			return
		rpc("syncTakeDamage", damage)
		
	var dead = $HPBar.take_damage(damage)
	if dead:
		GameModes.addDeath(self)
		queue_free()
		if GameModes.game_is_over():
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

func play_place_bomb_sound():
	if Settings.sound_fx_enabled:
		$place_bomb_sound.volume_db = Settings.sound_fx_volume - 25
		$place_bomb_sound.play()

func play_powerup_sound():
	if Settings.sound_fx_enabled:
		$powerup_sound.volume_db = Settings.sound_fx_volume - 25
		$powerup_sound.play()

func play_load_sound():
	if Settings.sound_fx_enabled:
		$load_fx.volume_db = Settings.sound_fx_volume - 25
		$load_fx.play()

func updateHUD():
	if hud != null:
		hud.updateBombs([number_of_bombs, big_bombs, landMines, c4])
