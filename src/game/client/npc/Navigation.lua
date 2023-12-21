local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)
local next = next

local GeneralUtil = require("GeneralUtil")
local NavigationUtil = require("NavigationUtil")
local Doors = require("Doors")

local Navigation = {}
Navigation.__index = Navigation
Navigation.TAG_NAME = "Room"

function Navigation.new(npc)
    local self = {}
    setmetatable(self, Navigation)

    self.npc = npc
    self.config = npc.config
    self.character = npc.character
    self.humanoid = npc.humanoid
    self.root = npc.root

    local configFolder = GeneralUtil:Get("Folder", self.character, "config")
	local configNavigation = GeneralUtil:Get("Configuration", configFolder, "navigation")

    self.isDebug = GeneralUtil:GetBool(configNavigation, "_isDebug", true)

    self.config["AgentHeight"] = GeneralUtil:GetNumber(configNavigation, "agentHeight", self.isDebug.Value)
    self.config["AgentCanJump"] = GeneralUtil:GetBool(configNavigation, "agentCanJump", self.isDebug.Value)
    self.config["AgentCanClimb"] = GeneralUtil:GetBool(configNavigation, "agentCanClimb", self.isDebug.Value)
    self.config["AgentRadius"] = GeneralUtil:GetNumber(configNavigation, "agentWidth", self.isDebug.Value)
    self.config["WaypointSpacing"] = GeneralUtil:GetNumber(configNavigation, "waypointSpacing", self.isDebug.Value)

    self.path = PathfindingService:CreatePath({
        AgentRadius = self.config["AgentRadius"].Value/2,
        AgentHeight = self.config["AgentHeight"].Value,
        AgentCanJump = self.config["AgentCanJump"].Value,
        AgentCanClimb = self.config["AgentCanClimb"].Value,
        WaypointSpacing = self.config["WaypointSpacing"].Value,
        Costs = {
            NonWalkableSurface = math.huge,
            Hallway = 1,
            Large = 1,
            Small = 1,
        },
    })

    self.NPCDebug = npc.NPCDebug
    if self.isDebug.Value and self.config.isDebug.Value then
        self.NPCDebug:CreateAgentCylinder("agent", self.root, self.config["AgentRadius"].Value/2, self.config["AgentHeight"].Value, Color3.fromRGB(255, 255, 0))
    end

    self.regions = NavigationUtil:GetRegions(CollectionService:GetTagged(Navigation.TAG_NAME))

    self.move = {
        index = nil,
        waypoints = {},
        connection = nil,
        targetPosition = nil,
        isTargetReached = false,
    }

    self.action = {
        index = nil,
        waypoints = {},
        connection = nil,
        targetPosition = nil,
        isTargetReached = false,
    }

    self.unstuck = {
        lastPosition = nil,
        tickLast = tick(),
        tickInterval = 5,
        connection = nil,
    }

    return self
end


function Navigation:StartUnstuckService()
    NavigationUtil:EndService(self.unstuck)

    self.unstuck.tickLast = tick()
    self.unstuck.connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.move.isTargetReached then
            if tick() - self.unstuck.tickLast >= self.unstuck.tickInterval then

                if self.unstuck.lastPosition and GeneralUtil:IsDistanceLess(self.unstuck.lastPosition, self.root.Position, 2) then
                    warn("stuck")
                    self.npc.stateUI.Text = ">||"
                    self:Stop()
                end

                self.unstuck.lastPosition = self.root.Position
                self.unstuck.tickLast = tick()
            end
        end
    end)
end


function Navigation:StartPathing()
    NavigationUtil:EndService(self.move)

    self.move.connection = self.humanoid.MoveToFinished:Connect(function()
        if self.move.index < #self.move.waypoints then
            self.move.index += 1

            local nextWaypoint = self.move.waypoints[self.move.index]
            if nextWaypoint.Action == Enum.PathWaypointAction.Custom and nextWaypoint.Label == "Door" then
                local _, doorObject = GeneralUtil:GetConditonFromTable(Doors.instances, function(a, b)
                    return type(a) ~= "table" and true or GeneralUtil:GetDistance(self.root.Position, a.position) > GeneralUtil:GetDistance(self.root.Position, b.position)
                end)

                if doorObject.isClosed then
                    self:StartPause()
                    doorObject:activate()
                    task.wait(1)
                    self:EndPause()
                end

                NavigationUtil:EndService(self.move)
                self.move.connection = self.humanoid.MoveToFinished:Connect(function()
                    self:PathToTarget(self.move.targetPosition)
                end)
            end
            self.humanoid:MoveTo(nextWaypoint.Position)

        elseif self.move.index == #self.move.waypoints then
            NavigationUtil:EndService(self.move)
            NavigationUtil:EndService(self.unstuck)
            self.move.isTargetReached = true
        end
    end)

    self.humanoid:MoveTo(self.move.waypoints[self.move.index].Position)
end


function Navigation:StartMoving()
    NavigationUtil:EndService(self.move)

    self.move.connection = self.humanoid.MoveToFinished:Connect(function(reached)
		NavigationUtil:EndService(self.move)
        NavigationUtil:EndService(self.unstuck)
        self.move.isTargetReached = true
	end)

    self.humanoid:MoveTo(self.move.waypoints[self.move.index].Position)
end


function Navigation:Stop()
    NavigationUtil:EndService(self.move)
    NavigationUtil:EndService(self.unstuck)

    self.humanoid:MoveTo(self.root.Position)
    self.move.isTargetReached = nil

    return true
end


function Navigation:StartPause()
    self.walkSpeed = self.humanoid.WalkSpeed
    self.humanoid.WalkSpeed = 0
end


function Navigation:EndPause()
    self.humanoid.WalkSpeed = self.walkSpeed
end


function Navigation:PathToTarget(targetPosition)
    if not NavigationUtil:FindPath(self.path, self.root.Position, targetPosition) then
        return false
    end

    self.move.targetPosition = targetPosition
    self.move.isTargetReached = false
    self.move.waypoints = self.path:GetWaypoints()
    self.move.index = 1

    self:StartUnstuckService()
    self:StartPathing()

    return true
end


function Navigation:PathToRandomTarget()
    local targetPosition = NavigationUtil:FindPathRandom(self.path, self.root.Position, NavigationUtil.RandomPointAnyRegion, self.regions)

    if not targetPosition then
        return false
    end

    self.move.targetPosition = targetPosition
    self.move.isTargetReached = false
    self.move.waypoints = self.path:GetWaypoints()
    self.move.index = 1

    self:StartUnstuckService()
    self:StartPathing()

    return targetPosition
end


function Navigation:PathToRandomTargetInRegion(regionIndex)
    local targetPosition = NavigationUtil:FindPathRandom(self.path, self.root.Position, NavigationUtil.RandomPointInRegion, self.regions.rooms[regionIndex])

    if not targetPosition then
        return false
    end

    self.move.targetPosition = targetPosition
    self.move.isTargetReached = false
    self.move.waypoints = self.path:GetWaypoints()
    self.move.index = 1

    self:StartUnstuckService()
    self:StartPathing()

    return targetPosition
end


function Navigation:MoveToTarget(targetPosition)
    self.move.targetPosition = targetPosition
    self.move.isTargetReached = false
    self.move.waypoints = nil
    self.move.index = nil

    self:StartUnstuckService()
    self:StartMoving()

    return true
end


function Navigation:FindRegionWithPlayer()
    return NavigationUtil:FindRegionWithPart(self.regions.rooms, "RayChar", "CharPlayer")
end


return Navigation