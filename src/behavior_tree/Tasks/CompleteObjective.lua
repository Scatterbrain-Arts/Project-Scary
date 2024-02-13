local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3
local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.objective.isComplete then
		warn("Objective is not complete...")
		isForceFail = true
		return
	end

	Blackboard.isObjectiveAlignReached = false
	Blackboard.isObjectivePositionReached = false
	Blackboard.isObjectiveRoomReached = false

	Blackboard.objective.isComplete = false
	Blackboard.objective.interactObject = nil
	Blackboard.objective.walkToInstance = nil
	Blackboard.objective.goalRoom = nil
	Blackboard.objective.currentRoom = nil
	Blackboard.objective.reversePathToGoalRoom = nil
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

	return SUCCESS
end


return btTask
