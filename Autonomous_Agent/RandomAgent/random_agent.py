from godot import exposed, export
from godot import *
import random
from collections import deque
import time

import numpy as np


@exposed
class Autonomous_Agent(Control):
	def getYSort(self):
		self.nodes = self.YSort.get_children()
		self.sortedNodes = sorted(self.nodes, key = lambda n: (n.position.x, n.position.y))
	
	def randAction(self):
		randAction = random.randint(1,5)
		if randAction == 1:
			self.agent.move("UP")
		if randAction == 2:
			self.agent.move("RIGHT")
		if randAction == 3:
			self.agent.move("DOWN")
		if randAction == 4:
			self.agent.move("LEFT")
		if randAction == 5:
			self.agent.move("STOP")
			
	def randBomb(self):
		randBomb = random.randint(1,5)
		if randBomb == 1:
			self.agent.place_bomb("TNT")
		if randBomb == 2:
			self.agent.place_bomb("BIG_BOMB")
		if randBomb == 3:
			self.agent.place_bomb("LAND_MINE")
		if randBomb == 4:
			self.agent.place_bomb("C4")
	
	def _ready(self):
		self.worldObjects = self.get_parent().get_worldObjects()
		self.agent = self.get_parent()
		self.nextMoveTime = random.randint(0,5)
		self.nextBombTime = random.randint(0,5)
		self.moveTimer = 0
		self.bombTimer = 0

	def  _process(self, delta):
		self.moveTimer = self.moveTimer + delta # Timer to change direction
		self.bombTimer = self.bombTimer + delta # Timer to try to drop bomb
		
		if self.moveTimer >= self.nextMoveTime: # If timer done, change direction 
			self.randAction()
			self.nextMoveTime = random.randint(0,5)
			self.moveTimer = 0

		if self.bombTimer >= self.nextBombTime: # If timer done, try to drop bomb 
			self.randBomb()
			self.nextBombTime = random.randint(0,5)
			self.bombTimer = 0
