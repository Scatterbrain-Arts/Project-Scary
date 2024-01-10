local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.objective.goal ~= shared.npc.states.behavior.calmNames[shared.npc.states.behavior.calm.patrol] or Blackboard.objective.goalCondition then
		warn("objective is not correct...")
		isForceFail = true
		return
	end
	isForceFail = false

	local talismanObject = self:FindTalisman()
	if talismanObject then
		Blackboard.objective.actionObject = talismanObject
		Blackboard.objective.actionPosition = talismanObject.navStart
		Blackboard.objective.goalRoom = talismanObject.room
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

	return (Blackboard.objective.actionObject and Blackboard.objective.actionPosition) and SUCCESS or FAIL
end


return btTask
