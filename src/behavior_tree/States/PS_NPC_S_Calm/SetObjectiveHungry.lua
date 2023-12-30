local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local ObjectiveName = "Hungry"


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	Blackboard.objective.goal = ObjectiveName
	--TODo: default condition is complete all actions once
	Blackboard.objective.goalCondition = nil
	Blackboard.objective.goalActions = { "Think", "Search For Object", "Eat" }
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	return Blackboard.objective.goal == ObjectiveName and SUCCESS or FAIL
end


return btTask
