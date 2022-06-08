extends Node
# obs[x][y] = [wall, spawners and pickupables, bombs]
# spawners = 1 
# pickupable = 2, 3, ...

var walls = []
var agent
var player
var pickupables = []
var bombs = []
var spawners = []


var pickupable_classes = [preload("res://Pickupables/BigBombPowerUp.gd"),
preload("res://Pickupables/c4PowerUp.gd"),
preload("res://Pickupables/DamagePowerUp.gd"),
preload("res://Pickupables/HPPowerUp.gd"),
preload("res://Pickupables/LandMinePowerUp.gd"),
preload("res://Pickupables/MultipleTNTPowerUp.gd"),
preload("res://Pickupables/ShieldPowerUp.gd"),
preload("res://Pickupables/SpeedPowerUp.gd")]

var bomb_classes = [preload("res://World/TNT.gd"), 
preload("res://World/BigBomb.gd"),
preload("res://World/LandMine.gd"),
preload("res://World/C4.gd")]

var bomb_encoding = [1000, 100, 10, 1]

func observations():
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
	
func observations_continuous():
	return [observations(), 
	[player.position[0], player.position[1]], 
	[agent.position[0], agent.position[1]]]
	
func observations_discrete():
	return [observations(), 
	[posX(player), posY(player)], 
	[posX(agent), posY(agent)]]
	
func init_obs():
	var obs = []
	for x in GlobalVariables.my_width:
		var lst = []
		for y in GlobalVariables.my_height:
			lst.append([0, 0, 0])
		obs.append(lst)
	return obs
	
func posX(p):
	return int(p.position[0]/GlobalVariables.my_scale)

func posY(p):
	return int(p.position[1]/GlobalVariables.my_scale)
		
