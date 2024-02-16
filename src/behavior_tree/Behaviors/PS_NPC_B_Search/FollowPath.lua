local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local RunService = game:GetService("RunService")
local GeneralUtil = require(Packages.GeneralUtil)

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false
local count = 0
local countMax = nil


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self
	local objective = Blackboard.objective

	if next(objective.searchRoutePath) == nil then
		warn("Table is empty...")
		isForceFail = true
		return
	end

	print("starting follow", #objective.searchRoutePath)

	local max = 4
	local min = 1
	local rnd = math.random(min, max)
	while #objective.searchRoutePath - rnd < 0 do
		max -= 1
		rnd = math.random(min, max)
	end
	countMax = rnd

	local target = objective.searchRoutePath[#objective.searchRoutePath]
	self.navigation:PathToTarget(target.Position)
	table.remove(objective.searchRoutePath, #objective.searchRoutePath)
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	isForceFail = false
	count = 0
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self
	local objective = Blackboard.objective

	if isForceFail then
		return FAIL
	end

	if Blackboard.isTargetReached then
		count += 1
		if count < countMax and next(objective.searchRoutePath) ~= nil then
			local target = objective.searchRoutePath[#objective.searchRoutePath]
			self.navigation:PathToTarget(target.Position)
			table.remove(objective.searchRoutePath, #objective.searchRoutePath)
			return RUNNING

		else
			return SUCCESS
		end
	end

	return Blackboard.isTargetReached ~= nil and RUNNING or FAIL
end


return btTask
