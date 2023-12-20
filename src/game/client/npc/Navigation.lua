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
            Plastic = 10,
            NonWalkableSurface = math.huge,
            RoomHallway = 1,
            RoomLarge = 1,
            RoomSmall = 1,
        },
    })

    self.NPCDebug = npc.NPCDebug
    if self.isDebug.Value and self.config.isDebug.Value then
        self.NPCDebug:CreateAgentCylinder("agent", self.root, self.config["AgentRadius"].Value/2, self.config["AgentHeight"].Value, Color3.fromRGB(255, 255, 0))
    end

    self.regions = NavigationUtil:GetRegions(CollectionService:GetTagged(Navigation.TAG_NAME))

    self.waypoints = {}
    self.index = nil
    self.isTargetReached = false
    self.moveConnection = nil
    
    self.unstuck = {
        connection = nil,
        tickLast = tick(),
        tickInterval = 5,
        lastPosition = nil
    }

    return self
end


function Navigation:MoveStart(targetPosition)
    self.humanoid:MoveTo(targetPosition)

    if self.unstuck.connection then
        self.unstuck.connection:Disconnect()
        self.unstuck.connection = nil
    end

    self.unstuck.tickLast = tick()
    self.unstuck.connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.isTargetReached then
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


function Navigation:MoveContinue()
    if self.index < #self.waypoints then
        self.index += 1
        self.humanoid:MoveTo(self.waypoints[self.index].Position)
    elseif self.index == #self.waypoints then
        if self.moveConnection then
            self.moveConnection:Disconnect()
            self.moveConnection = nil
        end
        self.isTargetReached = true
    end
end


-- function Navigation:CheckAction()
--     if self.waypoints[self.index].Label == "Door" then
--         local doorInstance, doorObject = next(Doors.instances)
--         if doorObject.isClosed then

--             self.humanoid:MoveTo(self.root.Position)
--             task.wait(1)
    
--             self.humanoid:MoveTo(doorObject.openPosition)
--             task.wait(2)

--             self.root.CFrame = CFrame.lookAt(self.root.Position, doorObject.model.Position)
--             task.wait(2)
            
--             doorObject:activate()
--             task.wait(2)
--         end
--     end
-- end

function Navigation:PathTo(targetPosition)
    if not NavigationUtil:FindPathToTarget(self.path, self.root.Position, targetPosition) then
        return false
    end

    self.isTargetReached = false
    self.waypoints = self.path:GetWaypoints()
    self.index = 1

    if self.moveConnection then
        self.moveConnection:Disconnect()
    end

    self.moveConnection = self.humanoid.MoveToFinished:Connect(function() self:MoveContinue() end)
    self:MoveStart(self.waypoints[self.index].Position)

    return true
end


function Navigation:PathToRandomPosition()
    local targetPosition = NavigationUtil:FindPathToRandom(self.path, self.root.Position, NavigationUtil.RandomPointAnyRegion, self.regions)

    if not targetPosition then
        return false
    end

    self.isTargetReached = false
    self.waypoints = self.path:GetWaypoints()
    self.index = 1

    if self.moveConnection then
        self.moveConnection:Disconnect()
    end

    self.moveConnection = self.humanoid.MoveToFinished:Connect(function() self:MoveContinue() end)

    self:MoveStart(self.waypoints[self.index].Position)

    return targetPosition
end


function Navigation:PathToRandomPositionInRegion(regionIndex)
    local targetPosition = NavigationUtil:FindPathToRandom(self.path, self.root.Position, NavigationUtil.RandomPointInRegion, self.regions.rooms[regionIndex])

    if not targetPosition then
        return false
    end

    self.isTargetReached = false
    self.waypoints = self.path:GetWaypoints()
    self.index = 1

    if self.moveConnection then
        self.moveConnection:Disconnect()
    end

    self.moveConnection = self.humanoid.MoveToFinished:Connect(function() self:MoveContinue() end)
    self:MoveStart(self.waypoints[self.index].Position)

    return targetPosition
end


function Navigation:MoveTo(targetPosition)
    self.isTargetReached = false

    if self.moveConnection then
        self.moveConnection:Disconnect()
    end

    self.moveConnection = self.humanoid.MoveToFinished:Connect(function(reached)
		if self.moveConnection then
            self.moveConnection:Disconnect()
			self.moveConnection = nil
        end
        self.isTargetReached = true
	end)

    self:MoveStart(targetPosition)

    return true
end


function Navigation:Stop()
    self.humanoid:MoveTo(self.root.Position)

    if self.moveConnection then
        self.moveConnection:Disconnect()
        self.moveConnection = nil
    end

    if self.unstuck.connection then
        self.unstuck.connection:Disconnect()
        self.unstuck.connection = nil
    end

    self.isTargetReached = nil

    return true
end


function Navigation:FindRegionWithPlayer()
    return NavigationUtil:FindRegionWithPart(self.regions.rooms, "RayChar", "CharPlayer")
end


return Navigation