local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local tickLast = nil


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	self.navigation:Stop()
	tickLast = tick()
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	return tick() - tickLast > Blackboard.defaultWaitTime and SUCCESS or RUNNING
end


return btTask
