from godot import exposed, export
from godot import *
import random
from collections import deque
import time
import sys
import math 

import numpy as np


@exposed
class Autonomous_Agent(Control):
	def init(self):
		pass
	def getYSort(self):
		self.nodes = self.YSort.get_children()
		self.sortedNodes = sorted(self.nodes, key = lambda n: (n.position.x, n.position.y))
			
	def randLocation(self):
		g = 20
		
		if self.agent.get_number_of_bombs() <= 0 and random.randint(0,10) == 1:
			MinDist = Vector2(sys.maxsize, sys.maxsize)
			for i in self.worldObjects.spawners:
				if not i.boomBoxHere:
					continue
				checkDistanceX = i.position.x - self.agent.position.x
				checkDistanceY = i.position.y - self.agent.position.y
				currentDistanceX = MinDist.x - self.agent.position.x
				currentDistanceY = MinDist.y - self.agent.position.y
				if math.sqrt(checkDistanceX*checkDistanceX + checkDistanceY*checkDistanceY) < math.sqrt(currentDistanceX*currentDistanceX + currentDistanceY*currentDistanceY):
					MinDist = i.position
			self.destination = self.worldObjects.discretize(MinDist)
			return
		
		while g >= 20:
			self.destination = Vector2(random.randint(self.worldObjects.discretize(self.agent.position).x - 5,self.worldObjects.discretize(self.agent.position).x + 5), random.randint(self.worldObjects.discretize(self.agent.position).y - 5,self.worldObjects.discretize(self.agent.position).x + 5))
			g = self.agent.distance_to(self.destination)
			if self.agent.go_to(self.destination) == 0:
				g = 20
		# DEBUG
		#self.agent.go_to(self.destination)
		#self.worldObjects.player.position = self.destination * self.globalVariables.my_scale # DELETE LATER DEBUG
		
		
	def randBomb(self):
		randBomb = random.randint(1,10)
		if randBomb <= 7:
			self.agent.place_bomb("TNT")
		if randBomb == 8:
			self.agent.place_bomb("BIG_BOMB")
		if randBomb == 9:
			self.agent.place_bomb("LAND_MINE")
		if randBomb == 10:
			self.agent.place_bomb("C4")
	
	def _ready(self):
		self.worldObjects = self.get_parent().get_worldObjects()
		self.globalVariables = self.get_parent().get_globalVariables()
		self.agent = self.get_parent()
		self.nextBombTime = random.randint(0,5)
		self.bombTimer = 0
		self.destination = Vector2(1,1)

	def  _process(self, delta):
		self.bombTimer = self.bombTimer + delta # Timer to try to drop bomb
		
		self.agent.go_to(self.destination)
		
		if(self.worldObjects.discretize(self.agent.position) == self.destination):
			self.randLocation()

		if self.bombTimer >= self.nextBombTime or self.agent.distance_to(self.worldObjects.discretize(self.agent.opponent.position)) <= 5: # If timer done, try to drop bomb 
			self.randBomb()
			self.nextBombTime = random.randint(0,5)
			self.bombTimer = 0
