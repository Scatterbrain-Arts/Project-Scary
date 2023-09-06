local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")

local require = require(script.Parent.loader).load(script)

local Maid = require("Maid")
local Binder = require("Binder")

local Puppet = {}
Puppet.__index = Puppet
Puppet.TAG_NAME = "Puppet"

local targetLoc = game.workspace:FindFirstChild("end").Position

function Puppet.new(puppetInstance)
    local self = {}
    setmetatable(self, Puppet)

	self.character = puppetInstance
	self.humanoid = puppetInstance:FindFirstChild("Humanoid")

    self.maid = Maid.new()

    self.path = PathfindingService:CreatePath()
	self.waypoints = {
		list = {},
		currentIndex = nil,
		nextIndex = nil,
		blockedConnection = nil,
		reachedConnection = nil,
	}

	self:FindPath(targetLoc)

    return self
end

local function OnIndexBlocked(blockedIndex, self, targetLocation)
	if blockedIndex >= self.waypoints.nextIndex then
		self.waypoints.blockedConnection:Disconnect()
		self:FindPath(targetLocation)
	end
end

local function OnIndexReached(reachedIndex, self)
	if reachedIndex and self.waypoints.nextIndex < #self.waypoints.list then
		self.waypoints.nextIndex += 1
		self.humanoid:MoveTo(self.waypoints.list[self.waypoints.nextIndex].Position)
	else
		self.waypoints.reachedConnection:Disconnect()
	end
end

function Puppet:FindPath(targetLocation)
    -- Compute the path
    local success, errorMessage = pcall(function()
        self.path:ComputeAsync(self.character.PrimaryPart.Position, targetLocation)
    end)

	if not success then
		error(errorMessage)
	end

	if self.path.Status == Enum.PathStatus.Success or self.path.Status == Enum.PathStatus.ClosestNoPath then
		self.waypoints.list = self.path:GetWaypoints()
		self.waypoints.blockedConnection = self.path.Blocked:Connect(function(blockedIndex) OnIndexBlocked(blockedIndex, self, targetLoc) end)
	end

	if not self.waypoints.reachedConnection then
		self.waypoints.reachedConnection = self.humanoid.MoveToFinished:Connect(function(reachedIndex) OnIndexReached(reachedIndex, self) end)

		self.waypoints.nextIndex = 2
		self.humanoid:MoveTo(self.waypoints.list[self.waypoints.nextIndex].Position)
	end

	

	-- 	-- Detect when movement to next waypoint is complete
	-- 	if not reachedConnection then
	-- 		reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
	-- 			if reached and nextWaypointIndex < #waypoints then
	-- 				-- Increase waypoint index and move to next waypoint
	-- 				nextWaypointIndex += 1
	-- 				humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
	-- 			else
	-- 				reachedConnection:Disconnect()
	-- 				blockedConnection:Disconnect()
	-- 			end
	-- 		end)
	-- 	end

	-- 	-- Initially move to second waypoint (first waypoint is path start; skip it)
	-- 	nextWaypointIndex = 2
	-- 	humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
	-- else
	-- 	warn("Path not computed!", errorMessage)
	-- end
end

Puppet.BINDER = Binder.new(Puppet.TAG_NAME, Puppet)
Puppet.BINDER:Start()

return Puppet
