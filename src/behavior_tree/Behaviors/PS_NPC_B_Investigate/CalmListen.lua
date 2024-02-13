local btTask = {}

local SUCCESS,FAIL,RUNNING = 1,2,3
local tickStartListen = nil
local initListening = false

function btTask.start(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	self.navigation:Stop()
	initListening = false

	self.stateUI.Text = "❔"
	task.wait(1)
	self.stateUI.Text = "🔊"
end


function btTask.finish(obj, status)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if status == SUCCESS then
		Blackboard.calmSoundSuspicion += 1

	elseif status == FAIL then
		print("Found you...")
		-- Blackboard.lastSoundHeardPosition = Blackboard.player.Character.RightFoot.Position
		-- Blackboard.isSoundHeard = false
		-- Blackboard.detectionState = shared.npc.states.detection.alert
		-- Blackboard.alertBehaviorState = shared.npc.states.behavior.alert.investigate
	end
end


function btTask.run(obj)
	local Blackboard = obj.Blackboard
	local self = obj.self

	if not initListening then
		Blackboard.isSoundHeard = false
		tickStartListen = tick()
		initListening = true
	end

	if Blackboard.isSoundHeard == true or Blackboard.calmSoundSuspicion > 3 then
		self.stateUI.Text = "❕"
		task.wait(0.5)
		return FAIL
	end

	if tick() - tickStartListen > 3 and Blackboard.isSoundHeard == false then
		self.stateUI.Text = "🤷‍♀️"
		task.wait(0.5)
		return SUCCESS
	end

	return RUNNING
end


return btTask
