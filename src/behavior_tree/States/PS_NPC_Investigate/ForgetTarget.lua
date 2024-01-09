local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local STATE_CALM, STATE_ALERT, STATE_HOSTILE = shared.npc.states.detection.calm, shared.npc.states.detection.alert, shared.npc.states.detection.hostile


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	Blackboard.target = nil
	Blackboard.targetPosition = nil
	Blackboard.isTargetLost = nil
	Blackboard.lastKnownPosition = nil
	Blackboard.lastKnownRegion = nil
	Blackboard.isSoundHeard = false

	Blackboard.state = STATE_CALM
	self.soundDetection:UpdateState()
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	return SUCCESS
end


return btTask
