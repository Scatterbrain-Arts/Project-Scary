local ServerScriptService = game:GetService("ServerScriptService")
local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.objective.goal ~= shared.npc.states.behavior.alertNames[shared.npc.states.behavior.alert.investigate] or Blackboard.objective.goalCondition then
		warn("objective is not correct...")
		isForceFail = true
		return
	end
	isForceFail = false

	self:LocateSound(Blackboard.lastSoundHeardPosition)

	-- Blackboard.lastSoundHeardRoom = self.navigation:FindRoomFromPosition(Blackboard.lastSoundHeardPosition)

	-- local nearestMap, nearestNode = self.nodeMap:FindNearestMap(Blackboard.lastSoundHeardRoom, Blackboard.lastSoundHeardPosition)
	-- local searchPath = self.nodeMap:FindSearchRoute(nearestMap, nearestNode.Position)

	-- print(searchPath)

	-- for i = #searchPath, 1, -1 do
	-- 	table.insert(Blackboard.searchPath, searchPath[i])
	-- end
	
	-- local foodObject = self:FindFood()
	-- if foodObject then
		-- Blackboard.objective.actionObject = nil
		-- Blackboard.objective.actionPosition = nil
		-- Blackboard.objective.goalRoom = Blackboard.lastSoundHeardRoom
	-- end
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isForceFail then
		return FAIL
	end

	return (Blackboard.searchPath) and SUCCESS or FAIL
end


return btTask
