local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	Blackboard.isObjectiveRoomReached = Blackboard.objective.currentRoom == Blackboard.objective.goalRoom
	return Blackboard.isObjectiveRoomReached and SUCCESS or FAIL
end


return btTask
