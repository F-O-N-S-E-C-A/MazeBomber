extends Node

const agent_classes = [
preload("res://Autonomous_Agent/deliberative_agent/deliberative_agent.gd")]

var singlePlayer: bool
var multiplayer_online: bool
var multiplayer_local: bool

var agent
var agentSprite

var dead_players = []
var players = []

func multiplayer_online():
	singlePlayer = false
	multiplayer_online = true
	multiplayer_local = false

func multiplayer_local():
	singlePlayer = false
	multiplayer_online = false
	multiplayer_local = true

func singleplayer():
	singlePlayer = true
	multiplayer_online = false
	multiplayer_local = false

func menu():
	singlePlayer = false
	multiplayer_online = false
	multiplayer_local = false

func is_an_agent(var body):
	if singlePlayer:
		for a in agent_classes:
			if body is a:
				return true
	return false
	
func addDeath(player):
	dead_players.append(player)

func winner():
	for p in players:
		if not dead_players.has(p):
			return p
			
func game_is_over():
	var c = 0
	for p in players:
		if not dead_players.has(p):
			c += 1
	if c <= 1:
		return true 
	return false
