local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local GeneralUtil = require(Packages.GeneralUtil)

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not Blackboard.objective.actionPosition.AlignPosition or not Blackboard.objective.actionPosition.AlignOrientation then
		warn("Aligns are nil...")
		isForceFail = true
		return
	end
	isForceFail = false

	Blackboard.objective.actionPosition.AlignPosition.Attachment0 = self.root.RootAttachment
	Blackboard.objective.actionPosition.AlignPosition.Attachment1 = Blackboard.objective.actionPosition.Attachment

	Blackboard.objective.actionPosition.AlignOrientation.Attachment0 = self.root.RootAttachment
	Blackboard.objective.actionPosition.AlignOrientation.Attachment1 = Blackboard.objective.actionPosition.Attachment
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


	if GeneralUtil:GetAngleDifference(self.root.Orientation.Y, Blackboard.objective.actionPosition.Attachment.Orientation.Y) <= 1 then
		return SUCCESS
	end

	return RUNNING
end


return btTask
