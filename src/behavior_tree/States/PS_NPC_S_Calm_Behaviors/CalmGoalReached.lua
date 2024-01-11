local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


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

	return (Blackboard.objective.goal == shared.npc.states.behavior.calmNames[Blackboard.calmBehaviorState] and Blackboard.objective.goalCondition) and SUCCESS or FAIL
end


return btTask
