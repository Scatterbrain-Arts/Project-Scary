local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local navigation = {}
navigation.__index = navigation

local require = require(script.Parent.loader).load(script)
local GeneralUtil = require("GeneralUtil")

function navigation.new(pathData, humanoid)
    local self = {}
    setmetatable(self, navigation)

    self.path = PathfindingService:CreatePath({
        AgentRadius = (pathData.AgentWidth or 4)/2,
        AgentHeight = pathData.AgentHeight or 5,
        AgentCanJump = pathData.AgentCanJump or false,
        AgentCanClimb = pathData.AgentCanClimb or false,
        WaypointSpacing = pathData.WaypointSpacing or 4,
        Costs = pathData.Costs or {Plastic = 1}
    })

    local workspaceFolder = Instance.new("Folder", workspace)
    workspaceFolder.Name = "NavigationDebug"

	self.waypointsFolder = Instance.new("Folder", workspaceFolder)
	self.waypointsFolder.Name = "waypoints"
    self.aiHumanoid = humanoid

    self.waypoints = {}

    return self
end





local function ComputePath(path, startPosition, targetPosition)
    local success, errorMessage = pcall(function()
        path:ComputeAsync(startPosition, targetPosition)
    end)
    if success and path.Status == Enum.PathStatus.Success then
        return true
    else
        print("PathStatus: ", path.Status)
        return false
    end
end


function navigation:FindPath(startPosition, targetPosition)
    local tries = 0
    local hasFoundPath
    self.finalTargetPosition = targetPosition
    repeat
        hasFoundPath = ComputePath(self.path, startPosition, targetPosition)
        
        tries+=1
        print("try to make path" .. tries)
    until hasFoundPath or tries >= 3

    if hasFoundPath then
        self.waypoints = self.path:GetWaypoints()
        self.index = 1
        self:DebugShowWaypoints()
    end
end
local function IsDistanceInRange(pos1, pos2, range)
	return(pos1 - pos2).Magnitude <= range
end

function navigation:MoveToTarget()
    local humanoid = self.aiHumanoid

    if self.targetReached then 
        self.targetReached = false
        return "SUCCESS"
    end
    
    if self.isMoving then
        local playerPosition = Players.LocalPlayer.Character.PrimaryPart.Position
        if IsDistanceInRange(playerPosition, self.finalTargetPosition, 5.0) then
            return "RUNNING"
        else
            self.isMoving = false

            self:FindPath(self.waypoints[self.index].Position, playerPosition)
        end
    end


    
    local targetPosition = self.waypoints[self.index].Position

    self.moveToFinished = humanoid.MoveToFinished:Connect(function(reached)
        print(self.index,#self.waypoints, reached)
        if self.index < #self.waypoints then
            self.index = self.index + 1
            targetPosition = self.waypoints[self.index].Position
            humanoid:MoveTo(targetPosition)
        else
            print("Finished")
            if self.moveToFinished then self.moveToFinished:Disconnect() end
            self.moveToFinished = nil
            self.isMoving = false
            self.targetReached = true
        end
    end)

    humanoid:MoveTo(targetPosition)
    self.isMoving = true
    self.targetReached = false
    return "RUNNING"
end

function navigation:CancelMoveTo()
    print("Cancel")
    if self.moveToFinished then
        print("Disconnect")
        self.moveToFinished:Disconnect()
    end
    self.moveToFinished = nil
    self.isMoving = false
    self.targetReached = false
    self.aiHumanoid:MoveTo(self.aiHumanoid.RootPart.Position)
end

function navigation:MoveToIndex(index)

end

function navigation:DebugShowWaypoints()
    for _, waypointPart in pairs(self.waypointsFolder:GetChildren()) do
        waypointPart:Destroy()
    end

    for index, waypoint in self.waypoints do
		local sphere = GeneralUtil:CreatePart(Enum.PartType.Ball, Vector3.new(0.5, 0.5, 0.5), Color3.fromHex("006969"))
		sphere.Material = Enum.Material.Neon
		sphere.Name = index
		sphere.Parent = self.waypointsFolder
		sphere.Position = Vector3.new(waypoint.Position.X, waypoint.Position.Y + 0.5, waypoint.Position.Z)
	end
end

return navigation