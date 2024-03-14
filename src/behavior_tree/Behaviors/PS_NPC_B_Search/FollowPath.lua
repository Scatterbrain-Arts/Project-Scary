local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local RunService = game:GetService("RunService")
local GeneralUtil = require(Packages.GeneralUtil)

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self
	local objective = Blackboard.objective

	if next(objective.searchRoutePath) == nil then
		warn("Table is empty...")
		isForceFail = true
		return
	end

	local target = objective.searchRoutePath[#objective.searchRoutePath]
	self.navigation:PathToTarget(target.Position)
	table.remove(objective.searchRoutePath, #objective.searchRoutePath)
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	isForceFail = false
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self
	local objective = Blackboard.objective

	if isForceFail then
		return FAIL
	end

	if Blackboard.isTargetReached then
		return SUCCESS
	end

	return Blackboard.isTargetReached ~= nil and RUNNING or FAIL
end


return btTask
