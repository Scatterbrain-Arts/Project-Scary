local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self


	if Blackboard.behaviorConditions.calm[Blackboard.calmBehaviorState]() then
		Blackboard.objective.goal = shared.npc.states.behavior.calmNames[Blackboard.calmBehaviorState]
		Blackboard.objective.goalCondition = false
	else
		repeat
			Blackboard.calmBehaviorState += 1
		until Blackboard.behaviorConditions.calm[Blackboard.calmBehaviorState]() or Blackboard.calmBehaviorState > #shared.npc.states.behavior.calmNames

		if Blackboard.calmBehaviorState > #shared.npc.states.behavior.calmNames then
			isForceFail = true
			return
		end
		isForceFail = false

		Blackboard.objective.goal = shared.npc.states.behavior.calmNames[Blackboard.calmBehaviorState]
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

	if isForceFail then
		return FAIL
	end

	return Blackboard.behaviorConditions.calm[Blackboard.calmBehaviorState] and SUCCESS or FAIL
end


return btTask
