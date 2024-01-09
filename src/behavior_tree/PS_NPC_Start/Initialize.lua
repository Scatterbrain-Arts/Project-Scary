local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3

local tickLast = nil
local isInit = false

local count = nil


function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isInit then
		return
	end
	count = 1
	print("bt loop:", count)
	tickLast = tick()
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isInit then
		count += 1
		print("bt loop:", count)
		return
	end

	Blackboard.detectionState = shared.npc.states.detection.calm
	Blackboard.calmBehaviorState = shared.npc.states.behavior.calm.hungry
	isInit = true
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isInit then
		return SUCCESS
	end

	return tick() - tickLast > 1 and SUCCESS or RUNNING
end


return btTask
