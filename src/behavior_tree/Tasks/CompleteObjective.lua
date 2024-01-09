local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local ObjectiveName = "Hungry"


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.objective.goalCondition then
		Blackboard.objective.goal = ""
		Blackboard.objective.goalRoom = nil
		Blackboard.objective.currentRoom = nil
		Blackboard.objective.reversePathToGoalRoom = {}
		Blackboard.objective.goalCondition = nil
		Blackboard.objective.actionObject = nil
		Blackboard.objective.actionPosition = nil

		Blackboard.isActionPositionAligned = false
		Blackboard.isActionPositionReached = false
		Blackboard.isObjectiveRoomReached = false
	end
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	return Blackboard.objective.goal == "" and SUCCESS or FAIL
end


return btTask
