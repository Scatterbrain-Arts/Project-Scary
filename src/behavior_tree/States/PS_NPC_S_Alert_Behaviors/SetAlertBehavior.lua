local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false
local behaviorState = 1

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	while not Blackboard.behaviorConditions.alert[behaviorState]() do
		if behaviorState+1 > #shared.npc.states.behavior.alertNames then
			isForceFail = true
			return
		end

		behaviorState += 1
	end

	Blackboard.alertBehaviorState = behaviorState
	Blackboard.objective.isComplete = false
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
	
	return Blackboard.behaviorConditions.alert[Blackboard.alertBehaviorState]() and SUCCESS or FAIL
end


return btTask
