local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local ObjectiveName = "Hungry"


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if self:IsFoodAvailable() then
		Blackboard.objective.goal = ObjectiveName
		Blackboard.objective.goalCondition = false
	end
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
