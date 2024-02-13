local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.isObjectiveRoomReached then
		warn("Room is reached...")
		isForceFail = true
		return
	end

	Blackboard.objective.reversePathToGoalRoom = self.navigation:FindShortestPath(Blackboard.objective.currentRoom, Blackboard.objective.goalRoom)
	if not Blackboard.objective.reversePathToGoalRoom then
		warn("Path To Room is nil...")
		isForceFail = true
		return
	end

	table.remove(Blackboard.objective.reversePathToGoalRoom, #Blackboard.objective.reversePathToGoalRoom)
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

	return Blackboard.objective.reversePathToGoalRoom and SUCCESS or FAIL
end


return btTask
