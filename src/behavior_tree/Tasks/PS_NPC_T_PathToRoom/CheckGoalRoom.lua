local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.objective.goalRoom then
		warn("Goal Room is nil...")
		isForceFail = true
		return
	end

	Blackboard.objective.currentRoom = self.navigation:FindRegionWithNPC()
	if not Blackboard.objective.currentRoom then
		warn("Current Room is nil...")
		isForceFail = true
		return
	end

	Blackboard.isObjectiveRoomReached = Blackboard.objective.currentRoom == Blackboard.objective.goalRoom
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	isForceFail = false
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isForceFail then
		return FAIL
	end

	return Blackboard.isObjectiveRoomReached and SUCCESS or FAIL
end


return btTask
