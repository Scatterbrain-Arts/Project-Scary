local Players = game:GetService("Players")

local require = require(script.Parent.loader).load(script)

local GetRemoteEvent = require("GetRemoteEvent")
local GameOverEvent = GetRemoteEvent("GameOverEvent")

local Maid = require("Maid")
local Locks = require("Locks")

local Talisman = {}
Talisman.__index = Talisman
Talisman.TAG_NAME = "Talisman"

Talisman.Collected = 0
Talisman.Count = 0

print(Players.LocalPlayer)


function Talisman.new(talismanInstance, serviceBag)
    local self = {}
    setmetatable(self, Talisman)

	self.maid = Maid.new()
	self.entity = talismanInstance
	self.name = talismanInstance.Name
	self.prompt = talismanInstance:FindFirstChild("ProximityPrompt") or Instance.new("ProximityPrompt", talismanInstance)
	self.talismanNumber = tonumber(string.match(self.name, "%d+"))

	Talisman.Count += 1
	self.debounce = false
	self.prompt.ActionText = "Collect Talisman"

	self.prompt.Triggered:Connect(function(player)
		self.debounce = true
		self.entity.Transparency = 1
		Talisman.Collected += 1

		if Talisman.Collected == Talisman.Count then
			GameOverEvent:FireClient(Players:GetPlayers()[1])
		end
		self.prompt.Enabled = false
		self.debounce = false
	end)

	Locks.Signals.unlock:Connect(function(keyNumber)
		if not self.talismanNumber then
			return
		end

		if self.talismanNumber == keyNumber then
			self.prompt.Enabled = true
		end
	end)

	self.prompt.Enabled = self.talismanNumber == nil
	return self
end


return Talisman