from godot import exposed, export
from godot import *
import random
from collections import deque
import time

from tensorflow.keras import Model, Sequential
from tensorflow.keras.layers import Dense, Embedding, Reshape
from tensorflow.keras.optimizers import Adam

import numpy as np
import time

batch_size = 25



@exposed
class Autonomous_Agent(Control):
	
	def _ready(self):
		
		self.actions = ["UP", "DOWN", "LEFT", "RIGHT", "STAY", "TNT", "BIG_BOMB", "LAND_MINE", "C4"]
		self.init = False
		
		
		"""self.state_size = len(self.state)
		self.action_size = len(self.actions)
		self.optimizer = Adam(learning_rate=0.01)
		
		self.expirience_replay = deque(maxlen=2000)
		
		# Initialize discount and exploration rate
		self.gamma = 0.6
		self.epsilon = 0.1
		
		# Build networks
		self.q_network = self.build_compile_model()
		self.target_network = self.build_compile_model()
		self.alighn_target_model()"""
		
		
	def _process(self, delta):
		if not self.init:
			self.init = True
			self.state, self.player_obs = self.observations()
			self.state_size = len(self.state)
			self.action_size = len(self.actions)
			self.optimizer = Adam(learning_rate=0.01)
			
			self.expirience_replay = deque(maxlen=2000)
			
			# Initialize discount and exploration rate
			self.gamma = 0.6
			self.epsilon = 0.1
			
			# Build networks
			self.q_network = self.build_compile_model()
			self.target_network = self.build_compile_model()
			self.alighn_target_model()
		
		
		action = self.act(self.state)
		self.perform_action(action)
		
		next_state, next_player_obs = self.observations()
		reward = self.calculate_reward(next_player_obs, self.player_obs) # index 4 and 5 
		self.state = next_state
		
		terminated = False
		self.store(self.state, action, reward, next_state, terminated)
		
		self.state = next_state
		
		if terminated:
			self.alighn_target_model()
			
		if len(self.expirience_replay) > batch_size:
			self.retrain(batch_size)
			self.alighn_target_model()
		
		
		
	def observations(self):
		map = np.array(self.get_parent().world_objects.map_obs()).flatten()
		player = np.array(self.get_parent().world_objects.player_obs_continuous())
		return (np.concatenate([map, player]), player)

	def perform_action(self, a):
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
		elif a >= 5 and a <= 8:
			self.get_parent().place_bomb(self.actions[a])
			
	def calculate_reward(self, next, old):
		return (next[5] - old[5]) + (old[4] - next[4])
			
	
	def store(self, state, action, reward, next_state, terminated):
		self.expirience_replay.append((state, action, reward, next_state, terminated))
		
		
	def build_compile_model(self):
		model = Sequential()
		model.add(Embedding(self.state_size, 10, input_length=1))
		model.add(Reshape((10,)))
		model.add(Dense(50, activation='relu'))
		model.add(Dense(50, activation='relu'))
		model.add(Dense(self.action_size, activation='linear'))
		
		model.compile(loss='mse', optimizer=self.optimizer)
		return model
		
	def alighn_target_model(self):
		self.target_network.set_weights(self.q_network.get_weights())
		
	def act(self, state):
		if np.random.rand() <= self.epsilon:
			return self.actions.sample()

		q_values = self.q_network.predict(state)
		return np.argmax(q_values[0])
		
	def retrain(self, batch_size):
		minibatch = random.sample(self.expirience_replay, batch_size)
		
		for state, action, reward, next_state, terminated in minibatch:
			
			target = self.q_network.predict(state)
			
			if terminated:
				target[0][action] = reward
			else:
				t = self.target_network.predict(next_state)
				target[0][action] = reward + self.gamma * np.amax(t)
			
			self.q_network.fit(state, target, epochs=1, verbose=0)
	
	
