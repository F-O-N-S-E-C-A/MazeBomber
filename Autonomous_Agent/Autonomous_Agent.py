from godot import exposed, export
from godot import *
import random
from collections import deque
import time

from tensorflow.keras import Model, Sequential
from tensorflow.keras.layers import Dense, Embedding, Reshape
from tensorflow.keras.optimizers import Adam

import numpy as np

@exposed
class Autonomous_Agent(Control):
	def getYSort(self):
		self.nodes = self.YSort.get_children()
		self.sortedNodes = sorted(self.nodes, key = lambda n: (n.position.x, n.position.y))
	
	def _ready(self):
		self.lastState = np.array([[16,16]])
		self.lastAction = 4
		self.get_parent().model = True
		self.state_size = 2 #position
		self.action_size = 5 #movement
		self.optimizer = Adam(learning_rate=0.01)
		self.expirience_replay = deque(maxlen=2000)
		self.gamma = 0.6
		self.epsilon = 0.1
		self.action_space = ["UP", "DOWN", "LEFT", "RIGHT", "STOP"]

		self.q_network = self._build_compile_model()
		self.target_network = self._build_compile_model()
		self.alighn_target_model()

		self.world = self.owner.get_parent().owner
		self.mazeGenerator = self.world.get_child(1)
		self.YSort = self.mazeGenerator.get_child(1)
		print(self)

	def  _process(self, delta):
		#1 - send input
		#2 - receive action
		#3 - repeat
		
		#self.getYSort()
		#for node in self.sortedNodes:
		#	if "Wall" in str(node.get_name()):
		#		if node.position.x == 16 and node.position.y == 48:
		#			node.visible = not node.visible
		state = np.array([[self.get_parent().position.x, self.get_parent().position.y]])
		a = self.act(state)
		
		if a == 0:
			self.get_parent().setVec(0, -1)
		elif a == 1:
			self.get_parent().setVec(0, 1)
		elif a == 2:
			self.get_parent().setVec(-1, 0)
		elif a == 3:
			self.get_parent().setVec(1, 0)
		elif a == 4:
			self.get_parent().setVec(0, 0)
		
		reward = np.linalg.norm(state[0]-self.lastState[0])
		print(reward)
		self.store(self.lastState, self.lastAction, reward, state)
		
		self.retrain(len(self.expirience_replay) % 2)
		self.lastState = state
		self.lastAction = a
		
	
	def _build_compile_model(self):
		model = Sequential()
		model.add(Dense(100, activation='relu', input_dim=self.state_size))
		model.add(Dense(100, activation='relu'))
		model.add(Dense(100, activation='relu'))
		model.add(Dense(self.action_size, activation='linear'))

		model.compile(loss='mse', optimizer=self.optimizer)
		return model
	
	def store(self, state, action, reward, next_state):
		self.expirience_replay.append((state, action, reward, next_state))
	
	def alighn_target_model(self):
		self.target_network.set_weights(self.q_network.get_weights())
		
	def act(self, state):
		if np.random.rand() <= self.epsilon:
			return random.randint(0, len(self.action_space)-1)

		q_values = self.q_network.predict(state, verbose = 0)
		return np.argmax(q_values[0])
		
	def retrain(self, batch_size):
		minibatch = random.sample(self.expirience_replay, batch_size)
		
		for state, action, reward, next_state in minibatch:
			target = self.q_network.predict(state, verbose = 0)

			t = self.target_network.predict(next_state, verbose = 0)
			target[0][action] = reward + self.gamma * np.amax(t)
				
			self.q_network.fit(state, target, epochs=1, verbose=0)
