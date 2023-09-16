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

local Puppet = {}
Puppet.__index = Puppet
Puppet.TAG_NAME = "Puppet"

function Puppet.new(puppetInstance, serviceBag)
    local self = {}
    setmetatable(self, Puppet)

	self.character = puppetInstance
	self.humanoid = puppetInstance:FindFirstChild("Humanoid")
	self.root = puppetInstance:FindFirstChild("HumanoidRootPart")

	self.stats = {
		sightRange = 50,
		attackRange = 10,
		attackDamage = 25,
		attackCooldown = 2,
	}

    self.maid = Maid.new()

    self.navigationCurrent = {
		path = PathfindingService:CreatePath(),
		waypoints = {},
		currentIndex = 1,
		nextIndex = 2,
		description = "current",
	}

	self.navigationNext = {
		path = PathfindingService:CreatePath(),
		waypoints = {},
		currentIndex = 1,
		nextIndex = 2,
		description = "next",
	}

	self.manuelOverride = self.character:GetAttribute("ManuelOverride")
	if self.manuelOverride  then
		warn("Manuel Override enabled for", self.character.Name, "...")
	elseif self.manuelOverride  == false then
		warn("Manuel Override disabled for", self.character.Name, "...")
	elseif self.manuelOverride  == nil then
		warn("Create attribute \"ManuelOverride\" to enable overriding for", self.character.Name, "...")
	end

	self.isDebug = self.character:GetAttribute("Debug")
	self.DebugService = serviceBag:GetService(require("DebugService"))
	if self.isDebug then
		warn("Debug enabled for", self.character.Name, "...")
		self.DebugService:CreateRangeIndicator("sight", self.character, self.root, self.stats.sightRange, Color3.fromRGB(0,255,0))
		self.DebugService:CreateRangeIndicator("attack", self.character, self.root, self.stats.attackRange,  Color3.fromRGB(255,0,0))
	elseif self.isDebug == false then
		warn("Debug is disabled for", self.character.Name, "...")
	elseif self.isDebug == nil then
		warn("Create attribute \"Debug\" to enable testing for", self.character.Name, "...")
	end

	self.btRoot = BehaviorTreeCreator:Create(ServerStorage.BehaviorTrees.MOB_Start)
	self.btState = {
		self = self
	}

	RunService.Heartbeat:Connect(function(time, deltaTime)
		if not self.manuelOverride then
			self.btRoot:Run(self.btState)
		end
	end)


	PuppetManuelOverrideEvent.OnServerEvent:Connect(function()
		self.manuelOverride = not self.manuelOverride
		self.character:SetAttribute("ManuelOverride", self.manuelOverride)
		if self.manuelOverride  then
			warn("Manuel Override ENABLED for", self.character.Name, "...")
		elseif self.manuelOverride  == false then
			warn("Manuel Override DISABLED for", self.character.Name, "...")
		end
	end)

    return self
end


function Puppet:FindPath(startLocation, targetLocation, navigation)
    local success, errorMessage = pcall(function()
        navigation.path:ComputeAsync(startLocation, targetLocation)
    end)

	if not success then
		warn(errorMessage)
		return false
	end

	navigation.waypoints = navigation.path:GetWaypoints()
	navigation.currentIndex = 1
	navigation.nextIndex = 2

	if self.isDebug then
		self.DebugService:CreatePathIndicator(navigation.waypoints, navigation.description)
	end

	return true
end


function Puppet:MoveToNextIndex()
	if #self.navigationNext.waypoints > 0 then
		self.navigationCurrent.waypoints = self.navigationNext.waypoints
		self.navigationCurrent.currentIndex = self.navigationNext.currentIndex
		self.navigationCurrent.nextIndex = self.navigationNext.nextIndex
	end

	self.humanoid:MoveTo(self.navigationCurrent.waypoints[self.navigationCurrent.nextIndex].Position)
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
