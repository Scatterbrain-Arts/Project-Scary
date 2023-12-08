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


	self.hunt = false

	self.bar = 0

	self.cycleLock = false
	self.cycleRefresh = 1
	self.cycleStartTime = tick()
	RunService.Heartbeat:Connect(function(deltaTime)
		if tick() - self.cycleStartTime >= self.cycleRefresh then
			self:Listen()
			self.cycleStartTime = tick()

			self.bar = math.clamp(self.bar - 1, 0, 100)

			self.guiNPC.GuiNPCBar.Size = UDim2.fromScale(self.bar / 100, 1)
			self.guiNPC.GuiNPCPercent.Text = math.floor(self.bar) .. " pts"

			if self.bar > 10 then
				self.guiNPC.GuiNPCIsAlert.Visible = false
				self.guiNPC.GuiNPCIsHostile.Visible = true
				self.guiNPC.GuiNPCIsCalm.Visible = false
				self.guiNPC.GuiNPCStatus.Text = "HOSTILE"
				self.hunt = true
			else
				self.guiNPC.GuiNPCIsAlert.Visible = false
				self.guiNPC.GuiNPCIsHostile.Visible = false
				self.guiNPC.GuiNPCIsCalm.Visible = true
				self.guiNPC.GuiNPCStatus.Text = "CALM"
				self.hunt = false
			end
		end
	end)

	return self
end


function SoundDetection:Listen()
	local distanceToSound = GeneralUtil:GetDistance(self.playerCharacter.PrimaryPart.Position, self.root.Position) / 8
	local inverseSquare = distanceToSound ^ (2)

	local apparentSound = math.clamp(self.PLAYER_STATUS.currentDecibel.Value / inverseSquare, 0, 100)

	print("apparentSound:", apparentSound)
	self.bar += apparentSound
end




return SoundDetection