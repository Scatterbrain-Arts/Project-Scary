local Players = game:GetService("Players")

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	Blackboard.isObjective = self.mind:FindTarget()
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.isObjective then
		return SUCCESS
	elseif not Blackboard.isObjective then
		return FAIL
	else
		warn("Unexpected Error: Leaf-FindObjective...")
		return FAIL
	end
end


return btTask
