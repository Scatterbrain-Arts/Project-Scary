local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local isForceFail = false


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	print("start")
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	print("end")
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	print("run")

	return Blackboard.objective.currentRoom == Blackboard.objective.goalRoom and SUCCESS or FAIL
end


return btTask
