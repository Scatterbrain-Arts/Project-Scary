local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.objective.interactObject then
		warn("Failed to find food...")
		isForceFail = true
		return
	end

	Blackboard.objective.interactObject:EatObject(self.character.RightHand)
	Blackboard.objective.isComplete = true
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

	return Blackboard.objective.isComplete and SUCCESS or FAIL
end


return btTask
