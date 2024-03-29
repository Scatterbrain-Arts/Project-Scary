local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.objective.actionObject then
		warn("Failed to find food...")
		isForceFail = true
		return
	end
	isForceFail = false

	Blackboard.objective.actionObject:EatObject(self.character.RightHand)
	Blackboard.objective.goalCondition = true
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

	return Blackboard.objective.goalCondition and SUCCESS or FAIL
end


return btTask
