local PathfindingService = game:GetService("PathfindingService")

local require = require(script.Parent.loader).load(script)

local GeneralUtil = require("GeneralUtil")

local NavigationUtil = {}
NavigationUtil.__index = NavigationUtil

function NavigationUtil.new(npc)
    local self = {}
    setmetatable(self, NavigationUtil)

    self.npc = npc
    self.config = npc.config
    self.character = npc.character

    local configFolder = GeneralUtil:Get("Folder", self.character, "config")
	local configNavigation = GeneralUtil:Get("Configuration", configFolder, "navigation")

    self.isDebug = GeneralUtil:GetBool(configNavigation, "_isDebug", true)
    
    self.config["AgentHeight"] = GeneralUtil:GetNumber(configNavigation, "agentHeight", self.isDebug.Value)
    self.config["AgentCanJump"] = GeneralUtil:GetBool(configNavigation, "agentCanJump", self.isDebug.Value)
    self.config["AgentCanClimb"] = GeneralUtil:GetBool(configNavigation, "agentCanClimb", self.isDebug.Value)
    self.config["AgentRadius"] = GeneralUtil:GetNumber(configNavigation, "agentWidth", self.isDebug.Value)
    self.config["WaypointSpacing"] = GeneralUtil:GetNumber(configNavigation, "waypointSpacing", self.isDebug.Value)

    self.path = PathfindingService:CreatePath({
        AgentRadius = self.npc.config["AgentRadius"].Value/2,
        AgentHeight = self.npc.config["AgentHeight"].Value,
        AgentCanJump = self.npc.config["AgentCanJump"].Value,
        AgentCanClimb = self.npc.config["AgentCanClimb"].Value,
        WaypointSpacing = self.npc.config["WaypointSpacing"].Value,
        Costs = {
            Plastic = 1,
        },
    })
    self.NPCDebug = npc.NPCDebug
    if self.isDebug.Value and self.npc.config.isDebug.Value then
        self.NPCDebug:CreateAgentCylinder("agent", self.npc.root, self.npc.config["AgentRadius"].Value, self.npc.config["AgentHeight"].Value, Color3.fromRGB(255, 255, 0))
    end

    self.waypoints = {}
    self.index = nil
    self.isTargetReached = false
    self.moveConnection = nil

    return self
end

local function IsDistanceInRange(pos1, pos2, range)
	return (pos1 - pos2).Magnitude <= range
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
            task.wait(1)
            print("path re-attempt:" .. tries)
            print("path status: ", path.Status)
        end
        tries+=1
    until isPath or tries > 3

    if not isPath then
        print("No Path Found...")
        return false
    end

    return true
end


function NavigationUtil:Move(targetPosition)

    if not FindPath(self.path, self.npc.root.Position, targetPosition) then
        return false
    end

    self.isTargetReached = false
    self.waypoints = self.path:GetWaypoints()
    self.index = 1

    -- if self.isDebug.Value then
    --     self.NPCDebug:PrintWaypoints(self.waypoints)
    -- end

    if self.moveConnection then
        self.moveConnection:Disconnect()
    end

    self.moveConnection  = self.npc.humanoid.MoveToFinished:Connect(function(reached)
		if self.index < #self.waypoints then
			self.index += 1
			self.npc.humanoid:MoveTo(self.waypoints[self.index].Position)
		elseif self.index == #self.waypoints then
            if self.moveConnection then
                self.moveConnection:Disconnect()
			    self.moveConnection = nil
            end
			self.isTargetReached = true
        end
	end)

    self.npc.humanoid:MoveTo(self.waypoints[self.index].Position)

    return true
end



return NavigationUtil