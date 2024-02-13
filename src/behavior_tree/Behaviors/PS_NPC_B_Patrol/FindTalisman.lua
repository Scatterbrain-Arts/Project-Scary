local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.calmBehaviorState ~= shared.npc.states.behavior.calm.patrol then
		warn("objective behaviorState is not correct...")
		isForceFail = true
		return
	end


	local talismanObject = self:FindTalisman()
	if not talismanObject then
		warn("talismanObject is nil...")
		isForceFail = true
		return
	end

	Blackboard.objective.interactObject = talismanObject
	Blackboard.objective.walkToInstance = talismanObject.navStart
	Blackboard.objective.goalRoom = talismanObject.room
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
