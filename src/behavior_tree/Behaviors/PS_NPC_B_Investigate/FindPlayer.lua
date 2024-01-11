local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.objective.goal ~= shared.npc.states.behavior.alertNames[shared.npc.states.behavior.calm.investigate] or Blackboard.objective.goalCondition then
		warn("objective is not correct...")
		isForceFail = true
		return
	end
	isForceFail = false

	-- local foodObject = self:FindFood()
	-- if foodObject then
	-- 	Blackboard.objective.actionObject = foodObject
	-- 	Blackboard.objective.actionPosition = foodObject.navStart
	-- 	Blackboard.objective.goalRoom = foodObject.room
	-- end
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
