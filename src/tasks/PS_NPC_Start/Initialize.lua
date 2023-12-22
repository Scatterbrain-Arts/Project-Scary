local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local tickLast = nil


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	tickLast = tick()
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	Blackboard.isActive = true
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.isActive then
		return SUCCESS
	end

	return tick() - tickLast > 1 and SUCCESS or RUNNING
end


return btTask
