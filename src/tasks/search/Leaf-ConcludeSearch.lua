local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	self.mind:SearchStart()
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	self.mind:SearchEnd()
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if tick() - self.mind.searchStartTime < self.mind.searchTimer then
		return RUNNING
	else
		return SUCCESS
	end
end


return btTask
