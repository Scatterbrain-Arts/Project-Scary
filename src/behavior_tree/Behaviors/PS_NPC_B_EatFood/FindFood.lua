local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.calmBehaviorState ~= shared.npc.states.behavior.calm.hungry then
		warn("objective behaviorState is not correct...")
		isForceFail = true
		return
	end

	local foodObject = self:FindFood()
	if not foodObject then
		warn("foodObject is nil...")
		isForceFail = true
		return
	end

	Blackboard.objective.interactObject = foodObject
	Blackboard.objective.walkToInstance = foodObject.navStart
	Blackboard.objective.goalRoom = foodObject.room
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

	return SUCCESS
end


return btTask
