local PathfindingService = game:GetService("PathfindingService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)
local next = next

local GeneralUtil = require("GeneralUtil")


local Navigation = {}
Navigation.__index = Navigation
Navigation.TAG_NAME = "Room"

local function GetRegions(rooms)
    local regions = {
        rooms = {},
        totalWeight = 0,
    }

    local largestArea = 0
    for index, room in rooms do
        local regionFolder = GeneralUtil:Get("Folder", room.NavMesh, "Region"):GetChildren()

        if #regionFolder ~= 2 then
            error("Region folders must have 2 corner parts...")
        end

        local corner1 = regionFolder[1]
        local corner2 = regionFolder[2]

        local regionData = {}
        regionData.lowerbound = Vector3.new(
            math.min(corner1.Position.X, corner2.Position.X),
            math.min(corner1.Position.Y, corner2.Position.Y),
            math.min(corner1.Position.Z, corner2.Position.Z)
        )
        regionData.upperbound = Vector3.new(
            math.max(corner1.Position.X, corner2.Position.X),
            math.max(corner1.Position.Y, corner2.Position.Y),
            math.max(corner1.Position.Z, corner2.Position.Z)
        )

        regionData.region = Region3.new(regionData.lowerbound, regionData.upperbound)
        regionData.area = regionData.region.Size.X * regionData.region.Size.Z

        if regionData.area > largestArea then
            largestArea = regionData.area
        end

        regions.rooms[room.Name] = regionData
    end

    local totalWeight = 0
    for i, regionData in regions.rooms do
        local ratio = (regionData.area/largestArea) * 10
        regionData.weight = math.floor( math.clamp(ratio, 1, 10) )
        totalWeight += regionData.weight
    end

    regions.totalWeight = totalWeight

    return regions
end

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

    self.regions = GetRegions(CollectionService:GetTagged(Navigation.TAG_NAME))

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




local function ComputePath(path, startPosition, targetPosition)
    local success, errorMessage = pcall(function()
        path:ComputeAsync(startPosition, targetPosition)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        return true
    else
        return false
    end
end


local function FindPath(path, startPosition, targetPosition)
    local tries = 0
    local isPath = false

    repeat
        isPath = ComputePath(path, startPosition, targetPosition)

        if tries >= 1 then
            task.wait()
        end
        tries+=1
    until isPath or tries > 3

    if not isPath then
        print("No Path Found...")
        return false
    end

    return true
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
                    self:Stop()
                end

                self.unstuck.lastPosition = self.root.Position
                self.unstuck.tickLast = tick()
            end
        end
    end)

end


function Navigation:PathTo(targetPosition)
    local rayResult = GeneralUtil:CastSphere(self.root.Position, 4, Vector3.zero, "RayNPC")

    if rayResult then
        print(rayResult.Instance)
    end

    if not FindPath(self.path, self.root.Position, targetPosition) then
        return false
    end

    self.isTargetReached = false
    self.waypoints = self.path:GetWaypoints()
    self.index = 1

    if self.moveConnection then
        self.moveConnection:Disconnect()
    end

    self.moveConnection  = self.humanoid.MoveToFinished:Connect(function(reached)
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
	end)

    self:MoveStart(self.waypoints[self.index].Position)

    return true
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

local Axis8Directions = {
    north = Vector3.new(0, 0, -1), east = Vector3.new(1, 0, 0), northeast = Vector3.new(1, 0, -1), southwest = Vector3.new(-1, 0, 1),
    south = Vector3.new(0, 0, 1), west = Vector3.new(-1, 0, 0), southeast = Vector3.new(1, 0, 1), northwest = Vector3.new(-1, 0, -1),
}

local ThreadLookDirection = coroutine.create(function(npcRoot, targetDirection)
	while true do
        while true do
            local targetCFrame = CFrame.new(npcRoot.Position, npcRoot.Position + targetDirection)
            
            npcRoot.CFrame = npcRoot.CFrame:Lerp(targetCFrame, 0.1)
            if (targetCFrame.LookVector - npcRoot.CFrame.LookVector).Magnitude <= 0.1 then
                break
            end

          -- print(npcRoot.CFrame.LookVector)

            task.wait()
        end
		coroutine.yield()
	end
end)


function Navigation:FaceTo(targetDirection)
    coroutine.resume(ThreadLookDirection, self.root, targetDirection)
end


function Navigation:FindDirectionToFace()
    local partsInRadius = GeneralUtil:QueryRadius(self.root.Position, 8, "RayNPC", false)
    if not partsInRadius then
        return
    end

    local directionScores = {
        north = 0, east = 0,
        south = 0, west = 0,
    }

    for _, part in pairs(partsInRadius) do
        local directionToPart = (part.Position - self.root.Position).Unit
        local angle = math.deg(math.atan2(directionToPart.X, directionToPart.Z))

        angle = angle % 360

        if angle >= 135.6 and angle <= 225.4 then
            directionScores.north += 1

        elseif angle >= 225.6 and angle <= 315.4 then
            directionScores.west += 1

        elseif angle >= 315.6 and angle <= 360 or angle >= 0 and angle <= 45.4 then
            directionScores.south += 1

        elseif angle >= 45.6 and angle <= 135.4 then
            directionScores.east += 1
        end
    end

    local i, v = GeneralUtil:GetConditonFromTable(directionScores, function(a,b) return a > b end)

    print("final direction:", i)

    return Axis8Directions[i]
end


local function GetRandomPointInRegion(regions, currentPos)
    local rnd = math.random() * regions.totalWeight
    local selectedRegion = nil

    local cumulativeWeight = 0
    for index, regionData in regions.rooms do
        cumulativeWeight += regionData.weight

        if rnd <= cumulativeWeight then
            selectedRegion = index
            break
        end
    end

    local regionData = regions.rooms[selectedRegion]
    local point = Vector3.new(
        math.random(regionData.lowerbound.X, regionData.upperbound.X),
        math.random(regionData.lowerbound.Y, regionData.upperbound.Y),
        math.random(regionData.lowerbound.Z, regionData.upperbound.Z)
    )

    -- local part = GeneralUtil:CreatePart(Enum.PartType.Ball, Vector3.new(1,1,1), Color3.fromHex("fa22af"))
    -- part.Position = point
    -- part.Parent = workspace

    return point
end


local function FindRandomPath(regions, path, startPosition)
    local tries = 0
    local isPath = false
    local point = nil

    repeat
        point = GetRandomPointInRegion(regions, startPosition)
        isPath = ComputePath(path, startPosition, point)

        if tries >= 1 then
            task.wait()
        end
        tries+=1
    until isPath or tries > 3

    if not isPath then
        print("No Path Found...")
        return false
    end

    return true
end


function Navigation:PathToRandomPosition()
    local tries = 0
    local point = nil

    if not FindRandomPath(self.regions, self.path, self.root.Position) then
        return false
    end

    self.isTargetReached = false
    self.waypoints = self.path:GetWaypoints()
    self.index = 1

    if self.moveConnection then
        self.moveConnection:Disconnect()
    end

    self.moveConnection  = self.humanoid.MoveToFinished:Connect(function(reached)
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
	end)

    self:MoveStart(self.waypoints[self.index].Position)

    return point
end



return Navigation