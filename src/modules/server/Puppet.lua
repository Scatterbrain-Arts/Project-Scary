local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local BehaviorTreeCreator = require("BehaviorTreeCreator")
local GetRemoteEvent = require("GetRemoteEvent")
local Maid = require("Maid")

local PuppetManuelOverrideEvent = GetRemoteEvent("PuppetManuelOverrideEvent")
local PlayerMoveSoundEvent = GetRemoteEvent("PlayerMoveSoundEvent")

local Puppet = {}
Puppet.__index = Puppet
Puppet.TAG_NAME = "Puppet"
Puppet.STAT_NAMES = {
	agentWidth = "navAgentWidth",
	agentHeight = "navAgentHeight",
	agentCanJump = "navAgentCanJump",
	agentCanClimb = "navAgentCanClimb",
	waypointSpacing = "navWaypointSpacing",

	sightRange = "statSightRange",
	attackRange = "statAttackRange",
	attackDamage = "statAttackDamage",
	attackCooldown = "statAttackCooldown",

	isDebug = "_DEBUG",
	isOverride = "_OVERRIDE"
}


function Puppet.new(puppetInstance, serviceBag)
    local self = {}
    setmetatable(self, Puppet)

	self.maid = Maid.new()

	self.character = puppetInstance
	self.humanoid = puppetInstance:FindFirstChild("Humanoid")
	self.root = puppetInstance:FindFirstChild("HumanoidRootPart")

	

	self.isDebug = self:GetCondition(Puppet.STAT_NAMES.isDebug) or false
	self.DebugService = serviceBag:GetService(require("DebugService"))

	self.manuelOverride =  self:GetCondition(Puppet.STAT_NAMES.isOverride) or false

	self.stats = {
		sightRange = self:GetValue(Puppet.STAT_NAMES.sightRange) or 50,
		attackRange = self:GetValue(Puppet.STAT_NAMES.attackRange) or 10,
		attackDamage = self:GetValue(Puppet.STAT_NAMES.attackDamage) or 25,
		attackCooldown = self:GetValue(Puppet.STAT_NAMES.attackCooldown) or 2,
	}

	self.navigationStats = {
		AgentRadius = (self:GetValue(Puppet.STAT_NAMES.agentWidth) or 4)/2,
		AgentHeight = self:GetValue(Puppet.STAT_NAMES.agentHeight) or 5,
		AgentCanJump = self:GetValue(Puppet.STAT_NAMES.agentCanJump) or false,
		AgentCanClimb = self:GetValue(Puppet.STAT_NAMES.agentCanClimb) or false,
		WaypointSpacing = self:GetValue(Puppet.STAT_NAMES.waypointSpacing) or 4,
		Costs = {
			Plastic = 1,
		}
	}

    self.navigationCurrent = {
		path = PathfindingService:CreatePath(self.navigationStats),
		waypoints = {},
		currentIndex = 1,
		nextIndex = 2,
		description = "current",
	}

	self.navigationNext = {
		path = PathfindingService:CreatePath(self.navigationStats),
		waypoints = {},
		currentIndex = 1,
		nextIndex = 2,
		description = "next",
	}

	self.btRoot = BehaviorTreeCreator:Create(ServerStorage.BehaviorTrees.MOB_Start)
	self.btState = {
		self = self
	}

	RunService.Heartbeat:Connect(function(time, deltaTime)
		if not self.manuelOverride then
			self.btRoot:Run(self.btState)
		end
	end)

	if self.isDebug then
		self.DebugService:CreateRangeIndicator("sight", self.character, self.root, self.stats.sightRange, Color3.fromRGB(0,255,0))
		self.DebugService:CreateRangeIndicator("attack", self.character, self.root, self.stats.attackRange,  Color3.fromRGB(255,0,0))
		self.DebugService:CreateAgentIndicator("agent", self.character, self.root, self.navigationStats.AgentRadius, self.navigationStats.AgentHeight, Color3.fromRGB(255, 255, 0))
	end


	PuppetManuelOverrideEvent.OnServerEvent:Connect(function()
		self.manuelOverride = not self.manuelOverride
		self.character:SetAttribute("ManuelOverride", self.manuelOverride)
		if self.manuelOverride  then
			warn("Manuel Override ENABLED for", self.character.Name, "...")
		elseif self.manuelOverride  == false then
			warn("Manuel Override DISABLED for", self.character.Name, "...")
		end
	end)

	PlayerMoveSoundEvent.OnServerEvent:Connect(function()
		print("heared")
	end)

	self:SetNetworkOwner(nil)

    return self
end

function Puppet:SetNetworkOwner(owner)
	owner = owner or nil
	for _, part in pairs(self.character:GetChildren()) do
		if part:IsA("BasePart") then
			part:SetNetworkOwner(owner)
		end
	end
end


function Puppet:GetValue(attributeName)
	local attribute = self.character:GetAttribute(attributeName)

	if self.isDebug then
		if attribute ~= nil then
			print(string.upper(attributeName), "set to", attribute, "for", self.character.Name, "...")
		else
			warn("Create attribute \"", attributeName, "\"; Using Default value...")
		end
	end

	return attribute
end

function Puppet:GetCondition(attributeName)
	local isAttribute = self.character:GetAttribute(attributeName)
	if isAttribute then
		warn(attributeName, "enabled for", self.character.Name, "...")
	elseif isAttribute == false then
		warn(attributeName, "disabled for", self.character.Name, "...")
	elseif isAttribute == nil then
		warn("Create attribute \"", attributeName , "\" for", self.character.Name, "; Using Default value...")
	end

	return isAttribute
end


function Puppet:FindPath(startLocation, targetLocation, navigation)
    local success, errorMessage = pcall(function()
        navigation.path:ComputeAsync(startLocation, targetLocation)
    end)

	if not success then
		warn(errorMessage)
		return false
	end

	if navigation.path.Status ~= Enum.PathStatus.Success then
		warn(navigation.path.Status)
		return false
	end

	navigation.waypoints = navigation.path:GetWaypoints()
	navigation.currentIndex = 1
	navigation.nextIndex = 2

	if self.isDebug then
		self.DebugService:CreatePathNextIndicator(navigation.waypoints)
	end

	return true
end


function Puppet:MoveToNextIndex(isDrawing)

	if #self.navigationNext.waypoints <= 0 then
		warn("Navigation Next has no path...")
		return false
	end

	self.navigationCurrent.waypoints = self.navigationNext.waypoints
	self.navigationCurrent.currentIndex = self.navigationNext.currentIndex
	self.navigationCurrent.nextIndex = self.navigationNext.nextIndex

	self.humanoid:MoveTo(self.navigationCurrent.waypoints[self.navigationCurrent.nextIndex].Position)

	if isDrawing and self.isDebug then
		self.DebugService:CreatePathCurrentIndicator()
	end

	return true
end


function Puppet:Attack(target)
	if not target.character then
		warn("Not valid target to attack...")
		return false
	end

	target.character:FindFirstChild("Humanoid"):TakeDamage(self.stats.attackDamage)

	return true
end



return Puppet
