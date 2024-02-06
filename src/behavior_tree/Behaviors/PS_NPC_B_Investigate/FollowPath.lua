local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	self.navigation:PathToTarget(Blackboard.searchPath[#Blackboard.searchPath].Position)
	table.remove(Blackboard.searchPath, #Blackboard.searchPath)
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

	if Blackboard.isTargetReached then
		if next(Blackboard.searchPath) then
			self.navigation:PathToTarget(Blackboard.searchPath[#Blackboard.searchPath].Position)
			table.remove(Blackboard.searchPath, #Blackboard.searchPath)
			return RUNNING
		else
			return SUCCESS
		end
	end

	return Blackboard.isTargetReached ~= nil and RUNNING or FAIL
end


return btTask
