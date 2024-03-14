local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3
local tickStartListen = nil
local initListening = false
local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	self.navigation:Stop()
	initListening = false

	self.stateUI.Text = "🔊"
	task.wait(1)
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	isForceFail = false

	if status == SUCCESS then
		self.nodeMap:DebugPop()
		Blackboard.isPlayerFound = false

	elseif status == FAIL then
		Blackboard.isPlayerFound = true
		Blackboard.objective.isComplete = true
		Blackboard.detectionState = shared.npc.states.detection.hostile
	end
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if isForceFail then
		return FAIL
	end

	if not initListening then
		Blackboard.isSoundHeard = false
		tickStartListen = tick()
		initListening = true
	end

	if Blackboard.isSoundHeard == true then
		self.stateUI.Text = "❕❕❕"
		task.wait(0.5)
		return FAIL
	end

	if tick() - tickStartListen > 2 and Blackboard.isSoundHeard == false then
		self.stateUI.Text = "💢"
		task.wait(0.5)
		return SUCCESS
	end

	return RUNNING
end




return btTask
