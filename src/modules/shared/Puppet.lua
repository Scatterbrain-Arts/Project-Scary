local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local BehaviorTreeCreator = require("BehaviorTreeCreator")
local Maid = require("Maid")
local Binder = require("Binder")

local Puppet = {}
Puppet.__index = Puppet
Puppet.TAG_NAME = "Puppet"

local targetLoc = game.Workspace:FindFirstChild("end").Position
local targetHome = game.Workspace:FindFirstChild("home").Position

function Puppet.new(puppetInstance)
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

    self.navigation = {
		path = PathfindingService:CreatePath(),
		waypoints = {},
		currentIndex = nil,
		nextIndex = nil,

		connections = {
			blocked = nil,
			reached = nil,
		}
	}

	self:CreateDebugPart("sight", self.stats.sightRange, Color3.fromRGB(0,255,0))
	self:CreateDebugPart("attack", self.stats.attackRange,  Color3.fromRGB(255,0,0))

	self.btIsRunning = false
	self.btRoot = BehaviorTreeCreator:Create(ServerStorage.BehaviorTrees.MOB_Start)
	self.btState = {
		self = self
	}

	RunService.Stepped:Connect(function(time, deltaTime)
		self.btRoot:Run(self.btState)
	end)


    return self
end


function Puppet:CreateDebugPart(name, size, color)
	local part = Instance.new("Part", self.character)
	part.Shape = Enum.PartType.Ball
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Position = self.root.Position
	part.Transparency = 0.5
	part.CastShadow = false
	part.Name = name
	part.Size = Vector3.new(size*2, size*2, size*2)
	part.Color = color

	local weld = Instance.new("Weld", part)
	weld.Part0 = part
	weld.Part1 = self.root
end


function Puppet:FindPath(targetLocation)
    local success, errorMessage = pcall(function()
        self.navigation.path:ComputeAsync(self.character.PrimaryPart.Position, targetLocation)
    end)

	if not success then
		warn(errorMessage)
		return false
	end

	self.navigation.waypoints = self.navigation.path:GetWaypoints()
	self.navigation.currentIndex = 1
	self.navigation.nextIndex = 2

	return true
end


function Puppet:MoveToNextIndex()
	if self.navigation.path.Status ~= Enum.PathStatus.Success then
		warn("No path found...")
		return
	end

	self.humanoid:MoveTo(self.navigation.waypoints[self.navigation.nextIndex].Position)
end


function Puppet:Attack(target)
	if not target.character then
		warn("Not valid target to attack...")
		return false
	end

	target.Character:FindFirstChild("Humanoid"):TakeDamage(self.stats.attackDamage)

	return true
end



Puppet.BINDER = Binder.new(Puppet.TAG_NAME, Puppet)
Puppet.BINDER:Start()




return Puppet
