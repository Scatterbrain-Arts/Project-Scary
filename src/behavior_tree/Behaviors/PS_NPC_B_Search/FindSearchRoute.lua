local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	local range = 22
	local startPosition = Blackboard.player.Character.RightFoot.Position
	local path, readPath = self:FindSearchRoute(Blackboard.objective.goalRoom, startPosition, range)
	if not path then
		warn("Search route not found..")
		isForceFail = true
		return
	end

	Blackboard.objective.searchRoutePath = path
	Blackboard.objective.searchRoutePathReadOnly = readPath

	print("path:", Blackboard.objective.searchRoutePathReadOnly)
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

	return SUCCESS
end


return btTask
