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

	self.soundHeardThreshold = 3
	self.statusCalmThreshold = 10
	self.statusAlertThreshold = 25
	self.statusHostileThreshold = 50

	self.isSoundHeard = false

	self.tickLastSoundHeard = tick()

	self.soundAwareness = 0

	self.cycleLock = false
	self.cycleRefresh = 1
	self.cycleStartTime = tick()
	RunService.Heartbeat:Connect(function(deltaTime)
		if tick() - self.cycleStartTime >= self.cycleRefresh then
			self:Listen()
			self.cycleStartTime = tick()


			if tick() - self.tickLastSoundHeard >= 7 then
				if self.soundAwareness < self.statusCalmThreshold then
					self.soundAwareness = math.clamp(self.soundAwareness - 1, 0, 100)
				end
			end

			self.guiNPC.GuiNPCBar.Size = UDim2.fromScale(self.soundAwareness / 100, 1)
			self.guiNPC.GuiNPCPercent.Text = math.floor(self.soundAwareness) .. " pts"

			if self.soundAwareness >= self.statusCalmThreshold then
				self.blackboard.state = shared.npc.states.perception.alert
				self.guiNPC.GuiNPCIsAlert.Visible = true
				self.guiNPC.GuiNPCIsHostile.Visible = false
				self.guiNPC.GuiNPCIsCalm.Visible = false
				self.guiNPC.GuiNPCStatus.Text = "ALERT"
				self.blackboard.isSoundHeard = true
				self.isSoundHeard = true
			else
				self.blackboard.state = shared.npc.states.perception.calm
				self.guiNPC.GuiNPCIsAlert.Visible = false
				self.guiNPC.GuiNPCIsHostile.Visible = false
				self.guiNPC.GuiNPCIsCalm.Visible = true
				self.guiNPC.GuiNPCStatus.Text = "CALM"
			end
		end
	end)

	return self
end


function SoundDetection:Listen()
	local distanceToSound = GeneralUtil:GetDistance(self.playerCharacter.PrimaryPart.Position, self.root.Position) / 8
	local inverseSquare = distanceToSound ^ (2)

	local apparentSound = math.clamp(self.PLAYER_STATUS.currentDecibel.Value / inverseSquare, 0, 100)

	--print("apparentSound:", apparentSound)

	local normalizedSound = apparentSound / self.soundHeardThreshold
	if normalizedSound >= 1 then
		local detectionAmount = math.floor(normalizedSound%10)
		print("heard:", detectionAmount)

		self.soundAwareness += detectionAmount

		self.tickLastSoundHeard = tick()
	end

end




return SoundDetection