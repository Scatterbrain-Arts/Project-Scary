local PathfindingService = game:GetService("PathfindingService")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")

local AiHelper = require("AiHelper")

local AiComponentBody = {}
AiComponentBody.__index = AiComponentBody

function AiComponentBody.new(entity, serviceBag)
    local self = {}
    setmetatable(self, AiComponentBody)

	self.maid = Maid.new()

	self.entity = entity

	self.entity.config["body"] = {
		navigation = {
			AgentRadius = (AiHelper:GetValue(self.entity.character, "navAgentWidth", self.entity.config["entity"].isDebug) or 4)/2,
			AgentHeight = AiHelper:GetValue(self.entity.character, "navAgentHeight", self.entity.config["entity"].isDebug) or 5,
			AgentCanJump = AiHelper:GetValue(self.entity.character, "navAgentCanJump", self.entity.config["entity"].isDebug) or false,
			AgentCanClimb = AiHelper:GetValue(self.entity.character, "navAgentCanClimb", self.entity.config["entity"].isDebug) or false,
			WaypointSpacing = AiHelper:GetValue(self.entity.character, "navWaypointSpacing", self.entity.config["entity"].isDebug) or 4,
			Costs = {
				Plastic = 1,
			},
		},

		sightRange = AiHelper:GetValue(self.entity.character, "statSightRange",self.entity.config["entity"].isDebug) or 50,
		attackRange = AiHelper:GetValue(self.entity.character, "statAttackRange", self.entity.config["entity"].isDebug) or 10,
		attackDamage = AiHelper:GetValue(self.entity.character, "statAttackDamage", self.entity.config["entity"].isDebug) or 25,
		attackCooldown = AiHelper:GetValue(self.entity.character, "statAttackCooldown", self.entity.config["entity"].isDebug) or 2,
	}

    self.navigation = {
		path = PathfindingService:CreatePath(self.entity.config["body"].navigation),
		waypoints = {},
		currentIndex = 1,
	}


	if self.entity.config["entity"].isDebug then
		
		self.entity.debug:CreateAgentCylinder("agent", self.entity.root, self.entity.config["body"].navigation.AgentRadius,
											self.entity.config["body"].navigation.AgentHeight, Color3.fromRGB(255, 255, 0))
	end

    return self
end



function AiComponentBody:FindPath(startLocation, targetLocation)
    local success, errorMessage = pcall(function()
        self.navigation.path:ComputeAsync(startLocation, targetLocation)
    end)

	if not success then
		warn(errorMessage)
		return false
	end

	if self.navigation.path.Status ~= Enum.PathStatus.Success then
		warn(self.navigation.path.Status)
		return false
	end

	self.navigation.waypoints = self.navigation.path:GetWaypoints()
	self.navigation.currentIndex = 1


	if self.entity.config["entity"].isDebug then
		self.entity.debug:CreatePathCurrent()
	end

	return true
end


function AiComponentBody:MoveToNextIndex()

	if #self.navigation.waypoints <= 0 then
		warn("Navigation has no path...")
		return false
	end

	if self.navigation.waypoints[self.navigation.currentIndex+1] then
		self.entity.humanoid:MoveTo(self.navigation.waypoints[self.navigation.currentIndex].Position)
	end

	return true
end

function AiComponentBody:StopPathing()
	self.maid:DoCleaning()

	self.navigation.waypoints = {}
	self.navigation.currentIndex = 1

	self.entity.humanoid:MoveTo(self.entity.root.Position)
end


function AiComponentBody:Attack()
	if not self.entity.playerHumanoid then
		warn("Not valid target to attack...")
		return false
	end

	self.entity.playerHumanoid:TakeDamage(self.entity.config["body"].attackDamage)

	return true
end



return AiComponentBody
