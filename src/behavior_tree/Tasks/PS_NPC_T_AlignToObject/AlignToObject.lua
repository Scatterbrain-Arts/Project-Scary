local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(Packages.GeneralUtil)

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.objective.walkToInstance.AlignPosition or not Blackboard.objective.walkToInstance.AlignOrientation then
		warn("Aligns are nil...")
		isForceFail = true
		return
	end

	Blackboard.isObjectiveAlignReached = false

	Blackboard.objective.walkToInstance.AlignPosition.Attachment0 = self.root.RootAttachment
	Blackboard.objective.walkToInstance.AlignPosition.Attachment1 = Blackboard.objective.walkToInstance.Attachment

	Blackboard.objective.walkToInstance.AlignOrientation.Attachment0 = self.root.RootAttachment
	Blackboard.objective.walkToInstance.AlignOrientation.Attachment1 = Blackboard.objective.walkToInstance.Attachment
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	isForceFail = false
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isForceFail then
		return FAIL
	end

	local isAlignedOrientation = GeneralUtil:GetAngleDifference(self.root.Orientation.Y, Blackboard.objective.walkToInstance.Attachment.Orientation.Y) <= 1
	local isAlignedPosition = GeneralUtil:IsDistanceLess(self.root.Position, Blackboard.objective.walkToInstance.Position, 1, true)

	if isAlignedOrientation and isAlignedPosition then
		Blackboard.objective.walkToInstance.AlignOrientation.Attachment0 = nil
		Blackboard.objective.walkToInstance.AlignOrientation.Attachment1 = nil

		Blackboard.objective.walkToInstance.AlignPosition.Attachment0 = nil
		Blackboard.objective.walkToInstance.AlignPosition.Attachment1 = nil

		Blackboard.isObjectiveAlignReached = true

		return SUCCESS
	end


	return RUNNING
end


return btTask
