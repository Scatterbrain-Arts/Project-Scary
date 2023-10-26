local Players = game:GetService("Players")

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	--print("find-Objective")
	local Blackboard = obj.Blackboard
	local self = obj.self

	self.mind:FindTarget()
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	return self.mind.objective and SUCCESS or FAIL
end


return btTask
