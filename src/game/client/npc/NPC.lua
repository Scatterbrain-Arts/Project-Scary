local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local BehaviorTreeCreator = require("BehaviorTreeCreator")
local Maid = require("Maid")
local ServiceBag = require("ServiceBag")

local NPCDebug = require("NPCDebug")
local GeneralUtil = require("GeneralUtil")
local Navigation = require("Navigation")
local NPCSoundDetection = require("NPCSoundDetection")

local STATE_CALM, STATE_ALERT, STATE_HOSTILE = shared.npc.states.detection.calm, shared.npc.states.detection.alert, shared.npc.states.detection.hostile

local NPC = {}
NPC.__index = NPC
NPC.TAG_NAME = "NPC"

function NPC.new(npcModel, serviceBag)
    local self = {}
    setmetatable(self, NPC)

	assert(ServiceBag.isServiceBag(serviceBag), "Not valid a service bag...")
	self._objectService = serviceBag:GetService(require("ObjectService"))

	self.name = "Pepe"
	self.maid = Maid.new()

	self.character = npcModel or warn("No instance found for ", self.name, "...")
	self.humanoid = npcModel:FindFirstChild("Humanoid") or warn("No humanoid found for", self.name, "...")
	self.root = npcModel:FindFirstChild("HumanoidRootPart") or warn("No root found for", self.name, "...")

	local configFolder = GeneralUtil:Get("Folder", self.character, "config")

	self.config = {
		isDebug = GeneralUtil:GetBool(configFolder, "_DEBUG"),
		isOverride = GeneralUtil:GetBool(configFolder, "_OVERRIDE"),
	}

	if self.config.isDebug.Value then
		self.NPCDebug = NPCDebug.new(self)
	end

	self.player = Players.LocalPlayer
	self.playerCharacter = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	Players.PlayerAdded:Connect(function(player)
		self.player = player
		player.CharacterAdded:Connect(function(character)
			self.playerCharacter = character
		end)
	end)

	self.btRoot = BehaviorTreeCreator:Create(ReplicatedStorage.Tree.PS_NPC_Start, self)
	self.btState = {
		self = self,
		Blackboard = {
			defaultWaitTime = 2,
			player = self.player,
			targetPosition = nil,
			target = nil,
			collisionGroupRayLoS = "RayNPCLoS",
			state = STATE_CALM,
			isSoundHeard = false,
			isTargetLost = nil,
			lastKnownPosition = nil,
			lastKnownRegion = nil,

			isLineOfSight = nil,
			isActive = false,


			--calm behavior
			detectionState = nil,
			calmBehaviorState = nil,

			behaviorStates = {
				calm = {
					[shared.npc.states.behavior.calm.hungry] = false,
					[shared.npc.states.behavior.calm.mourning] = false,
					[shared.npc.states.behavior.calm.angry] = false,
					[shared.npc.states.behavior.calm.patrol] = false,
				},
			},

			objective = {
				goal = "",
				goalRoom = nil,
				currentRoom = nil,
				reversePathToGoalRoom = {},

				goalCondition = nil,
				goalActions = {},

				actionObject = nil,
				actionPosition = nil,
			},

			isActionPositionAligned = false,
			isActionPositionReached = false,
			isObjectiveRoomReached = false
		},
	}

	self.stateUI = self.character.Head.stategui.TextLabel

	self.navigation = Navigation.new(self)
	self.soundDetection = NPCSoundDetection.new(self)

    RunService.Heartbeat:Connect(function(time, deltaTime)
		if not self.config.isOverride.Value then
			self.btRoot:Run(self.btState)
			self.navigation:EndPause()

			if self.config.isDebug.Value then
				self.NPCDebug:UpdateBehaviorTreeIndicator(self.btState.Blackboard.node.Name, false)
			end
		else
			self.navigation:StartPause()
		end
	end)

	self._objectService:AddObject(NPC.TAG_NAME, self, self.character)
	self._objectService:FinishAddObject(NPC.TAG_NAME)

	return self
end


function NPC:FindFood()
	local foodInstance, foodObject = next(self._objectService:GetType("Food"))
	return foodObject
end


function NPC:IsFoodAvailable()
	return next(self._objectService:GetType("Food")) ~= nil
end





return NPC