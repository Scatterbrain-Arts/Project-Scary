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
	--self.root = puppetInstance:FindFirstChild("HumanoidRootPart")

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

	self.btIsRunning = false
	self.btRoot = BehaviorTreeCreator:Create(ServerStorage.BehaviorTrees.MOB_Start)
	self.btState = {
		MOB = self
	}

	RunService.Stepped:Connect(function(time, deltaTime)
		if self.btIsRunning then return end
		local result = self.btRoot:Run(self.btState)
		self.btIsRunning = (result == 3)
	end)


    return self
end

-- local function OnIndexBlocked(blockedIndex, self, targetLocation)
-- 	if blockedIndex >= self.navigation.nextIndex then
-- 		self.navigation.connections.blocked:Disconnect()
-- 		self:FindPath(targetLocation)
-- 	end
-- end

local function OnIndexReached(reachedIndex, self)
	if not reachedIndex then
		error("reachedIndex is nil...")
	end

	print("currentIndex" .. self.navigation.currentIndex)
	print("nextIndex" .. self.navigation.nextIndex)
	print("reachedIndex: " .. reachedIndex)

	self.navigation.currentIndex = reachedIndex
	if self.navigation.nextIndex < #self.navigation.waypoints then
		self.navigation.nextIndex += 1
	end

	self.navigation.connections.reached:Disconnect()
end


function Puppet:FindPath(targetLocation)
    -- Compute the path
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

	

	-- print("MOVETO: currentIndex " .. self.navigation.currentIndex)
	-- print("MOVETO: nextIndex " .. self.navigation.nextIndex)
	self.humanoid:MoveTo(self.navigation.waypoints[self.navigation.nextIndex].Position)
	--self.navigation.running = true
	-- self.navigation.connections.reached = self.humanoid.MoveToFinished:Connect(function(reachedIndex)
	-- 	if not reachedIndex then
	-- 		error("reachedIndex is ...")
	-- 	end

		
	-- 	print("REACHED: " .. self.navigation.nextIndex)

	-- 	self.navigation.currentIndex = self.navigation.nextIndex
	-- 	if self.navigation.nextIndex < #self.navigation.waypoints then
	-- 		self.navigation.nextIndex += 1
	-- 		--self.navigation.running = true
	-- 		self:MoveToNextIndex()
	-- 	else
	-- 		--self.navigation.running = false
	-- 		self.navigation.connections.reached:Disconnect()
	-- 	end
	-- end)
end


Puppet.BINDER = Binder.new(Puppet.TAG_NAME, Puppet)
Puppet.BINDER:Start()




return Puppet
