local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false
local behaviorState = 1

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	print("testing", shared.npc.states.behavior.calmNames[behaviorState])
	

	while not Blackboard.behaviorConditions.calm[behaviorState]() do
		print(shared.npc.states.behavior.calmNames[behaviorState], " Failed...")
		if behaviorState+1 > #shared.npc.states.behavior.calmNames then
			warn("CalmBehaviors is out of bounds...")
			isForceFail = true
			return
		end

		behaviorState += 1
	end

	print(shared.npc.states.behavior.calmNames[behaviorState], "passed...")

	Blackboard.calmBehaviorState = behaviorState
	Blackboard.objective.isComplete = false
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	behaviorState = 1
	isForceFail = false

	print("status", status)
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isForceFail then
		return FAIL
	end

	return Blackboard.behaviorConditions.calm[Blackboard.calmBehaviorState]() and SUCCESS or FAIL
end


return btTask
