local RunService = game:GetService("RunService")

local require = require(script.Parent.loader).load(script)

local GeneralUtil = require("GeneralUtil")
local Math = require("Math")

local SoundDetection = {}
SoundDetection.__index = SoundDetection

function SoundDetection.new(npc)
    local self = {}
    setmetatable(self, SoundDetection)

	self.npc = npc
    self.config = npc.config
    self.character = npc.character
    self.humanoid = npc.humanoid
    self.root = npc.root
	self.blackboard = npc.btState.Blackboard

	print(self.blackboard)

	self.player = npc.player
	self.playerCharacter = npc.playerCharacter

	local configFolder = GeneralUtil:Get("Folder", self.character, "config")
	local configSound = GeneralUtil:Get("Configuration", configFolder, "sound")

    self.isDebug = GeneralUtil:GetBool(configSound, "_isDebug", true)
	self.CONFIG = {

	}

	local playerStatusFolder = GeneralUtil:Get("Folder", self.playerCharacter, "status")
	self.PLAYER_STATUS = {
		currentDecibel = GeneralUtil:GetNumber(playerStatusFolder, "current decibel", self.isDebug.Value)
	}

	local GuiNPC = GeneralUtil:GetUI(self.player.PlayerGui, "npc")
	GuiNPC.Enabled = true
	self.guiNPC = {
		GuiNPCBar =  GeneralUtil:GetUI(GuiNPC, "fg"),
		GuiNPCIsCalm = GeneralUtil:GetUI(GuiNPC, "calmbg").button,
		GuiNPCIsAlert = GeneralUtil:GetUI(GuiNPC, "alertbg").button,
	 	GuiNPCIsHostile = GeneralUtil:GetUI(GuiNPC, "hostilebg").button,
	 	GuiNPCPercent = GeneralUtil:GetUI(GuiNPC, "Percent"),
		GuiNPCStatus = GeneralUtil:GetUI(GuiNPC, "Status"),
	}

	self.tickLastSoundHeard = tick()
	self.soundAwareness = 0
	self.soundHeardThreshold = 3

	self.statusCalmThreshold = 10
	local statusAlertThreshold = 25
	local statusHostileThreshold = 50

	local secondsPerCycle = 1
	local tickLastCycle = tick()
	RunService.Heartbeat:Connect(function(deltaTime)
		if tick() - tickLastCycle >= secondsPerCycle then
			self:Listen()

			if tick() - self.tickLastSoundHeard >= 7 then
				if self.soundAwareness < self.statusCalmThreshold then
					self.soundAwareness = math.clamp(self.soundAwareness - 1, 0, 100)
				end
			end

			self.guiNPC.GuiNPCBar.Size = UDim2.fromScale(self.soundAwareness / 100, 1)
			self.guiNPC.GuiNPCPercent.Text = math.floor(self.soundAwareness) .. " pts"

			if self.blackboard.state == shared.npc.states.perception.alert and self.blackboard.target then
				if GeneralUtil:IsDistanceGreater(self.root.Position, self.blackboard.targetPosition, 30) then
					self.blackboard.isTargetLost = true
				end
			end

			tickLastCycle = tick()
		end

		
	end)

	return self
end


function SoundDetection:Listen()
	local distanceToSound = GeneralUtil:GetDistance(self.playerCharacter.PrimaryPart.Position, self.root.Position) / 8
	local inverseSquare = distanceToSound ^ (2)

	local apparentSound = math.clamp(self.PLAYER_STATUS.currentDecibel.Value / inverseSquare, 0, 100)

	local normalizedSound = apparentSound / self.soundHeardThreshold
	if normalizedSound >= 1 then
		local detectionAmount = math.floor(normalizedSound%10)
		self.soundAwareness += detectionAmount

		if self.blackboard.isSoundHeard == false and self.blackboard.state == shared.npc.states.perception.calm and self.soundAwareness >= self.statusCalmThreshold then
			self.blackboard.isSoundHeard = true
			self.tickLastSoundHeard = tick()
		end
	end
end

function SoundDetection:UpdateState()
	local newState = self.blackboard.state
	self.guiNPC.GuiNPCIsAlert.Visible = newState == shared.npc.states.perception.alert
	self.guiNPC.GuiNPCIsHostile.Visible = newState == shared.npc.states.perception.hostile
	self.guiNPC.GuiNPCIsCalm.Visible = newState == shared.npc.states.perception.calm
	self.guiNPC.GuiNPCStatus.Text = string.upper( shared.npc.states.perceptionNames[newState] )
end




return SoundDetection