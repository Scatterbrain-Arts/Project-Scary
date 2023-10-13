local Players = game:GetService("Players")

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	print("select")
	local Blackboard = obj.Blackboard
	local self = obj.self

	-- for _, player in Players:GetPlayers() do
	-- 	local playerCharacter = player:WaitForChild("Character")

	-- 	if playerCharacter then
	-- 		Blackboard.playerInfo = {
	-- 			localPlayer = player,
	-- 			character = playerCharacter,
	-- 		}
	-- 	end
	-- end
	local target = self:GetPatrolPoint()
	Blackboard.target = {
		isPlayer = false,
		isActive = true,
		object = target.object,
		positionKnown = target.position
	}
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
