local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3
local tickStartListen = nil
local initListening = false
local isForceFail = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if Blackboard.calmBehaviorState ~= shared.npc.states.behavior.calm.investigate then
		warn("objective behaviorState is not correct...")
		isForceFail = true
		return
	end

	self.navigation:Stop()
	initListening = false

	self.stateUI.Text = "❔"
	task.wait(1)
	self.stateUI.Text = "🔊"
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	isForceFail = false

	if status == SUCCESS then
		Blackboard.calmSoundSuspicion += 1

	elseif status == FAIL then
		warn("Theres someone here!!!!!!")
		Blackboard.isSoundHeard = false
		Blackboard.detectionState = shared.npc.states.detection.alert
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

	if Blackboard.calmSoundSuspicion > 2 then
		self.stateUI.Text = "❕"
		task.wait(0.5)
		return FAIL
	end

	if tick() - tickStartListen > 3 and Blackboard.isSoundHeard == false then
		self.stateUI.Text = "💢"
		task.wait(0.5)
		return SUCCESS
	end

	return RUNNING
end


return btTask
