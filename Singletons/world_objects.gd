extends Node
# obs[x][y] = [wall, spawners and pickupables, bombs]
# spawners = 1 
# pickupable = 2, 3, ...

var agent
var agent_hp = 0
var agent_shield_hp = 0

var player
var player_hp = 0
var player_shield_hp = 0

var walls = []
var pickupables = []
var bombs = []
var spawners = []

var time_to_win = 0
var start_counting = false

export(bool) var ready = false

# ** rewards **
var player_health_reward = 0 
var player_shield_reward = 0
var agent_health_reward = 0
var agent_shield_reward = 0
var pickup_bombs_reward = 0 # 1 for each that was picked up
var pickup_xp_reward = 0 # 1 for each that was picked up
var pickup_hp_reward = 0 # 1 for each that was picked up
var destroy_walls_reward = 0 # 1 for each that was destroied
var weaken_walls_reward = 0 # cumulative sum of the damage in every wall


var pickupable_classes = [preload("res://Pickupables/BigBombPowerUp.gd"),
preload("res://Pickupables/c4PowerUp.gd"),
preload("res://Pickupables/DamagePowerUp.gd"),
preload("res://Pickupables/HPPowerUp.gd"),
preload("res://Pickupables/LandMinePowerUp.gd"),
preload("res://Pickupables/MultipleTNTPowerUp.gd"),
preload("res://Pickupables/ShieldPowerUp.gd"),
preload("res://Pickupables/SpeedPowerUp.gd")]

var pickupable_names = ["BigBombPowerUp",
"c4PowerUp",
"DamagePowerUp",
"HPPowerUp",
"LandMinePowerUp",
"MultipleTNTPowerUp",
"ShieldPowerUp",
"SpeedPowerUp"]

var bomb_classes = [preload("res://World/TNT.gd"), 
preload("res://World/BigBomb.gd"),
preload("res://World/LandMine.gd"),
preload("res://World/C4.gd")]

var bomb_names =  ["TNT", "BigBomb", "LandMine", "C4"]

var bomb_encoding = [1000, 100, 10, 1]

func _process(delta):
	if(start_counting):
		time_to_win = time_to_win + delta
		
func start_count():
	start_counting = true
	
func stop_count():
	if start_counting:
		print(" Time to win: " + String(time_to_win))
	start_counting = false
		
# for rule based agents
func map_matrix():
	var obs = init_matrix()
	for w in walls: 
		if w.border:
			obs[posX(w)][posY(w)]["walls"] = -1
		else:
			obs[posX(w)][posY(w)]["walls"] = w.health
	for p in pickupables:
		for i in range(len(pickupable_classes)):
			if p is pickupable_classes[i]:
				obs[posX(p)][posY(p)]["pickupables"] = pickupable_names[i]
				
	for s in spawners:
		obs[posX(s)][posY(s)]["spawners"] = 1
		
	for b in bombs: 
		for i in range(len(bomb_classes)):
			if b is bomb_classes[i]:
				obs[posX(b)][posY(b)]["bombs"].append(bomb_names[i])
	return obs
				

func map_obs():
	var obs = init_obs()
	for w in walls: 
		if w.border:
			obs[posX(w)][posY(w)][0] = -1
		else:
			obs[posX(w)][posY(w)][0] = w.health
	for p in pickupables:
		for i in range(len(pickupable_classes)):
			if p is pickupable_classes[i]:
				obs[posX(p)][posY(p)][1] = i + 2
				
	for s in spawners:
		obs[posX(s)][posY(s)][1] = 1
		
	for b in bombs: 
		for i in range(len(bomb_classes)):
			if b is bomb_classes[i]:
				obs[posX(b)][posY(b)][2] = obs[posX(b)][posY(b)][2] + bomb_encoding[i]
				#print(obs[posX(b)][posY(b)][2], " - (", posX(b), ",", posY(b), ")")
	return obs
	

func flatten(array):
	var lst_out = []
	
	for i in range(len(array)):
		if typeof(array[i]) == TYPE_ARRAY:
			for j in flatten(array[i]):
				lst_out.append(j)
		else:
			lst_out.append(array[i])
			
	return lst_out

func player_obs_continuous():
	return [	player.position[0], player.position[1],
	agent.position[0], agent.position[1], 
	agent_hp, player_hp, agent_shield_hp, player_shield_hp, 
	agent.number_of_bombs, agent.big_bombs, agent.landMines, agent.c4]
	
func player_obs_discrete():
	return [posX(player), posY(player), 
	posX(agent), posY(agent), 
	agent.hpbar.health, player.hpbar.health, agent.hpbar.shield, player.hpbar.shield, 
	agent.number_of_bombs, agent.big_bombs, agent.landMines, agent.c4]
	
func obs_discrete():
	var l = []
	for i in flatten(map_obs()):
		l.append(1.0*i)
	l.append(1.0 * posX(player))
	l.append(1.0 * posY(player))
	l.append(1.0 * posX(agent))
	l.append(1.0 * posY(agent))
	l.append(1.0 * agent.hpbar.health)
	l.append(1.0 * player.hpbar.health)
	l.append(1.0 * agent.hpbar.shield)
	l.append(1.0 * player.hpbar.shield)
	l.append(1.0 * agent.number_of_bombs)
	l.append(1.0 * agent.big_bombs)
	l.append(1.0 * agent.landMines)
	l.append(1.0 * agent.c4)
	
	return l #[flatten(map_obs()), posX(player), posY(player), 
	#posX(agent), posY(agent), 
	#agent.hpbar.health, player.hpbar.health, agent.hpbar.shield, player.hpbar.shield, 
	#agent.number_of_bombs, agent.big_bombs, agent.landMines, agent.c4]
	
func update_player_hp(new_hp, new_shiled_hp):
	player_health_reward += new_hp - player_hp
	player_shield_reward += new_shiled_hp - player_shield_hp
	player_hp = new_hp
	player_shield_hp = new_shiled_hp
	
func update_agent_hp(new_hp, new_shiled_hp):
	agent_health_reward += new_hp - player_hp
	agent_shield_reward += new_shiled_hp - agent_shield_hp
	agent_hp = new_hp
	agent_shield_hp = new_shiled_hp

	
func init_obs():
	var obs = []
	for x in GlobalVariables.my_width:
		var lst = []
		for y in GlobalVariables.my_height:
			lst.append([0, 0, 0])
		obs.append(lst)
	return obs
	
# for deliberative agent
func init_matrix():
	var obs = []
	for x in GlobalVariables.my_width:
		var lst = []
		for y in GlobalVariables.my_height:
			lst.append({"walls" : 0, "pickupables" : 0, "spawners" : 0, "bombs" : [], })
		obs.append(lst)
	return obs
	
func get_maze_mat():
	var obs = []
	for x in GlobalVariables.my_width:
		var lst = []
		for y in GlobalVariables.my_height:
			lst.append(0)
		obs.append(lst)
		
	for w in walls: 
		obs[posX(w)][posY(w)] = 1
	
	for p in bombs:
		obs[posX(p)][posY(p)] = 1	
	
	return obs
	
func get_rewards():
	var rewards = [player_health_reward/100,
	player_shield_reward/100,
	agent_health_reward/100,
	agent_shield_reward/100,
	pickup_bombs_reward,
	pickup_xp_reward,
	pickup_hp_reward,
	destroy_walls_reward, 
	weaken_walls_reward/100]
	
	player_health_reward = 0 
	player_shield_reward = 0
	agent_health_reward = 0
	agent_shield_reward = 0
	pickup_bombs_reward = 0
	pickup_xp_reward = 0
	pickup_hp_reward = 0
	destroy_walls_reward = 0
	weaken_walls_reward = 0
	
	return rewards
	
func discretize(p):
	return Vector2(int(p[0]/GlobalVariables.my_scale), int(p[1]/GlobalVariables.my_scale))

func posX(p):
	return int(p.position[0]/GlobalVariables.my_scale)

func posY(p):
	return int(p.position[1]/GlobalVariables.my_scale)
		
func getPlayerHP():
	return player_hp

func getAgentHP():
	return agent_hp
