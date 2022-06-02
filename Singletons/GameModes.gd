extends Node

var singlePlayer: bool
var multiplayer_online: bool
var multiplayer_local: bool

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
