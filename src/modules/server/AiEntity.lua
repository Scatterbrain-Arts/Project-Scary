local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local BehaviorTreeCreator = require("BehaviorTreeCreator")
local GetRemoteEvent = require("GetRemoteEvent")
local Maid = require("Maid")

local AiDebug = require("AiDebug")
local AiHelper = require("AiHelper")
local AiComponentBody = require("AiComponentBody")
local AiComponentMind = require("AiComponentMind")
local AiComponentSoul = require("AiComponentSoul")

local PuppetManuelOverrideEvent = GetRemoteEvent("PuppetManuelOverrideEvent")

local AiEntity = {}
AiEntity.__index = AiEntity
AiEntity.TAG_NAME = "Entity"

function AiEntity.new(aiInstance, serviceBag)
    local self = {}
    setmetatable(self, AiEntity)

	self.name = "Pepe"
	self.maid = Maid.new()

	self.character = aiInstance or warn("No instance found for ", self.name, "...")
	self.humanoid = aiInstance:FindFirstChild("Humanoid") or warn("No humanoid found for", self.name, "...")
	self.root = aiInstance:FindFirstChild("HumanoidRootPart") or warn("No root found for", self.name, "...")

	self.config = {
		["entity"] = {
			isDebug = AiHelper:GetCondition(self.character, "_DEBUG") or false,
			isOverride = AiHelper:GetCondition(self.character, "_OVERRIDE") or false,
		},
	}

	if self.config["entity"].isDebug then
		self.debug = AiDebug.new(self, true)
	end

	self.body = AiComponentBody.new(self, serviceBag)
	self.mind = AiComponentMind.new(self, serviceBag)
	self.soul = AiComponentSoul.new(self, serviceBag)

	AiHelper:SetNetworkOwner(self.character, nil)


	self.btRoot = BehaviorTreeCreator:Create(ServerStorage.BehaviorTrees.MOB_Start, self)
	self.btState = {
		self = self,
		Blackboard = {
			target = {}
		},
	}

    RunService.Heartbeat:Connect(function(time, deltaTime)
		if not self.config["entity"].isOverride then
			self.btRoot:Run(self.btState)

			if self.config["entity"].isDebug then
				self.debug:UpdateBehaviorTreeIndicator(self.btState.Blackboard.node.Name)
			end
		end
	end)

	PuppetManuelOverrideEvent.OnServerEvent:Connect(function()
		self.config["entity"].isOverride = not self.config["entity"].isOverride

		self.character:SetAttribute("_OVERRIDE", self.config["entity"].isOverride)
		if self.config["entity"].isOverride then
			warn("Manuel Override ENABLED for", self.name, "...")
		elseif self.config["entity"].isOverride == false then
			warn("Manuel Override DISABLED for", self.name, "...")
		end
	end)

	return self
end



return AiEntity