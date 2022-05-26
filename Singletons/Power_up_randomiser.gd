extends Node2D

const power_ups = [
	"HPPowerUp",
	"DamagePowerUp",
	"SpeedPowerUp",
	"ShieldPowerUp",
	"MultipleTNTPowerUp",
	"BigBombPowerUp", 
	"LandMinePowerUp",
	"c4PowerUp"
]

func get_random_power_up():
	#var choice = Utils.diracs([0.82, 0.04, 0.03, 0.02, 0.02, 0.02, 0.03, 0.02])
	var choice = Utils.diracs([0.799, 0.04, 0.03, 0.02, 0.02, 0.02, 0.03, 0.02, 0.02])
	if choice == 0:
		return null
	return power_ups[choice-1]
