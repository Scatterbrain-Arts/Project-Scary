local PathfindingService = game:GetService("PathfindingService")
local navigation = {}
navigation.__index = navigation

local require = require(script.Parent.loader).load(script)
local GeneralUtil = require("GeneralUtil")

function navigation.new(pathData)
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
        print("Success: " .. " PathStatus: " .. path.Status)
        return false
    end
end


function navigation:FindPath(startPosition, targetPosition)
    local tries = 0
    repeat
        local hasFoundPath = ComputePath(self.path, startPosition, targetPosition)
        
        tries+=1
        print("try " .. tries)

        task.wait(1)
    until hasFoundPath

    self.waypoints = self.path:GetWaypoints()
    self:DebugShowWaypoints()
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