local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.alertBehaviorState ~= shared.npc.states.behavior.alert.search then
		warn("objective behaviorState is not correct...")
		isForceFail = true
		return
	end

	local playerRoom = self.navigation:FindRegionWithPlayer()
	if not playerRoom then
		warn("search area is nil...")
		isForceFail = true
		return
	end

	-- Blackboard.objective.interactObject = talismanObject
	-- Blackboard.objective.walkToInstance = talismanObject.navStart
	Blackboard.objective.goalRoom = playerRoom
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
