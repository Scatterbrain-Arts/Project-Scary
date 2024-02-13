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
local NodeMap = require("NodeMap")

local next = next

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

	self.btRoot = BehaviorTreeCreator:Create(ReplicatedStorage.Tree["0_PS_NPC_Start"], self)
	self.btState = {
		self = self,

		Blackboard = {
			-- Junk vars
			defaultWaitTime = 2, --used in waits

			-- player
			player = self.player,

			-- nav
			targetPosition = nil, 	--position to move
			target = nil,			--target to chase/update targetPosition
			collisionGroupRayLoS = "RayNPCLoS",	--ray to see line of sight to target
			isLineOfSight = nil,

			-- sound
			isSoundHeard = false,
			lastSoundHeardPosition = nil,
			lastSoundHeardInstance = nil,
			calmSoundSuspicion = 1,

			-- states
			detectionState = nil, -- states for calm, alert, hostile
			calmBehaviorState = nil, -- behaviors for calm, used just for ref
			alertBehaviorState = nil, -- behaviors for alert, used just for ref

			-- set behavior will loop through all per state until true or error
			behaviorConditions = {
				calm = {
					[shared.npc.states.behavior.calm.investigate] = function()
						return self.btState.Blackboard.isSoundHeard == true
					end,
					[shared.npc.states.behavior.calm.hungry] = function()
						return next(self._objectService:GetType("Food")) ~= nil
					end,
					[shared.npc.states.behavior.calm.patrol] = function()
						return true
					end,
				},

				alert = {
					[shared.npc.states.behavior.alert.investigate] = function()
						return true
					end,
				}
			},

			isObjectiveAlignReached = false,
			isObjectivePositionReached = false,
			isObjectiveRoomReached = false,
			objective = {
				isComplete = false,

				-- nav for Task PathToObject
				walkToInstance = nil, -- action position
				interactObject = nil, --action Object

				-- nav for Task PathToRoom
				goalRoom = nil,
				currentRoom = nil,
				reversePathToGoalRoom = nil,
			},

			
		},
	}

	self.stateUI = self.character.Head.stategui.TextLabel

	self.navigation = Navigation.new(self)
	self.soundDetection = NPCSoundDetection.new(self)
	self.nodeMap = NodeMap.new(self)

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
	self.talismanToCheck = {}
	self.talismanLast = nil

	return self
end

function NPC:InitState()
	
end


function NPC:FindFood()
	local instance, object = next(self._objectService:GetType("Food"))
	return object
end


function NPC:FindTalisman()
	local talismen = self._objectService:GetType("Talisman")
	if not next(self.talismanToCheck) then
		for instance, _ in talismen do
			if instance ~= self.talismanLast then
				table.insert(self.talismanToCheck, instance)
			end
		end
	end

	local rnd = math.random(1, #self.talismanToCheck)
	self.talismanLast = table.remove(self.talismanToCheck, rnd)

	return talismen[self.talismanLast]
end


function NPC:FindPlayer()
	return nil
end


function NPC:LocateSound(lastSoundHeardPosition)
	local partSize = self.soundDetection.navSounds.walkToPosition.PrimaryPart.Size.X
	local walkToPosition = self.navigation:FindWalkablePosition(lastSoundHeardPosition, partSize, partSize*4)
	if not walkToPosition then
		warn("Can't walkable position for sound....")
		return
	end

	self.soundDetection:SetWalkToPosition(lastSoundHeardPosition, walkToPosition)

	return walkToPosition
end



return NPC