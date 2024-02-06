local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.isObjectiveRoomReached or not Blackboard.objective or not Blackboard.objective.goal or Blackboard.objective.current then
		warn("Objective is nil or Room is reached...")
		isForceFail = true
		return
	end
	isForceFail = false
	-- print(Blackboard.objective.currentRoom)
	-- print(Blackboard.objective.goalRoom)
	Blackboard.objective.reversePathToGoalRoom = self.navigation:FindShortestPath(Blackboard.objective.currentRoom, Blackboard.objective.goalRoom)
	table.remove(Blackboard.objective.reversePathToGoalRoom, #Blackboard.objective.reversePathToGoalRoom)
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

	return Blackboard.objective.reversePathToGoalRoom and SUCCESS or FAIL
end


return btTask
