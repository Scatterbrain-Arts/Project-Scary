local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	while not Blackboard.behaviorConditions.alert[Blackboard.alertBehaviorState]() do
		if Blackboard.alertBehaviorState+1 > #shared.npc.states.behavior.alertNames then
			isForceFail = true
			return
		end
		isForceFail = false

		Blackboard.alertBehaviorState += 1
	end

	Blackboard.objective.goal = shared.npc.states.behavior.alertNames[Blackboard.alertBehaviorState]
	Blackboard.objective.goalCondition = false
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

	return Blackboard.behaviorConditions.alert[Blackboard.alertBehaviorState] and SUCCESS or FAIL
end


return btTask
