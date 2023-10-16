local Players = game:GetService("Players")

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self


	local targetData = self.mind:FindTarget()

	Blackboard.target.priority = targetData.priority
	Blackboard.target.sense = targetData.sense
	Blackboard.target.positionKnown = targetData.position
	Blackboard.target.isPlayer = targetData.isPlayer
	Blackboard.target.isSearched = targetData.isSearched
	Blackboard.target.object = targetData.object

	if self.config["entity"].isDebug then
		self.debug:TargetAddIndicator(Blackboard.target.positionKnown, Blackboard.target.object)
	end
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	return SUCCESS
end


return btTask
