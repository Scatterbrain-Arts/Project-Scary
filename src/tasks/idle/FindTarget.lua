local Players = game:GetService("Players")

local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	Blackboard.players = Blackboard.players or {}

	local minDist = math.huge
	for _, player in Players:GetPlayers() do
		local playerCharacter = player.Character

		if playerCharacter then
			local dist = (self.root.Position - playerCharacter.PrimaryPart.Position).Magnitude
			if dist < minDist then
				minDist = dist
				Blackboard.nearestTarget = player
			end

			Blackboard.players[tostring(player.UserId)] = {
				player = player,
				character = playerCharacter,
				distance = dist,
			}
		end
	end

	if Blackboard.nearestTarget then
		local nearestTarget = Blackboard.players[tostring(Blackboard.nearestTarget.UserId)]
		if nearestTarget.distance <= self.stats.sightRange then
			Blackboard.isPath = self:FindPath(self.root.Position, nearestTarget.character.PrimaryPart.Position, self.navigationCurrent)
		end
	end
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self
end


function btTask.run(obj)
	--print("FindTarget-run")
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.isPath then
		return SUCCESS
	elseif not Blackboard.isPath then
		return FAIL
	else
		warn("FindTarget Task: Unexpected fail...")
		return FAIL
	end
end


return btTask
