local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(Packages.GeneralUtil)

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local rayLineOfSight = nil
local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.target or not Blackboard.targetPosition then
		warn("Target or TargetPosition is nil...")
		isForceFail = true
		return
	end

	rayLineOfSight = GeneralUtil:CastSphere(self.root.Position, 2, Blackboard.targetPosition - self.root.Position, Blackboard.collisionGroupRayLoS, false)
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

	Blackboard.isLineOfSight = rayLineOfSight and rayLineOfSight.Instance.Parent.Name == Blackboard.player.Name or false

	return Blackboard.isLineOfSight ~= nil and SUCCESS or FAIL
end


return btTask
