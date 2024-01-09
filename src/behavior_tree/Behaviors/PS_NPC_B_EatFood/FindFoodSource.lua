local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	-- TODO: heuristic to choose from list of room with food

	local foodObject = self:FindFood()
	if foodObject then
		Blackboard.objective.actionObject = foodObject
		Blackboard.objective.actionPosition = foodObject.navStart
		Blackboard.objective.goalRoom = foodObject.room
		Blackboard.objective.currentRoom = self.navigation:FindRegionWithNPC()
	end

	if not Blackboard.objective.currentRoom or not Blackboard.objective.goalRoom then
		warn("Failed to find food...")
		isForceFail = true
		return
	end
	isForceFail = false
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

	return Blackboard.isObjectiveRoomReached ~= nil and SUCCESS or FAIL
end


return btTask
